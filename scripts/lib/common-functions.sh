#!/bin/bash

# Bibliothèque de fonctions communes pour les scripts QA
# Usage: source "$(dirname "${BASH_SOURCE[0]}")/lib/common-functions.sh"

# Cache pour le décodage HTML (optimisation performance)
HTML_DECODE_CACHE_DIR="${TMPDIR:-/tmp}/qa_html_cache"
HTML_DECODE_CACHE_TTL=300  # 5 minutes

# Initialiser le répertoire de cache HTML
init_html_cache() {
    if [ ! -d "$HTML_DECODE_CACHE_DIR" ]; then
        mkdir -p "$HTML_DECODE_CACHE_DIR" 2>/dev/null || {
            log_warning "Impossible de créer le répertoire de cache HTML, cache désactivé"
            HTML_DECODE_CACHE_DIR=""
        }
    fi
}

# Fonction pour décoder les entités HTML/XML
# Usage: decode_html "<string>"
# Optimisation: utilise un seul sed avec plusieurs substitutions au lieu de plusieurs sed en chaîne
decode_html() {
    local input="$1"
    # Optimisation: utiliser un seul sed avec plusieurs substitutions
    echo "$input" | sed -E '
        s/&lt;/</g
        s/&gt;/>/g
        s/&amp;/\&/g
        s/&quot;/"/g
        s/&apos;/'"'"'/g
        s/&#8232;/\n/g
        s/&#160;/ /g
        s/&#8211;/-/g
        s/&#8220;/"/g
        s/&#8221;/"/g
        s/<br\/>/\n/g
        s/<[^>]*>//g
        s/  */ /g
    ' | sed '/^$/d'
}

# Fonction pour décoder avec cache (optimisation performance)
# Usage: decode_html_cached "<string>"
decode_html_cached() {
    local input="$1"
    
    # Si le cache est désactivé ou l'input est vide, utiliser la fonction normale
    if [ -z "$HTML_DECODE_CACHE_DIR" ] || [ -z "$input" ]; then
        decode_html "$input"
        return 0
    fi
    
    init_html_cache
    
    # Générer une clé de cache (hash MD5 si disponible, sinon utiliser les 100 premiers caractères)
    local cache_key
    if command -v md5sum &> /dev/null; then
        cache_key=$(echo -n "$input" | md5sum | cut -d' ' -f1)
    elif command -v md5 &> /dev/null; then
        cache_key=$(echo -n "$input" | md5 | cut -d' ' -f1)
    else
        # Fallback: utiliser les 100 premiers caractères comme clé
        cache_key=$(echo -n "$input" | head -c 100 | tr -d '\n' | sed 's/[^a-zA-Z0-9]/_/g')
    fi
    
    local cache_file="$HTML_DECODE_CACHE_DIR/${cache_key}.cache"
    local cache_time_file="$HTML_DECODE_CACHE_DIR/${cache_key}.time"
    
    # Vérifier le cache
    if [ -f "$cache_file" ] && [ -f "$cache_time_file" ]; then
        local cache_time=$(cat "$cache_time_file" 2>/dev/null || echo "0")
        local current_time=$(date +%s 2>/dev/null || echo "0")
        
        if [ "$current_time" != "0" ] && [ "$cache_time" != "0" ] && [ $((current_time - cache_time)) -lt $HTML_DECODE_CACHE_TTL ]; then
            # Utiliser le cache
            cat "$cache_file"
            return 0
        fi
    fi
    
    # Décoder et mettre en cache
    local decoded=$(decode_html "$input")
    echo "$decoded" > "$cache_file"
    date +%s > "$cache_time_file" 2>/dev/null || true
    
    echo "$decoded"
}

