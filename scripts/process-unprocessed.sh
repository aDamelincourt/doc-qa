#!/bin/bash

# Script pour traiter tous les fichiers XML non traités (workflow legacy XML).
# Pour le workflow API (recommande), utiliser : ./scripts/qa-pipeline.sh process-all
# Usage: ./scripts/process-unprocessed.sh

set -euo pipefail

# Charger les bibliothèques communes
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LIB_DIR="$SCRIPT_DIR/lib"
PROCESS_SCRIPT="$SCRIPT_DIR/process-xml-file.sh"
source "$LIB_DIR/config.sh"
source "$LIB_DIR/common-functions.sh"
source "$LIB_DIR/xml-utils.sh"
source "$LIB_DIR/processing-utils.sh"
source "$LIB_DIR/ticket-utils.sh"
source "$LIB_DIR/history-utils.sh"

log_info "🔍 Recherche des fichiers XML non traités..."
echo ""

# Trouver tous les fichiers XML
# Utiliser le JIRA_DIR de la config, ou le chemin relatif depuis le script
if [ -z "${JIRA_DIR:-}" ]; then
    BASE_DIR=$(cd "$SCRIPT_DIR/.." && pwd)
    JIRA_DIR_ACTUAL="$BASE_DIR/Jira"
else
    JIRA_DIR_ACTUAL="$JIRA_DIR"
fi

log_debug "Recherche dans : $JIRA_DIR_ACTUAL"

xml_files=()
while IFS= read -r -d '' xml_file; do
    # Ajouter tous les fichiers .xml trouvés (validation faite plus tard)
    xml_files+=("$xml_file")
done < <(find "$JIRA_DIR_ACTUAL" -type f -name "*.xml" -print0 2>/dev/null)

if [ ${#xml_files[@]} -eq 0 ]; then
    log_error "Aucun fichier XML trouvé dans $JIRA_DIR_ACTUAL"
    exit 1
fi

# Identifier les fichiers non traités
unprocessed=()
processed=()

for xml_file in "${xml_files[@]}"; do
    if is_processed "$xml_file"; then
        processed+=("$xml_file")
    else
        unprocessed+=("$xml_file")
    fi
done

echo "📊 Statistiques :"
echo "   Total fichiers XML : ${#xml_files[@]}"
echo "   ✅ Déjà traités : ${#processed[@]}"
echo "   ⏳ Non traités : ${#unprocessed[@]}"
echo ""

if [ ${#unprocessed[@]} -eq 0 ]; then
    log_success "🎉 Tous les fichiers XML ont déjà été traités !"
    exit 0
fi

echo "📋 Fichiers à traiter :"
for xml_file in "${unprocessed[@]}"; do
    echo "   - $xml_file"
done
echo ""

# Demander confirmation
read -p "Voulez-vous traiter ces ${#unprocessed[@]} fichiers ? (o/N) " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Oo]$ ]]; then
    log_info "Abandonné."
    exit 0
fi

echo ""
log_info "🚀 Début du traitement..."
echo ""

success_count=0
error_count=0

# Traiter chaque fichier
for xml_file in "${unprocessed[@]}"; do
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    log_info "📄 Traitement de : $xml_file"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
    
    if bash "$PROCESS_SCRIPT" "$xml_file"; then
        success_count=$((success_count + 1))
        log_success "✅ Traité avec succès"
    else
        error_count=$((error_count + 1))
        log_error "❌ Erreur lors du traitement"
    fi
    echo ""
done

# Résumé
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
log_info "📊 Résumé du traitement"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
log_success "✅ Succès : $success_count"
if [ $error_count -gt 0 ]; then
    log_error "❌ Erreurs : $error_count"
fi
echo ""

if [ $error_count -eq 0 ] && [ $success_count -gt 0 ]; then
    log_success "🎉 Tous les fichiers ont été traités avec succès !"
    exit 0
elif [ $error_count -gt 0 ]; then
    log_error "⚠️  Certains fichiers ont rencontré des erreurs"
    exit 1
else
    log_info "Aucun fichier à traiter"
    exit 0
fi

