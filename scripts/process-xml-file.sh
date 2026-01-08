#!/bin/bash

# Script pour traiter un fichier XML Jira et préparer la génération de documentation QA
# Usage: ./scripts/process-xml-file.sh [FICHIER_XML] [--force]

set -euo pipefail

# Gestion des arguments
FORCE_REGENERATE=false
if [ "${2:-}" == "--force" ] || [ "${1:-}" == "--force" ]; then
    FORCE_REGENERATE=true
    # Si le premier argument est --force, le second est le fichier XML
    if [ "${1:-}" == "--force" ]; then
        XML_FILE="${2:-}"
    else
        XML_FILE="${1:-}"
    fi
else
    XML_FILE="${1:-}"
fi

# Charger les bibliothèques communes
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LIB_DIR="$SCRIPT_DIR/lib"
source "$LIB_DIR/config.sh"
source "$LIB_DIR/common-functions.sh"
source "$LIB_DIR/xml-utils.sh"
source "$LIB_DIR/processing-utils.sh"
source "$LIB_DIR/ticket-utils.sh"
source "$LIB_DIR/history-utils.sh"
source "$LIB_DIR/acceptance-criteria-utils.sh"

# Gestion des erreurs avec trap
cleanup_on_error() {
    log_error "Erreur lors du traitement. Nettoyage..."
    exit 1
}
trap cleanup_on_error ERR

if [ -z "$XML_FILE" ]; then
    log_error "Fichier XML requis"
    echo "Usage: ./scripts/process-xml-file.sh [FICHIER_XML] [--force]"
    exit 1
fi

# Valider le fichier XML
if ! validate_xml "$XML_FILE"; then
    exit 1
fi

# Parser le XML une fois
if ! parse_xml_file "$XML_FILE"; then
    exit 1
fi

PROJECT_DIR=$(basename "$(dirname "$XML_FILE")")
TICKET_ID=$(basename "$XML_FILE" .xml)
DESCRIPTION=$(extract_description "$XML_FILE" 20)

log_info "Informations extraites :"
log_info "   Projet : $PROJECT_DIR"
log_info "   Ticket : $KEY"
log_info "   Titre : $TITLE"
echo ""

# Extraire le numéro du ticket dès le début (nécessaire pour plusieurs usages)
TICKET_NUMBER=$(get_ticket_number "$KEY")

# Vérifier si le ticket a déjà été traité (via historique)
if is_ticket_processed "$KEY"; then
    existing_info=$(get_treatment_info "$KEY")
    existing_dir=$(echo "$existing_info" | cut -d'|' -f1)
    existing_date=$(echo "$existing_info" | cut -d'|' -f2)
    
    log_warning "Le ticket $KEY a déjà été traité le $existing_date"
    log_info "   Dossier existant : $existing_dir"
    
    if [ -d "$existing_dir" ] && [ -f "$existing_dir/README.md" ]; then
        log_info "   Le dossier existe toujours et contient de la documentation"
        
        if [ "$FORCE_REGENERATE" = true ]; then
            log_warning "   Mode --force activé : régénération forcée"
            US_DIR="$existing_dir"
        elif [ "$DRY_RUN" != "true" ]; then
            read -p "Voulez-vous régénérer la documentation ? (o/N) " -n 1 -r
            echo
            if [[ ! $REPLY =~ ^[Oo]$ ]]; then
                log_info "Utilisation du dossier existant : $existing_dir"
                US_DIR="$existing_dir"
            else
                # Continuer avec la régénération
                US_DIR="$existing_dir"
            fi
        else
            log_info "DRY-RUN : Le dossier $existing_dir serait utilisé"
            US_DIR="$existing_dir"
        fi
    else
        log_warning "   Le dossier enregistré n'existe plus, création d'un nouveau dossier"
        # Continuer avec la création d'un nouveau dossier
        US_DIR=""
    fi
else
    US_DIR=""
fi

