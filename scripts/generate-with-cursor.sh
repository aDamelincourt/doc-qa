#!/bin/bash

# Script interactif pour générer avec l'agent Cursor
# Usage: ./scripts/generate-with-cursor.sh [questions|strategy|test-cases] [US_DIR]

set -euo pipefail

# Charger les bibliothèques communes
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LIB_DIR="$SCRIPT_DIR/lib"
source "$LIB_DIR/config.sh"
source "$LIB_DIR/common-functions.sh"
source "$LIB_DIR/xml-utils.sh"
source "$LIB_DIR/ticket-utils.sh"
source "$LIB_DIR/cursor-ai-utils.sh"

if [ -z "${1:-}" ] || [ -z "${2:-}" ]; then
    log_error "Arguments requis"
    echo "Usage: ./scripts/generate-with-cursor.sh [questions|strategy|test-cases] [US_DIR]"
    echo "Exemple: ./scripts/generate-with-cursor.sh questions projets/ACCOUNT/us-3239"
    exit 1
fi

DOCUMENT_TYPE="$1"
US_DIR="$2"

if [ ! -d "$US_DIR" ]; then
    log_error "Dossier introuvable : $US_DIR"
    exit 1
fi

# Trouver le fichier XML correspondant
EXTRACTION_FILE="$US_DIR/extraction-jira.md"
if ! validate_file "$EXTRACTION_FILE"; then
    exit 1
fi

# Extraire le ticket ID
TICKET_KEY=$(get_ticket_key_from_path "$US_DIR")
if [ -z "$TICKET_KEY" ]; then
    log_error "Impossible d'extraire la clé du ticket"
    exit 1
fi

# Trouver le fichier XML
XML_FILE=$(get_xml_file_from_key "$TICKET_KEY")
if ! validate_xml "$XML_FILE"; then
    exit 1
fi

log_info "📋 Préparation pour génération avec agent Cursor..."
log_info "   Type : $DOCUMENT_TYPE"
log_info "   Ticket : $TICKET_KEY"
echo ""

# Préparer le contexte riche pour l'IA
CONTEXT=$(prepare_context_for_ai "$XML_FILE" "$US_DIR")
if [ $? -ne 0 ]; then
    log_error "Erreur lors de la préparation du contexte"
    exit 1
fi

# Déterminer le template et le fichier de sortie
case "$DOCUMENT_TYPE" in
    questions)
        TEMPLATE_FILE="$TEMPLATES_DIR/questions-clarifications-template.md"
        OUTPUT_FILE="$US_DIR/01-questions-clarifications.md"
        ;;
    strategy)
        TEMPLATE_FILE="$TEMPLATES_DIR/strategie-test-template.md"
        OUTPUT_FILE="$US_DIR/02-strategie-test.md"
        ;;
    test-cases)
        TEMPLATE_FILE="$TEMPLATES_DIR/cas-test-template.md"
        OUTPUT_FILE="$US_DIR/03-cas-test.md"
        ;;
    *)
        log_error "Type de document invalide : $DOCUMENT_TYPE"
        log_info "   Types valides : questions, strategy, test-cases"
        exit 1
        ;;
esac

if [ ! -f "$TEMPLATE_FILE" ]; then
    log_error "Template introuvable : $TEMPLATE_FILE"
    exit 1
fi

# Créer le prompt
PROMPT_FILE=$(generate_with_cursor_agent "$DOCUMENT_TYPE" "$CONTEXT" "$TEMPLATE_FILE" "$OUTPUT_FILE")

if [ $? -ne 0 ]; then
    log_error "Erreur lors de la création du prompt"
    exit 1
fi

echo ""
log_info "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
log_info "📝 PROMPT PRÊT POUR L'AGENT CURSOR IA"
log_info "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
log_info "📄 Fichier de prompt : $PROMPT_FILE"
log_info "💾 Fichier de sortie : $OUTPUT_FILE"
echo ""
log_info "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
log_info "📋 CONTENU DU PROMPT (à copier ci-dessous)"
log_info "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
cat "$PROMPT_FILE"
echo ""
log_info "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
log_info "👉 INSTRUCTIONS POUR UTILISER CE PROMPT :"
log_info "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
log_info "1. Le prompt complet est affiché ci-dessus"
log_info "2. Copiez TOUT le contenu du prompt (depuis '## 🎯 OBJECTIF' jusqu'à la fin)"
log_info "3. Dans cette conversation avec l'agent Cursor (moi), dites :"
echo ""
log_info "   'Génère le document $DOCUMENT_TYPE en suivant exactement ce prompt :"
echo ""
log_info "   [collez ici TOUT le contenu du prompt ci-dessus]'"
echo ""
log_info "4. L'agent Cursor générera le contenu Markdown COMPLET et DÉTAILLÉ"
log_info "5. Copiez le résultat généré et sauvegardez-le dans : $OUTPUT_FILE"
echo ""
log_info "💡 ASTUCE : Vous pouvez aussi utiliser le script :"
log_info "   ./scripts/generate-with-cursor-direct.sh $DOCUMENT_TYPE $US_DIR"
log_info "   pour afficher le prompt de manière encore plus claire"
echo ""
log_info "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

