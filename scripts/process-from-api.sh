#!/bin/bash

# =============================================================================
# process-from-api.sh
# Traite un ticket Jira via l'API (sans export XML) et génère la documentation QA.
#
# Usage :
#   ./scripts/process-from-api.sh TICKET-ID [--force]
#   ./scripts/process-from-api.sh SPEX-3143
#   ./scripts/process-from-api.sh SPEX-3143 --force
#
# Ce script :
#   1. Appelle le CLI Jira pour extraire le contexte complet du ticket
#   2. Crée la structure de dossiers (projets/PROJET/us-XXXX/)
#   3. Sauvegarde le contexte comme extraction-jira.md
#   4. Crée le README depuis le template
#   5. Génère les 3 documents QA (questions, stratégie, cas de test)
#   6. Enregistre dans l'historique
#   7. Ajoute le label "qa-documented" sur le ticket Jira
# =============================================================================

set -euo pipefail

# ── Gestion des arguments ────────────────────────────────────────────────────

FORCE_REGENERATE=false
TICKET_ID=""
SKIP_LABEL=false

for arg in "$@"; do
    case "$arg" in
        --force) FORCE_REGENERATE=true ;;
        --skip-label) SKIP_LABEL=true ;;
        --help|-h)
            echo "Usage : $0 TICKET-ID [--force] [--skip-label]"
            echo ""
            echo "  TICKET-ID     Clé du ticket Jira (ex: SPEX-3143)"
            echo "  --force       Forcer la régénération même si déjà traité"
            echo "  --skip-label  Ne pas ajouter le label 'qa-documented' après traitement"
            echo ""
            echo "Exemples :"
            echo "  $0 SPEX-3143"
            echo "  $0 SPEX-3143 --force"
            exit 0
            ;;
        *)
            if [ -z "$TICKET_ID" ]; then
                TICKET_ID="$arg"
            fi
            ;;
    esac
done

if [ -z "$TICKET_ID" ]; then
    echo "Erreur : TICKET-ID requis"
    echo "Usage : $0 TICKET-ID [--force]"
    exit 1
fi

# ── Charger les bibliothèques ────────────────────────────────────────────────

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LIB_DIR="$SCRIPT_DIR/lib"
source "$LIB_DIR/config.sh"
source "$LIB_DIR/common-functions.sh"
source "$LIB_DIR/history-utils.sh"
source "$LIB_DIR/ticket-utils.sh"
source "$LIB_DIR/processing-utils.sh"

# ── Chemin du CLI Jira ───────────────────────────────────────────────────────

CLI_DIR="$BASE_DIR/jira-mcp-server"
CLI_JS="$CLI_DIR/dist/cli.js"

# Fichier de log pour capturer stderr des commandes API
LOG_DIR="${BASE_DIR}/logs"
mkdir -p "$LOG_DIR" 2>/dev/null || LOG_DIR="/tmp"
LOG_FILE="${LOG_DIR}/process-$(date +%Y%m%d-%H%M%S)-${TICKET_ID}.log"

# Vérifier que le CLI est buildé
if [ ! -f "$CLI_DIR/dist/cli.js" ]; then
    log_error "Le CLI Jira n'est pas buildé. Lancer : cd jira-mcp-server && npm run build"
    exit 1
fi

# Vérifier que le .env existe
if [ ! -f "$CLI_DIR/.env" ]; then
    log_error "Fichier .env manquant dans jira-mcp-server/"
    log_info "  Copier .env.example vers .env et renseigner les identifiants Jira"
    exit 1
fi

# ── Gestion des erreurs ─────────────────────────────────────────────────────

cleanup_on_error() {
    log_error "Erreur lors du traitement de $TICKET_ID."
    # Nettoyer le dossier si partiellement créé
    if [ -n "${US_DIR:-}" ] && [ -d "${US_DIR:-}" ] && [ "${DIR_CREATED:-false}" = true ]; then
        if [ ! -f "$US_DIR/01-questions-clarifications.md" ] && \
           [ ! -f "$US_DIR/02-strategie-test.md" ] && \
           [ ! -f "$US_DIR/03-cas-test.md" ]; then
            log_warning "Nettoyage du dossier partiellement créé : $US_DIR"
            rm -rf "$US_DIR"
        fi
    fi
    exit 1
}
trap cleanup_on_error ERR