# Créer la structure de dossiers si nécessaire
if [ -z "$US_DIR" ]; then
    # Structure simplifiée : projets/PROJECT/us-XXXX (sans sous-dossiers)
    # TICKET_NUMBER est déjà défini plus haut
    US_DIR="$PROJETS_DIR/$PROJECT_DIR/us-$TICKET_NUMBER"
    
    # Vérifier les permissions d'écriture
    if ! check_write_permissions "$PROJETS_DIR"; then
        exit 1
    fi
    
    if [ -d "$US_DIR" ]; then
        log_warning "Le dossier $US_DIR existe déjà"
        
        # Vérifier s'il y a déjà des fichiers de documentation
        if [ -f "$US_DIR/README.md" ] || [ -f "$US_DIR/01-questions-clarifications.md" ]; then
            log_warning "Des fichiers de documentation existent déjà dans ce dossier"
            log_info "   Pour éviter d'écraser, le script va créer un nouveau dossier ou demander confirmation"
        fi
        
        if [ "$DRY_RUN" != "true" ]; then
            read -p "Voulez-vous continuer et écraser ? (o/N) " -n 1 -r
            echo
            if [[ ! $REPLY =~ ^[Oo]$ ]]; then
                log_error "Abandonné"
                exit 1
            fi
        else
            log_info "DRY-RUN : Le dossier serait écrasé"
        fi
    fi
    
    if [ "$DRY_RUN" != "true" ]; then
        if ! safe_mkdir "$US_DIR"; then
            exit 1
        fi
    else
        log_info "DRY-RUN : Le répertoire $US_DIR serait créé"
    fi
    
    log_success "Structure créée : $US_DIR"
    echo ""
fi

if [ "$DRY_RUN" = "true" ]; then
    log_info "DRY-RUN : Les fichiers suivants seraient créés :"
    log_info "  - $US_DIR/extraction-jira.md"
    log_info "  - $US_DIR/README.md"
    log_info "  - $US_DIR/01-questions-clarifications.md"
    log_info "  - $US_DIR/02-strategie-test.md"
    log_info "  - $US_DIR/03-cas-test.md"
    exit 0
fi

# Créer un fichier d'extraction structuré avec toutes les données extraites
EXTRACTION_FILE="$US_DIR/extraction-jira.md"

# Extraire toutes les informations supplémentaires
STATUS=$(extract_status "$XML_FILE" 2>/dev/null || echo "")
TYPE=$(extract_type "$XML_FILE" 2>/dev/null || echo "Story")
PRIORITY=$(extract_priority "$XML_FILE" 2>/dev/null || echo "")

# Extraire les critères d'acceptation
ACCEPTANCE_CRITERIA=$(extract_acceptance_criteria "$XML_FILE" 2>/dev/null || echo "")

# Extraire les liens Figma et Miro
FIGMA_LINKS=$(extract_figma_links "$XML_FILE" 2>/dev/null || echo "")
MIRO_LINKS=$(extract_miro_links "$XML_FILE" 2>/dev/null || echo "")

# Extraire les commentaires formatés
COMMENTS=$(extract_comments_formatted "$XML_FILE" 10 2>/dev/null || echo "")

# Extraire la description décodée pour la User Story
DESCRIPTION_DECODED=$(decode_html_cached "$DESCRIPTION_SECTION" 2>/dev/null || echo "$DESCRIPTION_SECTION")
USER_STORY_SECTION=$(echo "$DESCRIPTION_DECODED" | awk '/USER STORY/i {found=1} found {print} /^<h[12]>/ && found && !/USER STORY/i {exit}' | head -50)

cat > "$EXTRACTION_FILE" <<EOF
# Extraction Jira - $KEY

## 📋 Informations générales

**Clé du ticket** : $KEY
**Titre/Summary** : $TITLE
**Type** : ${TYPE:-Story}
**Statut** : ${STATUS:-[Non disponible]}
**Priorité** : ${PRIORITY:-[Non disponible]}
**Lien Jira** : $LINK

## 📝 Description / User Story

$(if [ -n "$USER_STORY_SECTION" ]; then
    echo "$USER_STORY_SECTION" | sed 's/<[^>]*>//g' | sed 's/&[^;]*;//g' | head -30
else
    echo "$DESCRIPTION_DECODED" | sed 's/<[^>]*>//g' | sed 's/&[^;]*;//g' | head -30
fi)

