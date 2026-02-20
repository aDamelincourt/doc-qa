#!/bin/bash

# Bibliothèque pour utiliser l'agent IA intégré de Cursor
# Usage: source "$(dirname "${BASH_SOURCE[0]}")/lib/cursor-ai-utils.sh"

# Charger la configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
if [ -f "$SCRIPT_DIR/config.sh" ]; then
    source "$SCRIPT_DIR/config.sh"
fi

# Charger les autres bibliothèques nécessaires
if [ -f "$SCRIPT_DIR/common-functions.sh" ]; then
    source "$SCRIPT_DIR/common-functions.sh"
fi
if [ -f "$SCRIPT_DIR/xml-utils.sh" ]; then
    source "$SCRIPT_DIR/xml-utils.sh"
fi
if [ -f "$SCRIPT_DIR/acceptance-criteria-utils.sh" ]; then
    source "$SCRIPT_DIR/acceptance-criteria-utils.sh"
fi

# Préparer un contexte riche pour l'IA à partir du dossier US.
# Supporte 2 modes :
#   1. Mode API : lit directement extraction-jira.md (produit par le CLI Jira)
#   2. Mode XML (legacy) : parse le XML et construit le contexte
#
# Usage:
#   prepare_context_for_ai "/path/to/us-dir"                     (mode auto)
#   prepare_context_for_ai "/path/to/file.xml" "/path/to/us-dir" (mode legacy)
prepare_context_for_ai() {
    local arg1="$1"
    local arg2="${2:-}"
    local xml_file=""
    local us_dir=""

    # Détecter le mode d'appel (rétro-compatible)
    if [ -n "$arg2" ]; then
        # Mode legacy : prepare_context_for_ai XML_FILE US_DIR
        xml_file="$arg1"
        us_dir="$arg2"
    else
        # Mode nouveau : prepare_context_for_ai US_DIR
        us_dir="$arg1"
    fi

    if [ ! -d "$us_dir" ]; then
        log_error "Dossier US introuvable : $us_dir"
        return 1
    fi

    local extraction_file="$us_dir/extraction-jira.md"

    # ─── Mode API : extraction-jira.md existe et est riche (produit par le CLI) ───
    # On détecte un fichier API par la présence du header "# TICKET-ID: ..."
    if [ -f "$extraction_file" ] && head -1 "$extraction_file" | grep -qE '^# [A-Z]+-[0-9]+:'; then
        log_info "Utilisation du contexte API (extraction-jira.md)"
        cat "$extraction_file"
        return 0
    fi

    # ─── Mode XML (legacy) : parser le fichier XML ───────────────────────────
    if [ -z "$xml_file" ]; then
        # Tenter de trouver le XML correspondant
        local ticket_key
        ticket_key=$(get_ticket_key_from_path "$us_dir" 2>/dev/null || echo "")
        if [ -n "$ticket_key" ]; then
            xml_file=$(get_xml_file_from_key "$ticket_key" 2>/dev/null || echo "")
        fi
    fi

    if [ -z "$xml_file" ] || [ ! -f "$xml_file" ]; then
        # Dernier recours : utiliser extraction-jira.md tel quel
        if [ -f "$extraction_file" ]; then
            log_info "Utilisation du fichier extraction-jira.md existant"
            cat "$extraction_file"
            return 0
        fi
        log_error "Aucune source de contexte trouvée (ni API, ni XML, ni extraction-jira.md)"
        return 1
    fi

    # Parser le XML
    if ! parse_xml_file "$xml_file"; then
        return 1
    fi

    local extraction_content=""
    if [ -f "$extraction_file" ]; then
        extraction_content=$(cat "$extraction_file")
    fi

    local acceptance_criteria=$(extract_acceptance_criteria "$xml_file" 2>/dev/null || echo "")
    local comments=$(extract_comments "$xml_file" 200 2>/dev/null || echo "")
    local comments_decoded=$(decode_html_cached "$comments" 2>/dev/null || echo "$comments")
    local description_decoded=$(decode_html_cached "$DESCRIPTION_SECTION" 2>/dev/null || echo "$DESCRIPTION_SECTION")
    local figma_links=$(extract_figma_links "$xml_file" 2>/dev/null || echo "")
    local miro_links=$(extract_miro_links "$xml_file" 2>/dev/null || echo "")
    local status=$(extract_status "$xml_file" 2>/dev/null || echo "")
    local type=$(extract_type "$xml_file" 2>/dev/null || echo "")
    local priority=$(extract_priority "$xml_file" 2>/dev/null || echo "")

    cat <<EOF
# Contexte complet de la User Story

## Informations générales du ticket

- **Clé du ticket** : $KEY
- **Titre** : $TITLE
- **Type** : ${type:-Story}
- **Statut** : ${status:-Non disponible}
- **Priorité** : ${priority:-Non disponible}
- **Lien Jira** : $LINK
- **Projet** : $PROJECT_NAME

## Description complète / User Story

$description_decoded

## Critères d'acceptation

$(if [ -n "$acceptance_criteria" ]; then
    echo "$acceptance_criteria" | while IFS='|' read -r ac_num title given when then_clause; do
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

## Commentaires de l'équipe

$(if [ -n "$comments_decoded" ]; then
    echo "$comments_decoded" | head -100
else
    echo "*Aucun commentaire trouvé*"
fi)

## Liens de design

$(if [ -n "$figma_links" ]; then
    echo "### Liens Figma"
    echo "$figma_links" | while read -r link; do
        [ -n "$link" ] && echo "- $link"
    done
    echo ""
fi)

$(if [ -n "$miro_links" ]; then
    echo "### Liens Miro (Event Modeling)"
    echo "$miro_links" | while read -r link; do
        [ -n "$link" ] && echo "- $link"
    done
    echo ""
fi)

## Extraction Jira complète

$(if [ -n "$extraction_content" ]; then
    echo "$extraction_content"
else
    echo "*Fichier extraction-jira.md non disponible*"
fi)

EOF
}

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
    
    # Charger les instructions depuis les fichiers de prompts externes
    local prompt_dir="$TEMPLATES_DIR/prompts"
    local prompt_file="$prompt_dir/${document_type}.md"

    if [ ! -f "$prompt_file" ]; then
        log_error "Type de document non supporté : $document_type (prompt introuvable : $prompt_file)"
        return 1
    fi

    local instructions
    instructions=$(cat "$prompt_file")
    
    # Créer le prompt complet et détaillé
    cat > "$output_file" <<EOF
# Prompt pour génération $document_type avec l'agent Cursor IA

## 🎯 OBJECTIF

Génère un document QA COMPLET, EXHAUSTIF et DÉTAILLÉ au format Markdown pour la User Story suivante.
Le document doit être directement utilisable par une équipe QA sans modification supplémentaire.

## 📋 CONTEXTE COMPLET DE LA USER STORY

$context_data

## 📝 TEMPLATE À SUIVRE EXACTEMENT

\`\`\`markdown
$template_content
\`\`\`

## 🎓 INSTRUCTIONS DÉTAILLÉES

$instructions

## ✅ CRITÈRES DE QUALITÉ

Le document généré doit respecter les critères suivants :

1. **Exhaustivité** : Couvre TOUS les aspects pertinents de la fonctionnalité
2. **Détail** : Chaque section est détaillée avec des exemples concrets
3. **Actionnabilité** : Le contenu est directement utilisable sans interprétation
4. **Contexte** : Adapté au contexte métier et technique spécifique
5. **Complétude** : Aucune section du template n'est laissée vide ou générique
6. **Précision** : Utilise la terminologie exacte du projet et du domaine

## 🚀 TÂCHE

Génère le contenu COMPLET au format Markdown en suivant EXACTEMENT le template et les instructions ci-dessus.
Le contenu doit être :
- Exhaustif (maximum de détails)
- Adapté au contexte spécifique de cette US
- Directement utilisable par l'équipe QA
- Formaté correctement en Markdown
- Prêt à être sauvegardé dans le fichier de sortie

## 📌 NOTES IMPORTANTES

- Analyse en profondeur le contexte fourni
- Identifie TOUS les aspects à couvrir
- Génère le MAXIMUM de contenu pertinent
- Sois créatif dans l'identification des points à traiter
- Adapte chaque section au contexte spécifique
- Fournis des exemples concrets et réalistes
EOF

    log_success "✅ Prompt préparé : $output_file"
    log_info "   Copiez le contenu et demandez à l'agent Cursor de générer le document"
}

# Vérifie si le fichier contient du vrai Markdown QA (et non l'écran de connexion/erreur du CLI).
# Retourne 0 si valide, 1 si invalide (garbage).
# Le CLI Cursor en mode non-interactif peut écrire "Press any key to sign in..." ou de l'ASCII art.
is_valid_qa_markdown_output() {
    local file="$1"
    [ ! -f "$file" ] || [ ! -s "$file" ] && return 1
    # Indices de sortie invalide (écran de connexion, TUI, erreur)
    if grep -q "Press any key to sign in" "$file" 2>/dev/null; then return 1; fi
    if grep -q "Cursor Agent" "$file" 2>/dev/null; then return 1; fi
    if grep -q "Sign in" "$file" 2>/dev/null && ! grep -q "## " "$file" 2>/dev/null; then return 1; fi
    # Doit ressembler à du Markdown (titres ou listes)
    if head -50 "$file" | grep -qE '^(#+ |## |\- \*\*|\* )'; then
        return 0
    fi
    # Au moins une section markdown
    if grep -q "## " "$file" 2>/dev/null; then return 0; fi
    return 1
}

# Générer directement avec l'agent Cursor (via CLI ou prompt)
# Usage: generate_with_cursor_agent "questions" "$context" "$template" "$output"
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

    # Option 3 : Mode mixte — tenter CLI d'abord, puis fallback prompt
    local cursor_cmd=""
    if command -v cursor-agent &> /dev/null; then
        cursor_cmd="cursor-agent"
    elif command -v cursor &> /dev/null; then
        cursor_cmd="cursor"
    fi

    if [ -n "$cursor_cmd" ]; then
        if [ -z "${CURSOR_API_KEY:-}" ]; then
            log_warning "Pour utiliser l'IA Cursor automatiquement, définir CURSOR_API_KEY (voir docs/INSTALLATION-CURSOR-CLI.md). Génération depuis le contexte (extraction-jira.md)."
            rm -f "$prompt_file"
            return 1
        fi

        log_info "🤖 Option 3 (mixte) : utilisation du CLI Cursor pour génération directe..."

        local prompt_content=$(cat "$prompt_file")
        local cursor_full_cmd="$cursor_cmd -p --force --api-key $CURSOR_API_KEY"

        log_info "   Génération en cours avec Cursor CLI..."
        if echo "$prompt_content" | $cursor_full_cmd > "$output_file" 2>&1; then
            if is_valid_qa_markdown_output "$output_file"; then
                log_success "✅ Document généré directement avec Cursor CLI : $output_file"
                rm -f "$prompt_file"
                return 0
            fi
            # Sortie invalide (écran de connexion / erreur écrit dans le fichier)
            rm -f "$output_file"
            log_warning "⚠️  Sortie Cursor CLI invalide (écran de connexion ou erreur), bascule vers génération depuis le contexte."
            rm -f "$prompt_file"
            return 1
        else
            log_warning "⚠️  Erreur avec Cursor CLI, bascule vers mode prompt (fallback)..."
        fi
    fi

    # Fallback : mode prompt (pour traitement manuel ou via agent dans conversation)
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

# Générer directement un document avec l'agent Cursor (voie principale).
# Supporte contexte API (extraction-jira.md) ET XML (legacy).
# Usage: generate_document_directly "questions" "$us_dir"
generate_document_directly() {
    local document_type="$1"
    local us_dir="$2"

    if [ ! -d "$us_dir" ]; then
        log_error "Dossier introuvable : $us_dir"
        return 1
    fi

    # Préparer le contexte (mode auto : API ou XML)
    local context
    context=$(prepare_context_for_ai "$us_dir")
    if [ $? -ne 0 ] || [ -z "$context" ]; then
        log_error "Erreur lors de la préparation du contexte"
        return 1
    fi

    # Déterminer le template et le fichier de sortie
    local template_file=""
    local output_file=""

    case "$document_type" in
        questions)
            template_file="$TEMPLATES_DIR/questions-clarifications-template.md"
            output_file="$us_dir/01-questions-clarifications.md"
            ;;
        strategy)
            template_file="$TEMPLATES_DIR/strategie-test-template.md"
            output_file="$us_dir/02-strategie-test.md"
            ;;
        test-cases)
            template_file="$TEMPLATES_DIR/cas-test-template.md"
            output_file="$us_dir/03-cas-test.md"
            ;;
        *)
            log_error "Type de document invalide : $document_type"
            return 1
            ;;
    esac

    if [ ! -f "$template_file" ]; then
        log_error "Template introuvable : $template_file"
        return 1
    fi

    # Générer avec l'agent Cursor
    generate_with_cursor_agent "$document_type" "$context" "$template_file" "$output_file"
}