# ── Extraction du contexte via API ───────────────────────────────────────────

log_info "Extraction du contexte pour $TICKET_ID via l'API Jira..."
echo ""

CONTEXT_OUTPUT=$(cd "$CLI_DIR" && node "$CLI_JS" context "$TICKET_ID" 2>>"$LOG_FILE") || {
    log_error "Impossible d'extraire le contexte pour $TICKET_ID (voir $LOG_FILE)"
    log_info "  Vérifier les identifiants dans jira-mcp-server/.env"
    log_info "  Vérifier que le ticket existe : $JIRA_BASE_URL/browse/$TICKET_ID"
    exit 1
}

if [ -z "$CONTEXT_OUTPUT" ]; then
    log_error "Le contexte extrait est vide pour $TICKET_ID"
    exit 1
fi

# Extraire les informations du contexte
# Le titre est sur la première ligne : # TICKET-ID: Titre
TITLE=$(echo "$CONTEXT_OUTPUT" | head -1 | sed 's/^# [A-Z]*-[0-9]*: //')
KEY="$TICKET_ID"
PROJECT_DIR=$(echo "$KEY" | sed 's/-[0-9]*//')
TICKET_NUMBER=$(echo "$KEY" | sed 's/[A-Z]*-//')
LINK="$JIRA_BASE_URL/browse/$KEY"

log_info "Informations extraites :"
log_info "   Projet : $PROJECT_DIR"
log_info "   Ticket : $KEY"
log_info "   Titre  : $TITLE"
echo ""

# ── Vérification du traitement précédent ─────────────────────────────────────

US_DIR=""
DIR_CREATED=false

if is_ticket_processed "$KEY" 2>/dev/null; then
    existing_info=$(get_treatment_info "$KEY" 2>/dev/null || echo "")
    existing_dir=$(echo "$existing_info" | cut -d'|' -f1)
    existing_date=$(echo "$existing_info" | cut -d'|' -f2)

    if [ -n "$existing_dir" ] && [ -d "$existing_dir" ]; then
        log_warning "Le ticket $KEY a déjà été traité le ${existing_date:-N/A}"
        log_info "   Dossier existant : $existing_dir"

        if [ "$FORCE_REGENERATE" = true ]; then
            log_warning "   Mode --force activé : régénération forcée"
            US_DIR="$existing_dir"
        else
            log_info "   Utilisation du dossier existant (utiliser --force pour régénérer)"
            exit 0
        fi
    fi
fi

# ── Créer la structure de dossiers ───────────────────────────────────────────

if [ -z "$US_DIR" ]; then
    US_DIR="$PROJETS_DIR/$PROJECT_DIR/us-$TICKET_NUMBER"

    if ! check_write_permissions "$PROJETS_DIR"; then
        exit 1
    fi

    if [ -d "$US_DIR" ] && [ "$FORCE_REGENERATE" != true ]; then
        log_warning "Le dossier $US_DIR existe déjà. Utiliser --force pour écraser."
        exit 1
    fi

    if ! safe_mkdir "$US_DIR"; then
        exit 1
    fi
    DIR_CREATED=true
    log_success "Structure créée : $US_DIR"
    echo ""
fi

# ── Sauvegarder le contexte comme extraction-jira.md ─────────────────────────

echo "$CONTEXT_OUTPUT" > "$US_DIR/extraction-jira.md"
log_success "extraction-jira.md créé (contexte API)"

# ── Extraire métadonnées (parent/EPIC, type) pour Notion et historique ───────
# Format extraction-jira : "- **Type**: Story" et "- **Parent/Epic**: KEY (Summary)" ou "Aucun"
PARENT_KEY=""
ISSUE_TYPE="Story"
if [ -f "$US_DIR/extraction-jira.md" ]; then
    _type_line=$(grep -E '^\s*-\s+\*\*Type\*\*:' "$US_DIR/extraction-jira.md" | head -1)
    if [ -n "$_type_line" ]; then
        ISSUE_TYPE=$(echo "$_type_line" | sed -E 's/.*\*\*Type\*\*:\s*//' | tr -d '\r\n' | xargs)
    fi
    _parent_line=$(grep -E '^\s*-\s+\*\*Parent/Epic\*\*:' "$US_DIR/extraction-jira.md" | head -1)
    if [ -n "$_parent_line" ] && ! echo "$_parent_line" | grep -qE 'Aucun\s*$'; then
        PARENT_KEY=$(echo "$_parent_line" | sed -E 's/.*\*\*Parent\/Epic\*\*:\s*([A-Za-z]+-[0-9]+).*/\1/' | tr -d '\r\n' | xargs)
    fi
