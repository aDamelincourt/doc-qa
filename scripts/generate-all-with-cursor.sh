#!/bin/bash

# Script pour préparer tous les prompts pour l'agent Cursor
# Usage: ./scripts/generate-all-with-cursor.sh [US_DIR]

set -euo pipefail

# Charger les bibliothèques communes
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LIB_DIR="$SCRIPT_DIR/lib"
source "$LIB_DIR/config.sh"
source "$LIB_DIR/common-functions.sh"
source "$LIB_DIR/xml-utils.sh"
source "$LIB_DIR/ticket-utils.sh"
source "$LIB_DIR/cursor-ai-utils.sh"

if [ -z "${1:-}" ]; then
    log_error "Dossier US requis"
    echo "Usage: ./scripts/generate-all-with-cursor.sh [US_DIR]"
    echo "Exemple: ./scripts/generate-all-with-cursor.sh projets/ACCOUNT/us-3239"
    exit 1
fi

US_DIR="$1"

if [ ! -d "$US_DIR" ]; then
    log_error "Dossier introuvable : $US_DIR"
    exit 1
fi

log_info "📋 Préparation de tous les prompts pour l'agent Cursor..."
echo ""

# Générer les 3 prompts
for doc_type in questions strategy test-cases; do
    log_info "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    log_info "📝 Préparation : $doc_type"
    log_info "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
    
    "$SCRIPT_DIR/generate-with-cursor.sh" "$doc_type" "$US_DIR"
    echo ""
    echo ""
done

log_success "✅ Tous les prompts sont prêts !"
log_info ""
log_info "👉 Vous pouvez maintenant demander à l'agent Cursor de générer chaque document"
log_info "   en utilisant les prompts créés dans le dossier : $US_DIR"

