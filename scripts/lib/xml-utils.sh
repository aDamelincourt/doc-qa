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

# Extraire le statut
# Usage: extract_status "/path/to/file.xml"
extract_status() {
    local xml_file="$1"
    sed -n 's/.*<status[^>]*>\([^<]*\)<.*/\1/p' "$xml_file" | head -1
}

# Extraire le type
# Usage: extract_type "/path/to/file.xml"
extract_type() {
    local xml_file="$1"
    sed -n 's/.*<type[^>]*>\([^<]*\)<.*/\1/p' "$xml_file" | head -1
}

# Extraire la priorité
# Usage: extract_priority "/path/to/file.xml"
extract_priority() {
    local xml_file="$1"
    sed -n 's/.*<priority[^>]*>\([^<]*\)<.*/\1/p' "$xml_file" | head -1
}

# Extraire les liens Figma depuis la description
# Usage: extract_figma_links "/path/to/file.xml"
extract_figma_links() {
    local xml_file="$1"
    local description_section=$(awk '/<description>/,/<\/description>/' "$xml_file")
    # Décoder les entités HTML d'abord
    local decoded=$(echo "$description_section" | sed 's/&lt;/</g; s/&gt;/>/g; s/&amp;/\&/g; s/&quot;/"/g')
    # Extraire depuis l'attribut href si présent, sinon depuis le texte
    local href_links=$(echo "$decoded" | grep -oE 'href="https://www\.figma\.com/[^"]+"' | sed 's/href="//; s/"$//' | sed 's/&amp;/\&/g')
    if [ -n "$href_links" ]; then
        echo "$href_links" | sort -u
    else
        # Fallback : extraire depuis le texte
        echo "$decoded" | grep -oE 'https://www\.figma\.com/[^"<>\s&"]+' | sed 's/&amp;/\&/g' | sed 's/&[^;]*;//g' | sort -u
    fi
}

# Extraire les liens Miro depuis la description
# Usage: extract_miro_links "/path/to/file.xml"
extract_miro_links() {
    local xml_file="$1"
    local description_section=$(awk '/<description>/,/<\/description>/' "$xml_file")
    # Décoder les entités HTML d'abord
    local decoded=$(echo "$description_section" | sed 's/&lt;/</g; s/&gt;/>/g; s/&amp;/\&/g; s/&quot;/"/g')
    # Extraire depuis l'attribut href si présent, sinon depuis le texte
    local href_links=$(echo "$decoded" | grep -oE 'href="https://miro\.com/[^"]+"' | sed 's/href="//; s/"$//' | sed 's/&amp;/\&/g')
    if [ -n "$href_links" ]; then
        echo "$href_links" | sort -u
    else
        # Fallback : extraire depuis le texte
        echo "$decoded" | grep -oE 'https://miro\.com/[^"<>\s&"]+' | sed 's/&amp;/\&/g' | sed 's/&[^;]*;//g' | sort -u
    fi
}