fi

# Écrire meta.json dans le dossier US (pour sync-notion et rapports)
META_JSON="$US_DIR/meta.json"
if command -v python3 &>/dev/null; then
    python3 <<PYEOF
import json
parent = "$PARENT_KEY".strip() or None
meta = {
    "ticket_key": "$KEY",
    "projectKey": "$PROJECT_DIR",
    "parentKey": parent,
    "issuetype": "$ISSUE_TYPE"
}
with open("$META_JSON", "w", encoding="utf-8") as f:
    json.dump(meta, f, indent=2, ensure_ascii=False)
PYEOF
else
    echo "{\"ticket_key\":\"$KEY\",\"projectKey\":\"$PROJECT_DIR\",\"parentKey\":\"${PARENT_KEY:-}\",\"issuetype\":\"$ISSUE_TYPE\"}" > "$META_JSON"
fi
log_info "Métadonnées enregistrées : projet=$PROJECT_DIR, parent=${PARENT_KEY:-Aucun}, type=$ISSUE_TYPE"

# ── Créer le README ──────────────────────────────────────────────────────────

TEMPLATE_FILE="$TEMPLATES_DIR/us-readme-template.md"
if [ ! -f "$TEMPLATE_FILE" ]; then
    log_error "Template README introuvable : $TEMPLATE_FILE"
    exit 1
fi

cp "$TEMPLATE_FILE" "$US_DIR/README.md"

# Remplacer les placeholders (compatible macOS et Linux)
TITLE_ESCAPED=$(echo "$TITLE" | sed 's/[&/\]/\\&/g')
README_TMP="$US_DIR/README.md.tmp"
sed \
    -e "s|\[US-XXX\]|$KEY|g" \
    -e "s|\[Nom de la User Story\]|$TITLE_ESCAPED|g" \
    -e "s|\[NOM_PROJET\]|$PROJECT_DIR|g" \
    -e "s|\[NUMBER\]|$TICKET_NUMBER|g" \
    -e "s|\[URL du ticket\]|$LINK|g" \
    -e "s|\[AAAA-MM-JJ\]|$(date +"%Y-%m-%d")|g" \
    "$US_DIR/README.md" > "$README_TMP" && mv "$README_TMP" "$US_DIR/README.md"

log_success "README.md créé"
echo ""

# ── Générer les 3 documents QA ──────────────────────────────────────────────

log_info "Génération des documents QA..."
echo ""

# Charger les utilitaires Cursor AI si disponibles
if [ -f "$LIB_DIR/cursor-ai-utils.sh" ]; then
    source "$LIB_DIR/cursor-ai-utils.sh"
    source "$LIB_DIR/xml-utils.sh" 2>/dev/null || true
    source "$LIB_DIR/acceptance-criteria-utils.sh" 2>/dev/null || true
fi

# Script de génération depuis le contexte (fallback sans XML)
GENERATE_CONTEXT_SCRIPT="$SCRIPTS_DIR/generate-from-context.sh"

# Vérifie rapidement si le fichier ressemble à du Markdown QA (pas à l'écran de connexion Cursor).
is_sensible_qa_content() {
    local f="$1"
    [ ! -f "$f" ] || [ ! -s "$f" ] && return 1
    if grep -q "Press any key to sign in\|Cursor Agent" "$f" 2>/dev/null; then return 1; fi
    head -30 "$f" | grep -qE '^(#+ |## |\- )' 2>/dev/null || return 1
    return 0
}

