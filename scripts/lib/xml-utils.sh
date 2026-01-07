#!/bin/bash

# Bibliothèque de fonctions pour l'extraction XML
# Usage: source "$(dirname "${BASH_SOURCE[0]}")/lib/xml-utils.sh"

# Charger les fonctions communes
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
if [ -f "$SCRIPT_DIR/common-functions.sh" ]; then
    source "$SCRIPT_DIR/common-functions.sh"
else
    echo "❌ Erreur : Impossible de charger common-functions.sh" >&2
    exit 1
fi

# Extraire un champ XML générique
# Usage: extract_xml_field "/path/to/file.xml" "field_name"
extract_xml_field() {
    local xml_file="$1"
    local field="$2"
    
    if [ ! -f "$xml_file" ]; then
        log_error "Fichier XML introuvable : $xml_file"
        return 1
    fi
    
    sed -n "s/.*<$field[^>]*>\([^<]*\)<.*/\1/p" "$xml_file" | head -1 | sed 's/&lt;/</g; s/&gt;/>/g; s/&amp;/\&/g; s/&quot;/"/g; s/&apos;/'"'"'/g'
}

# Extraire la clé du ticket
# Usage: extract_key "/path/to/file.xml"
extract_key() {
    local xml_file="$1"
    sed -n 's/.*<key[^>]*>\([^<]*\)<.*/\1/p' "$xml_file" | head -1
}

# Extraire le lien
# Usage: extract_link "/path/to/file.xml"
# Extrait le lien Jira spécifique au ticket (celui qui contient /browse/)
extract_link() {
    local xml_file="$1"
    
    # Chercher d'abord le lien qui contient /browse/ (lien spécifique au ticket)
    local specific_link=$(sed -n 's/.*<link>\([^<]*\)<.*/\1/p' "$xml_file" | grep "/browse/" | head -1)
    
    if [ -n "$specific_link" ]; then
        echo "$specific_link"
        return 0
    fi
    
    # Si pas de lien spécifique trouvé, construire le lien à partir de la clé du ticket
    local key=$(extract_key "$xml_file" 2>/dev/null)
    if [ -n "$key" ]; then
        echo "https://forge.prestashop.com/browse/$key"
        return 0
    fi
    
    # Fallback : retourner le premier lien trouvé (générique)
    sed -n 's/.*<link>\([^<]*\)<.*/\1/p' "$xml_file" | head -1
}

# Extraire le summary/titre
# Usage: extract_summary "/path/to/file.xml"
extract_summary() {
    local xml_file="$1"
    sed -n 's/.*<summary>\([^<]*\)<.*/\1/p' "$xml_file" | head -1
}

# Extraire la description (section complète)
# Usage: extract_description "/path/to/file.xml" [max_lines]
extract_description() {
    local xml_file="$1"
    local max_lines="${2:-200}"
    awk '/<description>/,/<\/description>/' "$xml_file" | sed 's/<description>//; s/<\/description>//' | head -"$max_lines"
}

# Extraire le nom du projet
# Usage: extract_project_name "/path/to/file.xml"
extract_project_name() {
    local xml_file="$1"
    grep "<project" "$xml_file" | sed 's/.*>\([^<]*\)<.*/\1/' | head -1
}

# Extraire les commentaires
# Usage: extract_comments "/path/to/file.xml" [max_lines]
# Note: Utilise awk pour compatibilité macOS (grep -A non supporté par défaut)
extract_comments() {
    local xml_file="$1"
    local max_lines="${2:-100}"
    # Utiliser awk pour extraire les commentaires (compatible macOS)
    awk '/<comments>/,/<\/comments>/' "$xml_file" | awk '/<comment/,/<\/comment>/' | head -"$max_lines"
}

# Valider qu'un fichier XML est valide (vérification basique)
# Usage: validate_xml "/path/to/file.xml"
# Optimisation: lecture unique du fichier pour toutes les vérifications
validate_xml() {
    local xml_file="$1"
    
    if [ ! -f "$xml_file" ]; then
        log_error "Fichier XML introuvable : $xml_file"
        return 1
    fi
    
    # Vérifier que le fichier n'est pas vide
    if [ ! -s "$xml_file" ]; then
        log_error "Le fichier XML est vide : $xml_file"
        return 1
    fi
    
    # Optimisation: lire les 50 premières lignes une seule fois
    local first_lines=$(head -50 "$xml_file" 2>/dev/null)
    
    # Vérifier la présence de <?xml, <rss, <item ou <!-- (commentaire) dans les premières lignes
    # Certains exports Jira commencent par des commentaires
    if ! echo "$first_lines" | grep -qE "<?xml|<rss|<item|<!--"; then
        log_error "Le fichier ne semble pas être un XML Jira valide : $xml_file"
        log_error "   Le fichier doit contenir <?xml, <rss, <item ou <!--"
        return 1
    fi
    
    # Vérifier la présence de <key> dans les 50 premières lignes
    # Si pas trouvé dans les 50 premières, chercher dans les 200 premières
    if ! echo "$first_lines" | grep -q "<key"; then
        local more_lines=$(head -200 "$xml_file" 2>/dev/null)
        if ! echo "$more_lines" | grep -q "<key"; then
            log_error "Le fichier ne contient pas de balise <key> : $xml_file"
            log_error "   Le fichier doit contenir au moins une balise <key>"
            return 1
        fi
    fi
    
    return 0
}