# Extraire les commentaires décodés et formatés
# Usage: extract_comments_formatted "/path/to/file.xml" [max_comments]
extract_comments_formatted() {
    local xml_file="$1"
    local max_comments="${2:-10}"
    local temp_file=$(mktemp)
    
    # Extraire les commentaires
    awk '/<comments>/,/<\/comments>/' "$xml_file" | awk '/<comment/,/<\/comment>/' > "$temp_file"
    
    local count=0
    while IFS= read -r line && [ $count -lt $max_comments ]; do
        if echo "$line" | grep -q "<comment"; then
            # Extraire l'auteur
            local author=$(echo "$line" | sed -nE 's/.*author="([^"]*)".*/\1/p')
            # Extraire la date
            local created=$(echo "$line" | sed -nE 's/.*created="([^"]*)".*/\1/p')
            # Extraire le contenu (entre <comment> et </comment>)
            local content=$(echo "$line" | sed -nE 's/.*<comment[^>]*>(.*)<\/comment>.*/\1/p')
            
            if [ -n "$content" ]; then
                # Décoder les entités HTML
                content=$(echo "$content" | sed 's/&lt;/</g; s/&gt;/>/g; s/&amp;/\&/g; s/&quot;/"/g; s/&apos;/'"'"'/g')
                # Nettoyer les balises HTML
                content=$(echo "$content" | sed 's/<[^>]*>//g')
                
                if [ -n "$author" ] && [ -n "$content" ]; then
                    echo "**$author** ($created):"
                    echo "$content"
                    echo ""
                    count=$((count + 1))
                fi
            fi
        fi
    done < "$temp_file"
    
    rm -f "$temp_file"
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

# Générer le fichier extraction-jira.md complet
# Usage: generate_extraction_jira "/path/to/file.xml" "/path/to/us-dir"
# Prérequis: parse_xml_file doit avoir été appelé pour définir KEY, TITLE, LINK, PROJECT_NAME, DESCRIPTION_SECTION
generate_extraction_jira() {
    local xml_file="$1"
    local us_dir="$2"
    
    if [ -z "$xml_file" ] || [ -z "$us_dir" ]; then
        log_error "generate_extraction_jira: Arguments manquants"
        return 1
    fi
    
    if [ ! -f "$xml_file" ]; then
        log_error "generate_extraction_jira: Fichier XML introuvable : $xml_file"
        return 1
    fi
    
    if [ ! -d "$us_dir" ]; then
        log_error "generate_extraction_jira: Dossier US introuvable : $us_dir"
        return 1
    fi
    
    # Variables doivent être définies par parse_xml_file
    if [ -z "${KEY:-}" ] || [ -z "${TITLE:-}" ] || [ -z "${LINK:-}" ]; then
        log_error "generate_extraction_jira: Variables KEY, TITLE, LINK non définies. Appelez parse_xml_file d'abord."
        return 1
    fi
    
    local extraction_file="$us_dir/extraction-jira.md"
    local project_dir="${PROJECT_NAME:-$(basename "$(dirname "$xml_file")")}"
    local ticket_id=$(basename "$xml_file" .xml)
    
    # Extraire toutes les informations supplémentaires
    local status=$(extract_status "$xml_file" 2>/dev/null || echo "")
    local type=$(extract_type "$xml_file" 2>/dev/null || echo "Story")
    local priority=$(extract_priority "$xml_file" 2>/dev/null || echo "")
    
    # Extraire les critères d'acceptation
    local acceptance_criteria=$(extract_acceptance_criteria "$xml_file" 2>/dev/null || echo "")
    
    # Extraire les liens Figma et Miro
    local figma_links=$(extract_figma_links "$xml_file" 2>/dev/null || echo "")
    local miro_links=$(extract_miro_links "$xml_file" 2>/dev/null || echo "")
    
    # Extraire les commentaires formatés
    local comments=$(extract_comments_formatted "$xml_file" 10 2>/dev/null || echo "")
    
    # Extraire la description décodée pour la User Story
    local description_decoded=$(decode_html_cached "${DESCRIPTION_SECTION:-}" 2>/dev/null || echo "${DESCRIPTION_SECTION:-}")
    local user_story_section=$(echo "$description_decoded" | awk '/USER STORY/i {found=1} found {print} /^<h[12]>/ && found && !/USER STORY/i {exit}' | head -50)
    
    cat > "$extraction_file" <<EOF
# Extraction Jira - $KEY

## 📋 Informations générales

**Clé du ticket** : $KEY
**Titre/Summary** : $TITLE
**Type** : ${type:-Story}
**Statut** : ${status:-[Non disponible]}
**Priorité** : ${priority:-[Non disponible]}
**Lien Jira** : $LINK

## 📝 Description / User Story

$(if [ -n "$user_story_section" ]; then
    echo "$user_story_section" | sed 's/<[^>]*>//g' | sed 's/&[^;]*;//g' | head -30
else
    echo "$description_decoded" | sed 's/<[^>]*>//g' | sed 's/&[^;]*;//g' | head -30
fi)

> **Note** : Description complète disponible dans le fichier XML : \`../Jira/$project_dir/$ticket_id.xml\`

## ✅ Critères d'acceptation

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

## 💻 Informations techniques

$(if echo "$description_decoded" | grep -qi "SPECS TECHNIQUES\|SPECS\|Technical"; then
    echo "$description_decoded" | awk '/SPECS TECHNIQUES/i || /SPECS/i || /Technical/i {found=1} found {print} /^<h[12]>/ && found && !/SPECS/i && !/Technical/i && !/Acceptance/i {exit}' | sed 's/<[^>]*>//g' | sed 's/&[^;]*;//g' | grep -v "^$" | head -30
else
    echo "*Aucune information technique trouvée dans la description*"
fi)

## 🎨 Designs

$(if [ -n "$figma_links" ]; then
    echo "### Liens Figma"
    echo "$figma_links" | while read -r link; do
        echo "- $link"
    done
    echo ""
fi)

$(if [ -n "$miro_links" ]; then
    echo "### Liens Miro (Event Modeling)"
    echo "$miro_links" | while read -r link; do
        echo "- $link"
    done
    echo ""
fi)

$(if [ -z "$figma_links" ] && [ -z "$miro_links" ]; then
    echo "*Aucun lien de design trouvé dans la description*"
fi)

## 📝 Commentaires de l'équipe

$(if [ -n "$comments" ]; then
    echo "$comments"
else
    echo "*Aucun commentaire trouvé dans le XML*"
fi)

---

**Date d'extraction** : $(date +"%Y-%m-%d")
**Fichier source** : Jira/$project_dir/$ticket_id.xml
EOF
    
    log_success "Fichier d'extraction créé/mis à jour : extraction-jira.md"
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
                # Décoder DESCRIPTION_SECTION depuis base64 si présent
                if [ -n "${DESCRIPTION_SECTION_B64:-}" ]; then
                    DESCRIPTION_SECTION=$(echo "$DESCRIPTION_SECTION_B64" | base64 -d 2>/dev/null || echo "")
                    unset DESCRIPTION_SECTION_B64
                fi
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
        
        # Échapper les caractères spéciaux pour le cache
        # Utiliser base64 pour encoder DESCRIPTION_SECTION (contient du HTML/XML avec &lt; &gt; etc.)
        # qui pourrait être interprété comme des commandes lors du source
        local KEY_ESCAPED=$(printf '%q' "$KEY")
        local TITLE_ESCAPED=$(printf '%q' "$TITLE")
        local LINK_ESCAPED=$(printf '%q' "$LINK")
        local PROJECT_NAME_ESCAPED=$(printf '%q' "$PROJECT_NAME")
        local DESC_B64=$(echo -n "$DESCRIPTION_SECTION" | base64 2>/dev/null || echo "")
        
        cat > "$cache_file" <<EOF
KEY=$KEY_ESCAPED
TITLE=$TITLE_ESCAPED
LINK=$LINK_ESCAPED
PROJECT_NAME=$PROJECT_NAME_ESCAPED
DESCRIPTION_SECTION_B64="$DESC_B64"
EOF
        date +%s > "$cache_time_file" 2>/dev/null || true
        log_debug "Cache XML mis à jour pour : $xml_file"
    fi
    
    return 0
}