# Fonction pour générer un document avec fallback en 3 niveaux :
#   1. Cursor AI (CLI cursor-agent/cursor — si disponible et sortie valide)
#   2. generate-from-context.sh (génération depuis extraction-jira.md, sans Cursor)
#   3. Placeholder (dernier recours)
# En mode non-interactif, le CLI Cursor peut écrire un écran de connexion dans le fichier ;
# on détecte ce cas et on bascule sur le niveau 2.
generate_doc() {
    local doc_type="$1"
    local doc_file="$2"

    log_info "Génération de $doc_file..."

    # Niveau 1 : Cursor AI (CLI)
    if type generate_document_directly &>/dev/null; then
        if generate_document_directly "$doc_type" "$US_DIR" 2>/dev/null; then
            if [ -f "$US_DIR/$doc_file" ] && [ -s "$US_DIR/$doc_file" ]; then
                if is_sensible_qa_content "$US_DIR/$doc_file"; then
                    log_success "$doc_file généré avec Cursor IA"
                    return 0
                fi
                log_warning "  Contenu invalide (écran Cursor ?), bascule vers génération depuis le contexte."
                rm -f "$US_DIR/$doc_file"
            fi
        fi
    fi

    # Niveau 2 : Générateur depuis le contexte (extraction-jira.md)
    if [ -f "$GENERATE_CONTEXT_SCRIPT" ]; then
        log_info "  Génération depuis le contexte API (extraction-jira.md)..."
        if bash "$GENERATE_CONTEXT_SCRIPT" "$doc_type" "$US_DIR" 2>/dev/null; then
            if [ -f "$US_DIR/$doc_file" ] && [ -s "$US_DIR/$doc_file" ]; then
                log_success "$doc_file généré depuis le contexte"
                return 0
            fi
        fi
    fi

    # Niveau 3 : Placeholder
    log_warning "  Génération automatique impossible pour $doc_file"
    log_info "  Création d'un placeholder..."
    cat > "$US_DIR/$doc_file" <<PLACEHOLDER
# ${doc_file%.md}

> **A GENERER** : Ce document doit être généré manuellement ou avec Cursor AI.
>
> Contexte disponible dans : [extraction-jira.md](extraction-jira.md)
>
> Commandes :
> \`make process-force T=$KEY\`
> \`./scripts/generate-from-context.sh $doc_type $US_DIR\`

---

*Placeholder créé le $(date +"%Y-%m-%d") — En attente de génération*
PLACEHOLDER
    return 0
}

generate_doc "questions" "01-questions-clarifications.md"
echo ""
generate_doc "strategy" "02-strategie-test.md"
echo ""
generate_doc "test-cases" "03-cas-test.md"
echo ""

# ── Enregistrer dans l'historique ────────────────────────────────────────────

export RECORD_PROJECT_KEY="$PROJECT_DIR"
export RECORD_PARENT_KEY="$PARENT_KEY"
export RECORD_ISSUE_TYPE="$ISSUE_TYPE"
record_treatment "$KEY" "$US_DIR"
log_success "Traitement enregistré dans l'historique"

# ── Ajouter le label qa-documented ───────────────────────────────────────────

if [ "$SKIP_LABEL" != true ]; then
    log_info "Ajout du label '$QA_DOCUMENTED_LABEL' sur $KEY..."
    if cd "$CLI_DIR" && node "$CLI_JS" label add "$KEY" "$QA_DOCUMENTED_LABEL" 2>>"$LOG_FILE"; then
        log_success "Label '$QA_DOCUMENTED_LABEL' ajouté sur $KEY"
    else
        log_warning "Impossible d'ajouter le label (non bloquant)"
    fi
fi

# ── Validation automatique ────────────────────────────────────────────────────

VALIDATE_SCRIPT="$SCRIPTS_DIR/validate-docs.sh"
if [ -f "$VALIDATE_SCRIPT" ]; then
    log_info "Validation automatique des documents générés..."
    if bash "$VALIDATE_SCRIPT" "$US_DIR" 2>/dev/null; then
        log_success "Validation OK — tous les critères de qualité satisfaits"
    else
        log_warning "Validation : certains critères de qualité ne sont pas satisfaits"
        log_warning "Relancer : bash scripts/validate-docs.sh $US_DIR --strict"
    fi
fi

# ── Résumé ───────────────────────────────────────────────────────────────────

echo ""
log_success "Traitement terminé pour $KEY"
echo ""
echo "Fichiers créés dans : $US_DIR"
echo "  - README.md"
echo "  - extraction-jira.md (contexte API)"
echo "  - 01-questions-clarifications.md"
echo "  - 02-strategie-test.md"
echo "  - 03-cas-test.md"
echo ""
echo "Prochaines étapes :"
echo "  1. Vérifier les documents générés dans $US_DIR"
echo "  2. Compléter les documents placeholder si nécessaire"
echo "  3. Synchroniser vers Xray : make sync-xray T=$KEY"
echo ""
