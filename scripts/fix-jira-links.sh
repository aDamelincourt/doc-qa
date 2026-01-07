#!/bin/bash

# Script pour corriger tous les liens Jira dans les documents existants
# Usage: ./scripts/fix-jira-links.sh

set -euo pipefail

# Charger les bibliothèques communes
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LIB_DIR="$SCRIPT_DIR/lib"
source "$LIB_DIR/config.sh"
source "$LIB_DIR/common-functions.sh"
source "$LIB_DIR/xml-utils.sh"
source "$LIB_DIR/ticket-utils.sh"

log_info "🔧 Correction des liens Jira dans tous les documents..."
echo ""

# Trouver tous les dossiers us-XXXX
us_dirs=()
while IFS= read -r -d '' us_dir; do
    us_dirs+=("$us_dir")
done < <(find "$PROJETS_DIR" -type d -name "us-*" -print0 2>/dev/null | sort -z)

if [ ${#us_dirs[@]} -eq 0 ]; then
    log_error "Aucun dossier US trouvé dans $PROJETS_DIR"
    exit 1
fi

log_info "📊 Dossiers US trouvés : ${#us_dirs[@]}"
echo ""

fixed_count=0
error_count=0

# Fonction pour corriger le lien dans un fichier
fix_link_in_file() {
    local file="$1"
    local ticket_key="$2"
    local correct_link="$3"
    
    if [ ! -f "$file" ]; then
        return 1
    fi
    
    # Remplacer les liens génériques ou incorrects
    # Pattern 1: https://forge.prestashop.com (sans /browse/)
    # Pattern 2: [Lien Jira/Ticket]
    # Pattern 3: [Lien Jira]
    
    local temp_file=$(mktemp)
    
    sed -E "
        s|https://forge\.prestashop\.com[[:space:]]*$|$correct_link|g
        s|\[Lien Jira/Ticket\]|$correct_link|g
        s|\[Lien Jira\]|$correct_link|g
        s|https://forge\.prestashop\.com\"|$correct_link\"|g
    " "$file" > "$temp_file"
    
    # Vérifier si le fichier a changé
    if ! cmp -s "$file" "$temp_file"; then
        mv "$temp_file" "$file"
        return 0
    else
        rm "$temp_file"
        return 1
    fi
}

# Traiter chaque dossier US
for us_dir in "${us_dirs[@]}"; do
    # Extraire la clé du ticket
    ticket_key=$(get_ticket_key_from_path "$us_dir" 2>/dev/null || echo "")
    
    if [ -z "$ticket_key" ]; then
        log_warning "Impossible d'extraire la clé du ticket pour : $us_dir"
        error_count=$((error_count + 1))
        continue
    fi
    
    # Construire le lien correct
    correct_link="https://forge.prestashop.com/browse/$ticket_key"
    
    log_info "📄 Correction de : $ticket_key"
    
    # Fichiers à corriger
    files_to_fix=(
        "$us_dir/README.md"
        "$us_dir/extraction-jira.md"
        "$us_dir/01-questions-clarifications.md"
        "$us_dir/02-strategie-test.md"
        "$us_dir/03-cas-test.md"
    )
    
    file_fixed=false
    
    for file in "${files_to_fix[@]}"; do
        if fix_link_in_file "$file" "$ticket_key" "$correct_link"; then
            file_fixed=true
        fi
    done
    
    if [ "$file_fixed" = "true" ]; then
        fixed_count=$((fixed_count + 1))
        log_success "  ✅ Liens corrigés"
    else
        log_debug "  ⏭️  Aucun changement nécessaire"
    fi
done

# Résumé
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
log_info "📊 Résumé de la correction"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
log_success "✅ US corrigées : $fixed_count"
if [ $error_count -gt 0 ]; then
    log_error "❌ Erreurs : $error_count"
fi
echo ""