# Fonction pour décoder les entités HTML/XML (version simple, sans suppression des balises)
# Usage: decode_html_simple "<string>"
decode_html_simple() {
    local input="$1"
    # Décoder les entités HTML/XML mais garder les balises HTML
    echo "$input" | sed 's/&lt;/</g; s/&gt;/>/g; s/&amp;/\&/g; s/&quot;/"/g; s/&apos;/'"'"'/g; s/&#8232;/\n/g; s/&#160;/ /g; s/&#8211;/-/g; s/&#8212;/--/g; s/&#8220;/"/g; s/&#8221;/"/g; s/&#8216;/'"'"'/g; s/&#8217;/'"'"'/g; s/&#8230;/.../g; s/&#39;/'"'"'/g'
}

# Fonction pour logger avec niveau
# Usage: log_info "message" / log_error "message" / log_debug "message"
log_info() {
    echo "ℹ️  $1" >&2
}

log_error() {
    echo "❌ $1" >&2
}

log_success() {
    echo "✅ $1" >&2
}

log_warning() {
    echo "⚠️  $1" >&2
}

log_debug() {
    if [ "${DEBUG:-false}" = "true" ]; then
        echo "🔍 DEBUG: $1" >&2
    fi
}

# Fonction pour valider qu'un fichier existe
# Usage: validate_file "/path/to/file"
validate_file() {
    local file="$1"
    if [ ! -f "$file" ]; then
        log_error "Fichier introuvable : $file"
        return 1
    fi
    return 0
}

# Fonction pour valider qu'un répertoire existe
# Usage: validate_directory "/path/to/dir"
validate_directory() {
    local dir="$1"
    if [ ! -d "$dir" ]; then
        log_error "Répertoire introuvable : $dir"
        return 1
    fi
    return 0
}

# Fonction pour sanitizer un chemin (protection path traversal)
# Usage: sanitize_path "/path/to/file"
sanitize_path() {
    local path="$1"
    # Enlever les .. et les / au début
    # Protéger contre les path traversal attacks
    local sanitized=$(echo "$path" | sed 's|\.\./||g' | sed 's|\.\.||g' | sed 's|^/||')
    
    # Vérifier qu'il ne reste pas de caractères dangereux
    if echo "$sanitized" | grep -q '[;&|`$]'; then
        log_error "Chemin contenant des caractères dangereux détecté"
        return 1
    fi
    
    echo "$sanitized"
    return 0
}

# Fonction pour obtenir le répertoire de base du projet
# Usage: get_base_dir
get_base_dir() {
    # Si on est dans scripts/lib/, remonter de 2 niveaux
    # Si on est dans scripts/, remonter de 1 niveau
    local script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    if [[ "$script_dir" == */scripts/lib ]]; then
        echo "$(cd "$script_dir/../.." && pwd)"
    elif [[ "$script_dir" == */scripts ]]; then
        echo "$(cd "$script_dir/.." && pwd)"
    else
        # Fallback : essayer de trouver le répertoire parent
        echo "$(cd "$script_dir/.." && pwd)"
    fi
}

# Fonction pour obtenir le répertoire des scripts
# Usage: get_script_dir
get_script_dir() {
    echo "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
}

# Fonction pour échapper les caractères spéciaux pour sed
# Usage: escape_for_sed "<string>"
# Optimisation: fonction centralisée pour éviter la duplication de code
escape_for_sed() {
    local input="$1"
    # Échapper les caractères spéciaux pour sed
    echo "$input" | sed 's/[\.*^$()+?{|]/\\&/g' | sed 's|/|\\/|g' | sed 's/\[/\\[/g' | sed 's/\]/\\]/g'
}

# Fonction wrapper pour exécuter des commandes avec gestion d'erreurs cohérente
# Usage: safe_execute "command" ["error_message"]
safe_execute() {
    local cmd="$1"
    local error_msg="${2:-Erreur lors de l execution}"
    
    set +e
    eval "$cmd" >/dev/null 2>&1
    local exit_code=$?
    set -e
    
    if [ $exit_code -ne 0 ]; then
        log_debug "$error_msg (code: $exit_code)"
        return $exit_code
    fi
    return 0
}

