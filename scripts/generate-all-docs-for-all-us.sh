#!/bin/bash

# Script pour générer TOUS les documents pour TOUTES les US avec Cursor IA
# Usage: ./scripts/generate-all-docs-for-all-us.sh

set -euo pipefail

# Charger les bibliothèques communes
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LIB_DIR="$SCRIPT_DIR/lib"
source "$LIB_DIR/config.sh"
source "$LIB_DIR/common-functions.sh"
source "$LIB_DIR/xml-utils.sh"
source "$LIB_DIR/ticket-utils.sh"
source "$LIB_DIR/cursor-ai-utils.sh"

log_info "🤖 Génération automatique de TOUS les documents pour TOUTES les US..."
echo ""

# Trouver tous les dossiers US
BASE_DIR=$(cd "$SCRIPT_DIR/.." && pwd)
PROJETS_DIR_ACTUAL="${PROJETS_DIR:-$BASE_DIR/projets}"
us_dirs=()
while IFS= read -r -d '' us_dir; do
    us_dirs+=("$us_dir")
done < <(find "$PROJETS_DIR_ACTUAL" -type d -name "us-*" -print0 2>/dev/null | sort -z)

if [ ${#us_dirs[@]} -eq 0 ]; then
    log_error "Aucun dossier US trouvé dans $BASE_DIR/projets"
    exit 1
fi

log_info "📊 US trouvées : ${#us_dirs[@]}"
echo ""

# Afficher la liste
echo "📋 Liste des US à traiter :"
for us_dir in "${us_dirs[@]}"; do
    ticket_key=$(get_ticket_key_from_path "$us_dir" 2>/dev/null || echo "N/A")
    echo "   - $ticket_key : $us_dir"
done
echo ""

# Demander confirmation
read -p "Voulez-vous générer tous les documents (questions, strategy, test-cases) pour ces ${#us_dirs[@]} US ? (o/N) " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Oo]$ ]]; then
    log_info "Abandonné."
    exit 0
fi

echo ""
log_info "🚀 Début de la génération..."
echo ""

success_count=0
error_count=0
skipped_count=0

# Traiter chaque US
for us_dir in "${us_dirs[@]}"; do
    ticket_key=$(get_ticket_key_from_path "$us_dir" 2>/dev/null || echo "N/A")
    
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    log_info "📄 Traitement de : $ticket_key"
    log_info "   Dossier : $us_dir"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
    
    # Vérifier que le dossier existe et contient extraction-jira.md
    if [ ! -f "$us_dir/extraction-jira.md" ]; then
        log_warning "⚠️  Fichier extraction-jira.md introuvable, ignoré"
        skipped_count=$((skipped_count + 1))
        echo ""
        continue
    fi
    
    # Trouver le fichier XML
    XML_FILE=$(get_xml_file_from_key "$ticket_key" 2>/dev/null)
    if [ -z "$XML_FILE" ] || [ ! -f "$XML_FILE" ]; then
        log_warning "⚠️  Fichier XML introuvable pour $ticket_key, ignoré"
        skipped_count=$((skipped_count + 1))
        echo ""
        continue
    fi
    
    # Préparer le contexte
    CONTEXT=$(prepare_context_for_ai "$XML_FILE" "$us_dir" 2>/dev/null)
    if [ $? -ne 0 ]; then
        log_error "❌ Erreur lors de la préparation du contexte pour $ticket_key"
        error_count=$((error_count + 1))
        echo ""
        continue
    fi
    
    log_info "✅ Contexte préparé pour $ticket_key"
    log_info "📋 Les prompts seront générés et l'agent Cursor générera les documents"
    echo ""
    log_info "💡 Pour générer les documents, dites à l'agent Cursor :"
    log_info "   'Génère tous les documents pour $ticket_key'"
    echo ""
    
    success_count=$((success_count + 1))
    echo ""
done

# Résumé
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
log_info "📊 Résumé"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
log_success "✅ US prêtes pour génération : $success_count"
if [ $skipped_count -gt 0 ]; then
    log_warning "⚠️  US ignorées : $skipped_count"
fi
if [ $error_count -gt 0 ]; then
    log_error "❌ Erreurs : $error_count"
fi
echo ""
log_info "💡 Pour générer les documents, dites à l'agent Cursor :"
log_info "   'Génère tous les documents pour [TICKET-KEY]'"
log_info "   ou"
log_info "   'Génère le document [questions|strategy|test-cases] pour [TICKET-KEY]'"
echo ""

