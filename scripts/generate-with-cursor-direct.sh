#!/bin/bash

# Script pour générer DIRECTEMENT les documents avec l'agent Cursor IA
# Ce script prépare les prompts et les affiche pour que l'utilisateur puisse
# les donner directement à l'agent Cursor (moi) pour génération
# Usage: ./scripts/generate-with-cursor-direct.sh [questions|strategy|test-cases|all] [US_DIR]

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
    echo "Usage: ./scripts/generate-with-cursor-direct.sh [questions|strategy|test-cases|all] [US_DIR]"
    echo "Exemple: ./scripts/generate-with-cursor-direct.sh all projets/ACCOUNT/us-2608"
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

log_info "📋 Préparation pour génération avec agent Cursor IA..."
log_info "   Type : $DOCUMENT_TYPE"
log_info "   Ticket : $TICKET_KEY"
echo ""

# Préparer le contexte riche
CONTEXT=$(prepare_context_for_ai "$XML_FILE" "$US_DIR")
if [ $? -ne 0 ]; then
    log_error "Erreur lors de la préparation du contexte"
    exit 1
fi

# Fonction pour générer un document
generate_document() {
    local doc_type="$1"
    local template_file=""
    local output_file=""
    
    case "$doc_type" in
        questions)
            template_file="$TEMPLATES_DIR/questions-clarifications-template.md"
            output_file="$US_DIR/01-questions-clarifications.md"
            ;;
        strategy)
            template_file="$TEMPLATES_DIR/strategie-test-template.md"
            output_file="$US_DIR/02-strategie-test.md"
            ;;
        test-cases)
            template_file="$TEMPLATES_DIR/cas-test-template.md"
            output_file="$US_DIR/03-cas-test.md"
            ;;
        *)
            log_error "Type de document invalide : $doc_type"
            return 1
            ;;
    esac
    
    if [ ! -f "$template_file" ]; then
        log_error "Template introuvable : $template_file"
        return 1
    fi
    
    # Créer le prompt
    local prompt_file=$(mktemp)
    prepare_cursor_prompt "$doc_type" "$CONTEXT" "$template_file" "$prompt_file"
    
    if [ $? -ne 0 ]; then
        rm -f "$prompt_file"
        return 1
    fi
    
    echo ""
    log_info "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    log_info "📝 PROMPT PRÊT POUR GÉNÉRATION $doc_type"
    log_info "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
    log_info "📄 Fichier de prompt : $prompt_file"
    log_info "💾 Fichier de sortie : $output_file"
    echo ""
    log_info "👉 INSTRUCTIONS POUR L'AGENT CURSOR :"
    echo ""
    log_info "Copiez le contenu suivant et donnez-le à l'agent Cursor :"
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    cat "$prompt_file"
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
    log_info "💡 L'agent Cursor générera le document complet que vous pourrez sauvegarder dans :"
    log_info "   $output_file"
    echo ""
    
    # Garder le fichier de prompt pour référence
    local saved_prompt="$US_DIR/.prompt-$doc_type-$(date +%Y%m%d-%H%M%S).md"
    cp "$prompt_file" "$saved_prompt"
    log_info "📌 Prompt sauvegardé pour référence : $saved_prompt"
    echo ""
}

# Générer selon le type demandé
case "$DOCUMENT_TYPE" in
    questions|strategy|test-cases)
        generate_document "$DOCUMENT_TYPE"
        ;;
    all)
        log_info "Génération de TOUS les documents avec Cursor IA..."
        echo ""
        generate_document "questions"
        echo ""
        generate_document "strategy"
        echo ""
        generate_document "test-cases"
        echo ""
        log_success "✅ Tous les prompts sont prêts pour génération avec Cursor IA"
        ;;
    *)
        log_error "Type invalide : $DOCUMENT_TYPE"
        log_info "   Types valides : questions, strategy, test-cases, all"
        exit 1
        ;;
esac