# Cache pour le parsing XML (optimisation performance)
# Compatibilité bash 3.x : utiliser des fichiers temporaires au lieu de tableaux associatifs
XML_CACHE_TTL=300  # 5 minutes
XML_CACHE_DIR="${TMPDIR:-/tmp}/qa_xml_cache"

# Initialiser le répertoire de cache
init_xml_cache() {
    if [ ! -d "$XML_CACHE_DIR" ]; then
        mkdir -p "$XML_CACHE_DIR" 2>/dev/null || {
            log_warning "Impossible de créer le répertoire de cache XML, cache désactivé"
            XML_CACHE_DIR=""
        }
    fi
}

# Obtenir la clé de cache pour un fichier XML
get_xml_cache_key() {
    local xml_file="$1"
    # Utiliser le chemin absolu et la date de modification comme clé
    local abs_path=$(cd "$(dirname "$xml_file")" && pwd)/$(basename "$xml_file")
    local mtime=$(stat -f "%m" "$xml_file" 2>/dev/null || stat -c "%Y" "$xml_file" 2>/dev/null || echo "0")
    echo "$(echo "$abs_path" | md5sum 2>/dev/null | cut -d' ' -f1 || echo "$abs_path")_${mtime}"
}

# Parser le XML une fois et stocker les résultats dans des variables
# Usage: parse_xml_file "/path/to/file.xml"
# Retourne: variables KEY, TITLE, LINK, PROJECT_NAME, DESCRIPTION_SECTION
# Optimisation: utilise un cache pour éviter de parser plusieurs fois le même fichier
parse_xml_file() {
    local xml_file="$1"
    
    if ! validate_xml "$xml_file"; then
        return 1
    fi
    
    # Vérifier le cache si disponible
    if [ -n "$XML_CACHE_DIR" ]; then
        init_xml_cache
        local cache_key=$(get_xml_cache_key "$xml_file")
        local cache_file="$XML_CACHE_DIR/${cache_key}.cache"
        local cache_time_file="$XML_CACHE_DIR/${cache_key}.time"
        
        if [ -f "$cache_file" ] && [ -f "$cache_time_file" ]; then
            local cache_time=$(cat "$cache_time_file" 2>/dev/null || echo "0")
            local current_time=$(date +%s 2>/dev/null || echo "0")
            
            if [ "$current_time" != "0" ] && [ "$cache_time" != "0" ] && [ $((current_time - cache_time)) -lt $XML_CACHE_TTL ]; then
                # Utiliser le cache
                log_debug "Utilisation du cache XML pour : $xml_file"
                source "$cache_file"
                return 0
            fi
        fi
    fi
    
    # Parser le fichier XML
    KEY=$(extract_key "$xml_file")
    TITLE=$(extract_summary "$xml_file")
    LINK=$(extract_link "$xml_file")
    PROJECT_NAME=$(extract_project_name "$xml_file")
    DESCRIPTION_SECTION=$(extract_description "$xml_file" 200)
    
    if [ -z "$KEY" ] || [ -z "$TITLE" ]; then
        log_error "Impossible d'extraire les informations essentielles du XML : $xml_file"
        return 1
    fi
    
    # Mettre en cache si disponible
    if [ -n "$XML_CACHE_DIR" ] && [ -d "$XML_CACHE_DIR" ]; then
        local cache_key=$(get_xml_cache_key "$xml_file")
        local cache_file="$XML_CACHE_DIR/${cache_key}.cache"
        local cache_time_file="$XML_CACHE_DIR/${cache_key}.time"
        
        cat > "$cache_file" <<EOF
KEY="$KEY"
TITLE="$TITLE"
LINK="$LINK"
PROJECT_NAME="$PROJECT_NAME"
DESCRIPTION_SECTION='$DESCRIPTION_SECTION'
EOF
        date +%s > "$cache_time_file" 2>/dev/null || true
        log_debug "Cache XML mis à jour pour : $xml_file"
    fi
    
    return 0
}

