#!/bin/bash

# Script pour mettre à jour tous les README des US existantes
# Usage: ./scripts/update-all-readmes.sh

set -euo pipefail

# Charger les bibliothèques communes
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LIB_DIR="$SCRIPT_DIR/lib"
source "$LIB_DIR/config.sh"
source "$LIB_DIR/common-functions.sh"

log_info "Mise à jour de tous les README des US..."
echo ""

# Trouver tous les dossiers us-XXXX et les stocker dans un tableau
US_DIRS=()
while IFS= read -r -d '' US_DIR; do
    US_DIRS+=("$US_DIR")
done < <(find "$PROJETS_DIR" -type d -name "us-*" -print0)

US_COUNT=${#US_DIRS[@]}
UPDATED_COUNT=0

# Traiter chaque US
for US_DIR in "${US_DIRS[@]}"; do
    US_NAME=$(basename "$US_DIR")
    PROJECT_NAME=$(basename "$(dirname "$US_DIR")")
    
        log_info "Mise à jour de $PROJECT_NAME/$US_NAME..."
        
        if "$SCRIPT_DIR/update-readme-from-xml.sh" "$US_DIR" > /dev/null 2>&1; then
            UPDATED_COUNT=$((UPDATED_COUNT + 1))
            log_success "$US_NAME mis à jour"
        else
            log_warning "Erreur lors de la mise à jour de $US_NAME"
        fi
    echo ""
done

log_success "Mise à jour terminée"
log_info "   - $UPDATED_COUNT README mis à jour sur $US_COUNT US trouvées"

