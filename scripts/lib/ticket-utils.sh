#!/bin/bash

# Bibliothèque de fonctions pour la gestion des tickets
# Usage: source "$(dirname "${BASH_SOURCE[0]}")/lib/ticket-utils.sh"

# Charger les fonctions communes
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
if [ -f "$SCRIPT_DIR/common-functions.sh" ]; then
    source "$SCRIPT_DIR/common-functions.sh"
else
    echo "❌ Erreur : Impossible de charger common-functions.sh" >&2
    exit 1
fi

# Extraire le ticket ID depuis un chemin us-XXXX
# Usage: get_ticket_key_from_path "projets/SPEX/us-2990" ou "projets/ACCOUNT/spikes/us-3182"
get_ticket_key_from_path() {
    local us_dir="$1"
    local us_name=$(basename "$us_dir")
    
    # Essayer d'abord depuis extraction-jira.md (plus fiable)
    local extraction_file="$us_dir/extraction-jira.md"
    if [ -f "$extraction_file" ]; then
        local key=$(grep "^\*\*Clé du ticket\*\*" "$extraction_file" | sed 's/.*: //' | sed 's/[[:space:]]*$//' | head -1)
        if [ -n "$key" ]; then
            echo "$key"
            return 0
        fi
    fi
    
    # Extraire le numéro (us-2990 -> 2990)
    local ticket_number=$(echo "$us_name" | sed 's/^us-//' | sed 's/[^0-9]//g')
    
    if [ -z "$ticket_number" ]; then
        return 1
    fi
    
    # Trouver le dossier du projet (remonter jusqu'à trouver un dossier qui correspond à un projet)
    local base_dir=$(get_base_dir)
    local current_dir="$us_dir"
    local project_dir=""
    
    # Remonter jusqu'à trouver le dossier projet (projets/PROJECT/)
    while [ "$current_dir" != "$base_dir/projets" ] && [ "$current_dir" != "/" ]; do
        local dir_name=$(basename "$current_dir")
        local parent_dir=$(dirname "$current_dir")
        
        # Si le parent est "projets", alors dir_name est le projet
        if [ "$(basename "$parent_dir")" = "projets" ]; then
            project_dir="$dir_name"
            break
        fi
        
        current_dir="$parent_dir"
    done
    
    if [ -z "$project_dir" ]; then
        return 1
    fi
    
    # Détecter le préfixe du projet depuis le XML si possible
    local xml_file="$base_dir/Jira/$project_dir/${project_dir}-${ticket_number}.xml"
    if [ -f "$xml_file" ]; then
        if [ -f "$SCRIPT_DIR/xml-utils.sh" ]; then
            source "$SCRIPT_DIR/xml-utils.sh"
            local key=$(extract_key "$xml_file" 2>/dev/null)
            if [ -n "$key" ]; then
                echo "$key"
                return 0
            fi
        fi
    fi
    
    # Fallback : utiliser le nom du projet comme préfixe (uppercase)
    local prefix=$(echo "$project_dir" | tr '[:lower:]' '[:upper:]')
    echo "${prefix}-${ticket_number}"
}

# Extraire le numéro du ticket depuis une clé
# Usage: get_ticket_number "SPEX-2990"
get_ticket_number() {
    local ticket_key="$1"
    echo "$ticket_key" | sed 's/[^0-9]//g'
}

# Extraire le préfixe du projet depuis une clé
# Usage: get_project_prefix "SPEX-2990"
get_project_prefix() {
    local ticket_key="$1"
    echo "$ticket_key" | sed 's/-[0-9]*$//'
}

# Construire le chemin du dossier US depuis une clé de ticket
# Usage: get_us_dir_from_key "SPEX-2990"
get_us_dir_from_key() {
    local ticket_key="$1"
    local project_prefix=$(get_project_prefix "$ticket_key")
    local ticket_number=$(get_ticket_number "$ticket_key")
    local project_dir=$(echo "$project_prefix" | tr '[:upper:]' '[:lower:]')
    local base_dir=$(get_base_dir)
    
    echo "$base_dir/projets/$project_dir/us-$ticket_number"
}

# Construire le chemin du fichier XML depuis une clé de ticket
# Usage: get_xml_file_from_key "SPEX-2990"
get_xml_file_from_key() {
    local ticket_key="$1"
    local project_prefix=$(get_project_prefix "$ticket_key")
    local project_dir=$(echo "$project_prefix" | tr '[:upper:]' '[:lower:]')
    local base_dir=$(get_base_dir)
    
    echo "$base_dir/Jira/$project_dir/$ticket_key.xml"
}

