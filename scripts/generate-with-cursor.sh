#!/bin/bash

# Script unifié pour générer des documents avec l'agent Cursor IA
# Usage: ./scripts/generate-with-cursor.sh [questions|strategy|test-cases|all] [US_DIR] [OPTIONS]
#
# Options:
#   --all              Générer tous les documents (équivalent à generate-all-with-cursor.sh)
#   --direct           Mode direct (affiche le prompt clairement, équivalent à generate-with-cursor-direct.sh)
#   --auto             Mode automatique (génère directement, équivalent à generate-docs-directly.sh)
#   --interactive      Mode interactif (défaut, affiche le prompt pour copier-coller)

set -euo pipefail

# Charger les bibliothèques communes
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LIB_DIR="$SCRIPT_DIR/lib"
source "$LIB_DIR/config.sh"
source "$LIB_DIR/common-functions.sh"
source "$LIB_DIR/xml-utils.sh"
source "$LIB_DIR/ticket-utils.sh"
source "$LIB_DIR/cursor-ai-utils.sh"

# Gestion des arguments
MODE="interactive"  # Par défaut : mode interactif
DOCUMENT_TYPE=""
US_DIR=""

# Parser les arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --all|--direct|--auto|--interactive)
            MODE="${1#--}"
            shift
            ;;
        questions|strategy|test-cases|all)
            DOCUMENT_TYPE="$1"
            shift
            ;;
        *)
            if [ -z "$US_DIR" ] && [ -d "$1" ]; then
                US_DIR="$1"
            else
                log_error "Argument invalide : $1"
                echo "Usage: ./scripts/generate-with-cursor.sh [questions|strategy|test-cases|all] [US_DIR] [--all|--direct|--auto|--interactive]"
                exit 1
            fi
            shift
            ;;
    esac
done

# Validation des arguments
if [ -z "$DOCUMENT_TYPE" ] || [ -z "$US_DIR" ]; then
    log_error "Arguments requis"
    echo "Usage: ./scripts/generate-with-cursor.sh [questions|strategy|test-cases|all] [US_DIR] [OPTIONS]"
    echo ""
    echo "Options:"
    echo "  --all              Générer tous les documents"
    echo "  --direct           Mode direct (affiche le prompt clairement)"
    echo "  --auto             Mode automatique (génère directement)"
    echo "  --interactive      Mode interactif (défaut)"
    echo ""
    echo "Exemples:"
    echo "  ./scripts/generate-with-cursor.sh questions projets/ACCOUNT/us-3239"
    echo "  ./scripts/generate-with-cursor.sh all projets/ACCOUNT/us-3239 --all"
    echo "  ./scripts/generate-with-cursor.sh strategy projets/ACCOUNT/us-3239 --direct"
    exit 1
fi

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

log_info "📋 Génération avec agent Cursor IA (mode: $MODE)..."
log_info "   Type : $DOCUMENT_TYPE"
log_info "   Ticket : $TICKET_KEY"
echo ""

# Préparer le contexte riche pour l'IA
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
    
    # Afficher selon le mode
    case "$MODE" in
        interactive)
            echo ""
            log_info "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
            log_info "📝 PROMPT PRÊT POUR L'AGENT CURSOR IA"
            log_info "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
            echo ""
            log_info "📄 Fichier de prompt : $prompt_file"
            log_info "💾 Fichier de sortie : $output_file"
            echo ""
            log_info "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
            log_info "📋 CONTENU DU PROMPT (à copier ci-dessous)"
            log_info "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
            echo ""
            cat "$prompt_file"
            echo ""
            log_info "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
            log_info "👉 INSTRUCTIONS POUR UTILISER CE PROMPT :"
            log_info "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
            echo ""
            log_info "1. Le prompt complet est affiché ci-dessus"
            log_info "2. Copiez TOUT le contenu du prompt (depuis '## 🎯 OBJECTIF' jusqu'à la fin)"
            log_info "3. Dans cette conversation avec l'agent Cursor (moi), dites :"
            echo ""
            log_info "   'Génère le document $doc_type en suivant exactement ce prompt :"
            echo ""
            log_info "   [collez ici TOUT le contenu du prompt ci-dessus]'"
            echo ""
            log_info "4. L'agent Cursor générera le contenu Markdown COMPLET et DÉTAILLÉ"
            log_info "5. Copiez le résultat généré et sauvegardez-le dans : $output_file"
            echo ""
            ;;
        direct)
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
            ;;
        auto)
            log_info "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
            log_info "📝 Génération directe : $doc_type"
            log_info "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
            echo ""
            
            local prompt_content=$(cat "$prompt_file")
            log_info "📄 Prompt préparé (${#prompt_content} caractères)"
            log_info "🤖 Demande à l'agent Cursor de générer le document..."
            echo ""
            
            # Afficher le prompt pour que l'agent Cursor puisse le voir
            echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
            echo "PROMPT POUR L'AGENT CURSOR :"
            echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
            echo ""
            cat "$prompt_file"
            echo ""
            echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
            echo ""
            log_info "💾 Le document généré sera sauvegardé dans : $output_file"
            echo ""
            ;;
    esac
    
    # Sauvegarder le prompt pour référence
    local saved_prompt="$US_DIR/.prompt-$doc_type-$(date +%Y%m%d-%H%M%S).md"
    cp "$prompt_file" "$saved_prompt"
    log_info "📌 Prompt sauvegardé pour référence : $saved_prompt"
    echo ""
    
    rm -f "$prompt_file"
    return 0
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
        if [ "$MODE" = "auto" ]; then
            log_info "   👉 L'agent Cursor (moi) va maintenant générer les documents directement"
        fi
        ;;
    *)
        log_error "Type invalide : $DOCUMENT_TYPE"
        log_info "   Types valides : questions, strategy, test-cases, all"
        exit 1
        ;;
esac
