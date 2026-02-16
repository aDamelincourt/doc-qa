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
source "$LIB_DIR/cursor-ai-utils.sh"

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
# Utiliser la fonction commune pour la génération
if ! generate_extraction_jira "$XML_FILE" "$US_DIR"; then
    log_error "Erreur lors de la génération du fichier d'extraction"
    exit 1
fi
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

# 1. Questions et Clarifications - Générer avec Cursor IA (voie prépondérante)
log_info "Génération des questions de clarifications avec Cursor IA (voie prépondérante)..."
if generate_document_directly "questions" "$US_DIR" 2>/dev/null; then
    if [ -f "$US_DIR/01-questions-clarifications.md" ] && [ -s "$US_DIR/01-questions-clarifications.md" ]; then
        log_success "✅ Document généré directement avec Cursor IA : $US_DIR/01-questions-clarifications.md"
    else
        log_info "📋 Prompt préparé pour génération avec Cursor IA"
        log_info "   👉 Copiez le prompt affiché ci-dessus et donnez-le à l'agent Cursor pour génération"
    fi
else
    log_warning "⚠️  Erreur avec Cursor IA, basculement vers méthode classique..."
    "$GENERATE_QUESTIONS_SCRIPT" "$US_DIR" || {
        log_error "Erreur lors de la génération des questions"
        exit 1
    }
fi
echo ""

# 2. Stratégie de Test - Générer avec Cursor IA (voie prépondérante)
log_info "Génération de la stratégie de test avec Cursor IA (voie prépondérante)..."
if generate_document_directly "strategy" "$US_DIR" 2>/dev/null; then
    if [ -f "$US_DIR/02-strategie-test.md" ] && [ -s "$US_DIR/02-strategie-test.md" ]; then
        log_success "✅ Document généré directement avec Cursor IA : $US_DIR/02-strategie-test.md"
    else
        log_info "📋 Prompt préparé pour génération avec Cursor IA"
        log_info "   👉 Copiez le prompt affiché ci-dessus et donnez-le à l'agent Cursor pour génération"
    fi
else
    log_warning "⚠️  Erreur avec Cursor IA, basculement vers méthode classique..."
    "$GENERATE_STRATEGY_SCRIPT" "$US_DIR" || {
        log_error "Erreur lors de la génération de la stratégie"
        exit 1
    }
fi
echo ""

# 3. Cas de Test - Générer avec Cursor IA (voie prépondérante)
log_info "Génération des cas de test avec Cursor IA (voie prépondérante)..."
if generate_document_directly "test-cases" "$US_DIR" 2>/dev/null; then
    if [ -f "$US_DIR/03-cas-test.md" ] && [ -s "$US_DIR/03-cas-test.md" ]; then
        log_success "✅ Document généré directement avec Cursor IA : $US_DIR/03-cas-test.md"
    else
        log_info "📋 Prompt préparé pour génération avec Cursor IA"
        log_info "   👉 Copiez le prompt affiché ci-dessus et donnez-le à l'agent Cursor pour génération"
    fi
else
    log_warning "⚠️  Erreur avec Cursor IA, basculement vers méthode classique..."
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

