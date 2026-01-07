#!/bin/bash

# Bibliothèque de fonctions pour le traitement des fichiers
# Usage: source "$(dirname "${BASH_SOURCE[0]}")/lib/processing-utils.sh"

# Charger les fonctions communes
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
if [ -f "$SCRIPT_DIR/common-functions.sh" ]; then
    source "$SCRIPT_DIR/common-functions.sh"
else
    echo "❌ Erreur : Impossible de charger common-functions.sh" >&2
    exit 1
fi

# Cache pour les résultats de find (optimisation performance)
# Optimisation #8 : Utiliser des fichiers temporaires au lieu de eval (plus sûr)
FIND_CACHE_TTL=300  # 5 minutes
FIND_CACHE_DIR="${TMPDIR:-/tmp}/qa_find_cache"

# Initialiser le répertoire de cache find
init_find_cache() {
    if [ ! -d "$FIND_CACHE_DIR" ]; then
        mkdir -p "$FIND_CACHE_DIR" 2>/dev/null || {
            log_warning "Impossible de créer le répertoire de cache find, cache désactivé"
            FIND_CACHE_DIR=""
        }
    fi
}

# Obtenir le cache find
get_find_cache() {
    local cache_key="$1"
    if [ -z "$FIND_CACHE_DIR" ]; then
        return 1
    fi
    
    init_find_cache
    
    local cache_file="$FIND_CACHE_DIR/${cache_key}.cache"
    local cache_time_file="$FIND_CACHE_DIR/${cache_key}.time"
    
    if [ -f "$cache_file" ] && [ -f "$cache_time_file" ]; then
        local cache_time=$(cat "$cache_time_file" 2>/dev/null || echo "0")
        local current_time=$(date +%s 2>/dev/null || echo "0")
        
        if [ "$current_time" != "0" ] && [ "$cache_time" != "0" ] && [ $((current_time - cache_time)) -lt $FIND_CACHE_TTL ]; then
            cat "$cache_file"
            return 0
        fi
    fi
    return 1
}

# Mettre à jour le cache find
set_find_cache() {
    local cache_key="$1"
    local value="$2"
    
    if [ -z "$FIND_CACHE_DIR" ]; then
        return 1
    fi
    
    init_find_cache
    
    local cache_file="$FIND_CACHE_DIR/${cache_key}.cache"
    local cache_time_file="$FIND_CACHE_DIR/${cache_key}.time"
    
    echo "$value" > "$cache_file"
    date +%s > "$cache_time_file" 2>/dev/null || true
}

# Vérifier si un fichier XML a déjà été traité
# Usage: is_processed "/path/to/file.xml" [base_dir]
# Optimisation: utilise un cache pour éviter les scans répétés
is_processed() {
    local xml_file="$1"
    local base_dir="${2:-$(get_base_dir)}"
    local ticket_id=$(basename "$xml_file" .xml)
    local project_dir=$(basename "$(dirname "$xml_file")")
    local projets_dir="$base_dir/projets"
    local cache_key="readme_${project_dir}"
    
    # Vérifier que le projet existe
    if [ ! -d "$projets_dir/$project_dir" ]; then
        return 1  # Projet n'existe pas = non traité
    fi
    
    # Utiliser le cache si disponible (optimisation #8)
    local readme_list
    if readme_list=$(get_find_cache "$cache_key"); then
        # Cache valide
        log_debug "Utilisation du cache find pour : $project_dir"
    else
        # Mettre à jour le cache
        readme_list=$(find "$projets_dir/$project_dir" -type f -name "README.md" 2>/dev/null | tr '\n' '|')
        set_find_cache "$cache_key" "$readme_list"
    fi
    
    # Chercher dans les README pour une mention du ticket
    local found=0
    IFS='|' read -ra READMES <<< "$readme_list"
    for readme in "${READMES[@]}"; do
        if [ -n "$readme" ] && [ -f "$readme" ] && grep -q "$ticket_id" "$readme" 2>/dev/null; then
            found=1
            break
        fi
    done
    
    if [ "$found" -eq 1 ]; then
        return 0  # Trouvé = traité
    fi
    
    # Vérification supplémentaire : chercher un dossier us-XXXX correspondant au numéro du ticket
    # Peut être dans un sous-dossier (ex: projets/ACCOUNT/spikes/us-3182)
    local ticket_number=$(echo "$ticket_id" | sed 's/[^0-9]//g')
    if [ -n "$ticket_number" ]; then
        # Chercher dans tous les sous-dossiers possibles
        local found_us_dir=$(find "$projets_dir/$project_dir" -type d -name "us-$ticket_number" 2>/dev/null | head -1)
        if [ -n "$found_us_dir" ] && [ -d "$found_us_dir" ]; then
            # Le dossier existe, vérifier s'il contient au moins un fichier de documentation
            if [ -f "$found_us_dir/README.md" ] || \
               [ -f "$found_us_dir/01-questions-clarifications.md" ]; then
                return 0  # Documentation existe = traité
            fi
        fi
    fi
    
    return 1  # Non trouvé = non traité
}

# Extraire des informations basiques du XML (compatible macOS)
# Usage: extract_xml_info "/path/to/file.xml"
# Retourne: "project_dir|key|title"
extract_xml_info() {
    local xml_file="$1"
    
    if [ ! -f "$xml_file" ]; then
        log_error "Fichier XML introuvable : $xml_file"
        return 1
    fi
    
    source "$SCRIPT_DIR/xml-utils.sh" 2>/dev/null || {
        log_error "Impossible de charger xml-utils.sh"
        return 1
    }
    
    local key=$(extract_key "$xml_file")
    local title=$(extract_summary "$xml_file")
    local project_dir=$(basename "$(dirname "$xml_file")")
    
    echo "$project_dir|$key|$title"
}

# Vérifier les permissions d'écriture
# Usage: check_write_permissions "/path/to/dir"
check_write_permissions() {
    local dir="$1"
    
    if [ ! -d "$dir" ]; then
        # Essayer de créer le répertoire
        if ! mkdir -p "$dir" 2>/dev/null; then
            log_error "Impossible de créer le répertoire : $dir"
            return 1
        fi
    fi
    
    # Vérifier les permissions d'écriture
    if [ ! -w "$dir" ]; then
        log_error "Pas de permission d'écriture dans : $dir"
        return 1
    fi
    
    return 0
}

# Créer un répertoire avec validation
# Usage: safe_mkdir "/path/to/dir"
safe_mkdir() {
    local dir="$1"
    
    if [ -d "$dir" ]; then
        log_warning "Le répertoire existe déjà : $dir"
        return 0
    fi
    
    if ! mkdir -p "$dir" 2>/dev/null; then
        log_error "Impossible de créer le répertoire : $dir"
        return 1
    fi
    
    return 0
}