> **Note** : Description complète disponible dans le fichier XML : \`../Jira/$PROJECT_DIR/$TICKET_ID.xml\`

## ✅ Critères d'acceptation

$(if [ -n "$ACCEPTANCE_CRITERIA" ]; then
    echo "$ACCEPTANCE_CRITERIA" | while IFS='|' read -r ac_num title given when then_clause; do
        if [ -n "$ac_num" ] && [ -n "$title" ]; then
            echo "### $ac_num - $title"
            [ -n "$given" ] && echo "**Étant donné que** : $given"
            [ -n "$when" ] && echo "**Lorsque** : $when"
            [ -n "$then_clause" ] && echo "**Alors** : $then_clause"
            echo ""
        fi
    done
else
    echo "*Aucun critère d'acceptation trouvé dans le XML*"
fi)

## 💻 Informations techniques

$(if echo "$DESCRIPTION_DECODED" | grep -qi "SPECS TECHNIQUES\|SPECS\|Technical"; then
    echo "$DESCRIPTION_DECODED" | awk '/SPECS TECHNIQUES/i || /SPECS/i || /Technical/i {found=1} found {print} /^<h[12]>/ && found && !/SPECS/i && !/Technical/i && !/Acceptance/i {exit}' | sed 's/<[^>]*>//g' | sed 's/&[^;]*;//g' | grep -v "^$" | head -30
else
    echo "*Aucune information technique trouvée dans la description*"
fi)

## 🎨 Designs

$(if [ -n "$FIGMA_LINKS" ]; then
    echo "### Liens Figma"
    echo "$FIGMA_LINKS" | while read -r link; do
        echo "- $link"
    done
    echo ""
fi)

$(if [ -n "$MIRO_LINKS" ]; then
    echo "### Liens Miro (Event Modeling)"
    echo "$MIRO_LINKS" | while read -r link; do
        echo "- $link"
    done
    echo ""
fi)

$(if [ -z "$FIGMA_LINKS" ] && [ -z "$MIRO_LINKS" ]; then
    echo "*Aucun lien de design trouvé dans la description*"
fi)

## 📝 Commentaires de l'équipe

$(if [ -n "$COMMENTS" ]; then
    echo "$COMMENTS"
else
    echo "*Aucun commentaire trouvé dans le XML*"
fi)

---

**Date d'extraction** : $(date +"%Y-%m-%d")
**Fichier source** : Jira/$PROJECT_DIR/$TICKET_ID.xml
EOF

log_success "Fichier d'extraction créé : extraction-jira.md"
echo ""

# Créer le README de l'US
if ! validate_file "$TEMPLATES_DIR/us-readme-template.md"; then
    exit 1
fi

cp "$TEMPLATES_DIR/us-readme-template.md" "$US_DIR/README.md"

# Remplacer les placeholders dans le README (compatible macOS)
# Utiliser la fonction centralisée pour l'échappement
TITLE_ESCAPED=$(escape_for_sed "$TITLE")
KEY_ESCAPED=$(escape_for_sed "$KEY")
PROJECT_DIR_ESCAPED=$(escape_for_sed "$PROJECT_DIR")
LINK_ESCAPED=$(escape_for_sed "$LINK")

sed -i '' "s|\[US-XXX\]|$KEY_ESCAPED|g" "$US_DIR/README.md"
sed -i '' "s|\[Nom de la User Story\]|$TITLE_ESCAPED|g" "$US_DIR/README.md"
sed -i '' "s|\[NOM_PROJET\]|$PROJECT_DIR_ESCAPED|g" "$US_DIR/README.md"
sed -i '' "s|\[NUMBER\]|$TICKET_NUMBER|g" "$US_DIR/README.md"
sed -i '' "s|\[URL du ticket\]|$LINK_ESCAPED|g" "$US_DIR/README.md"
sed -i '' "s|\[AAAA-MM-JJ\]|$(date +"%Y-%m-%d")|g" "$US_DIR/README.md"

log_success "README.md créé"
echo ""

# Créer les 3 fichiers de documentation avec liens vers le fichier d'extraction
log_info "Création des fichiers de documentation..."
echo ""

# 1. Questions et Clarifications - Générer avec Cursor IA (priorité)
log_info "Génération des questions de clarifications avec Cursor IA..."
log_info "   Préparation du prompt détaillé pour l'agent Cursor..."
if "$GENERATE_WITH_CURSOR_SCRIPT" "questions" "$US_DIR" 2>/dev/null; then
    log_success "✅ Prompt préparé pour génération avec Cursor IA"
    log_info "   👉 Copiez le prompt affiché ci-dessus et donnez-le à l'agent Cursor pour génération"
    log_info "   💾 Le document sera sauvegardé dans : $US_DIR/01-questions-clarifications.md"
else
    log_warning "⚠️  Erreur avec la préparation du prompt Cursor, basculement vers méthode classique..."
    "$GENERATE_QUESTIONS_SCRIPT" "$US_DIR" || {
        log_error "Erreur lors de la génération des questions"
        exit 1
    }
fi
echo ""

# 2. Stratégie de Test - Générer avec Cursor IA (priorité)
log_info "Génération de la stratégie de test avec Cursor IA..."
log_info "   Préparation du prompt détaillé pour l'agent Cursor..."
if "$GENERATE_WITH_CURSOR_SCRIPT" "strategy" "$US_DIR" 2>/dev/null; then
    log_success "✅ Prompt préparé pour génération avec Cursor IA"
    log_info "   👉 Copiez le prompt affiché ci-dessus et donnez-le à l'agent Cursor pour génération"
    log_info "   💾 Le document sera sauvegardé dans : $US_DIR/02-strategie-test.md"
else
    log_warning "⚠️  Erreur avec la préparation du prompt Cursor, basculement vers méthode classique..."
    "$GENERATE_STRATEGY_SCRIPT" "$US_DIR" || {
        log_error "Erreur lors de la génération de la stratégie"
        exit 1
    }
fi
echo ""

# 3. Cas de Test - Générer avec Cursor IA (priorité)
log_info "Génération des cas de test avec Cursor IA..."
log_info "   Préparation du prompt détaillé pour l'agent Cursor..."
if "$GENERATE_WITH_CURSOR_SCRIPT" "test-cases" "$US_DIR" 2>/dev/null; then
    log_success "✅ Prompt préparé pour génération avec Cursor IA"
    log_info "   👉 Copiez le prompt affiché ci-dessus et donnez-le à l'agent Cursor pour génération"
    log_info "   💾 Le document sera sauvegardé dans : $US_DIR/03-cas-test.md"
else
    log_warning "⚠️  Erreur avec la préparation du prompt Cursor, basculement vers méthode classique..."
    "$GENERATE_TEST_CASES_SCRIPT" "$US_DIR" || {
        log_error "Erreur lors de la génération des cas de test"
        exit 1
    }
fi
echo ""

# Mettre à jour le README avec les informations extraites
log_info "Mise à jour du README avec les informations extraites..."
"$UPDATE_README_SCRIPT" "$US_DIR" || {
    log_warning "Erreur lors de la mise à jour du README (non bloquant)"
}
echo ""

log_success "Tous les fichiers de documentation créés"
echo ""

# Enregistrer le traitement dans l'historique
if [ "$DRY_RUN" != "true" ]; then
    record_treatment "$KEY" "$US_DIR"
fi

log_success "Traitement terminé pour $KEY"
echo ""
echo "📁 Fichiers créés dans : $US_DIR"
echo "   - README.md (vue d'ensemble)"
echo "   - extraction-jira.md (✅ généré automatiquement avec toutes les données extraites)"
echo "   - 01-questions-clarifications.md (🤖 prompts Cursor IA préparés - à générer)"
echo "   - 02-strategie-test.md (🤖 prompts Cursor IA préparés - à générer)"
echo "   - 03-cas-test.md (🤖 prompts Cursor IA préparés - à générer)"
echo ""
echo "🔗 Prochaines étapes :"
echo "   1. 📋 Les prompts Cursor IA sont affichés ci-dessus"
echo "   2. 🤖 Copiez chaque prompt et donnez-le à l'agent Cursor (moi) pour génération"
echo "   3. 💾 Sauvegardez les documents générés dans les fichiers correspondants"
echo "   4. ✅ Vérifiez et validez les documents générés"
echo ""
echo "💡 ASTUCE : Utilisez './scripts/generate-with-cursor-direct.sh all $US_DIR'"
echo "   pour afficher tous les prompts de manière encore plus claire"
echo ""

