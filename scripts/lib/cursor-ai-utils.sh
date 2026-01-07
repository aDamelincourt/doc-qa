#!/bin/bash

# Bibliothèque pour utiliser l'agent IA intégré de Cursor
# Usage: source "$(dirname "${BASH_SOURCE[0]}")/lib/cursor-ai-utils.sh"

# Charger la configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
if [ -f "$SCRIPT_DIR/config.sh" ]; then
    source "$SCRIPT_DIR/config.sh"
fi

# Préparer un prompt optimisé pour l'agent Cursor
prepare_cursor_prompt() {
    local document_type="$1"  # questions, strategy, test-cases
    local context_data="$2"   # Données extraites du XML
    local template_file="$3"  # Fichier template
    local output_file="$4"    # Fichier de sortie pour le prompt
    
    if [ ! -f "$template_file" ]; then
        log_error "Template introuvable : $template_file"
        return 1
    fi
    
    local template_content=$(cat "$template_file")
    
    # Construire le prompt selon le type de document
    local instructions=""
    
    case "$document_type" in
        questions)
            instructions="Génère un document complet de questions et clarifications au format Markdown.

INSTRUCTIONS :
- Génère le MAXIMUM de questions pertinentes (minimum 30-40 questions)
- Organise les questions par catégorie (PM, Dev, Designer, etc.)
- Pour chaque question, fournis le contexte expliquant pourquoi elle est importante
- Identifie les ambiguïtés dans les critères d'acceptation
- Propose des questions sur les cas limites non couverts
- Inclus des questions sur les données de test, les environnements, les dépendances
- Utilise le format du template fourni
- Sois exhaustif et créatif dans l'identification des points à clarifier"
            ;;
        strategy)
            instructions="Génère une stratégie de test complète au format Markdown.

INSTRUCTIONS :
- Identifie TOUS les axes de test pertinents pour cette fonctionnalité
- Définis une stratégie adaptée au contexte métier et technique
- Inclus les tests fonctionnels, non-fonctionnels, d'intégration, de sécurité, de performance
- Précise les prérequis, environnements, données de test nécessaires
- Identifie les risques et les priorités de test
- Propose un plan de test structuré
- Utilise le format du template fourni
- Sois exhaustif et adapte la stratégie au contexte spécifique de cette US"
            ;;
        test-cases)
            instructions="Génère un document complet de cas de test au format Markdown.

INSTRUCTIONS :
- Génère le MAXIMUM de cas de test pertinents (minimum 15-20 scénarios)
- Pour chaque scénario, fournis :
  * Un titre clair et descriptif
  * Des étapes détaillées et actionnables
  * Des données de test précises et réalistes
  * Des résultats attendus détaillés avec vérifications spécifiques
- Organise par catégories : Nominaux, Limites, Erreurs, Performance, Intégration, Sécurité, Compatibilité
- Identifie les edge cases et cas limites non évidents
- Génère des scénarios de régression si pertinent
- Adapte les cas de test au contexte métier spécifique
- Utilise le format du template fourni
- Sois exhaustif et créatif dans l'identification des scénarios de test"
            ;;
        *)
            log_error "Type de document non supporté : $document_type"
            return 1
            ;;
    esac
    
    # Créer le prompt complet
    cat > "$output_file" <<EOF
# Prompt pour génération $document_type avec l'agent Cursor

## Contexte de la User Story

$context_data

## Template à suivre

\`\`\`markdown
$template_content
\`\`\`

## Instructions

$instructions

## Tâche

Génère le contenu complet au format Markdown en suivant le template et les instructions ci-dessus.
Le contenu doit être exhaustif, adapté au contexte, et directement utilisable.
EOF

    log_success "✅ Prompt préparé : $output_file"
    log_info "   Copiez le contenu et demandez à l'agent Cursor de générer le document"
}

# Générer directement avec l'agent Cursor (via fichier de prompt)
generate_with_cursor_agent() {
    local document_type="$1"
    local context_data="$2"
    local template_file="$3"
    local output_file="$4"
    
    # Créer un fichier de prompt temporaire
    local prompt_file=$(mktemp)
    prepare_cursor_prompt "$document_type" "$context_data" "$template_file" "$prompt_file"
    
    if [ $? -ne 0 ]; then
        rm -f "$prompt_file"
        return 1
    fi
    
    log_info "📋 Fichier de prompt créé : $prompt_file"
    log_info ""
    log_info "🤖 Pour générer avec l'agent Cursor :"
    log_info "   1. Ouvrez le fichier : $prompt_file"
    log_info "   2. Copiez tout le contenu"
    log_info "   3. Dans Cursor, demandez à l'agent :"
    log_info "      'Génère le document $document_type en suivant ce prompt : [coller le contenu]'"
    log_info "   4. L'agent générera le contenu que vous pourrez sauvegarder dans : $output_file"
    log_info ""
    log_info "   OU utilisez le script interactif :"
    log_info "   ./scripts/generate-with-cursor.sh $document_type [US_DIR]"
    
    echo "$prompt_file"
}

