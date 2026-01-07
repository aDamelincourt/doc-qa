#!/bin/bash

# Script pour régénérer tous les documents QA à partir des exports XML existants
# Usage: ./scripts/regenerate-all-docs.sh [--force]

set -euo pipefail

# Charger les bibliothèques communes
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LIB_DIR="$SCRIPT_DIR/lib"
source "$LIB_DIR/config.sh"
source "$LIB_DIR/common-functions.sh"
source "$LIB_DIR/xml-utils.sh"
source "$LIB_DIR/processing-utils.sh"
source "$LIB_DIR/ticket-utils.sh"

# Gestion des arguments
FORCE=false
if [ "${1:-}" == "--force" ]; then
    FORCE=true
fi

log_info "Régénération de tous les documents QA à partir des exports XML..."
echo ""

# Valider le répertoire Jira
if ! validate_directory "$JIRA_DIR"; then
    exit 1
fi

# Trouver tous les fichiers XML
xml_files=()
while IFS= read -r -d '' xml_file; do
    if validate_xml "$xml_file" 2>/dev/null; then
        xml_files+=("$xml_file")
    else
        log_warning "Fichier XML invalide ignoré : $xml_file"
    fi
done < <(find "$JIRA_DIR" -type f -name "*.xml" -print0 2>/dev/null)

if [ ${#xml_files[@]} -eq 0 ]; then
    log_error "Aucun fichier XML trouvé dans $JIRA_DIR"
    exit 1
fi

log_info "Fichiers XML trouvés : ${#xml_files[@]}"
echo ""

# Optimisation #2 : Pré-calculer tous les dossiers us-XXXX une seule fois
log_info "Pré-calcul des dossiers US existants..."
declare -A US_DIRS_CACHE
for project_dir in "$PROJETS_DIR"/*/; do
    if [ ! -d "$project_dir" ]; then
        continue
    fi
    project=$(basename "$project_dir")
    while IFS= read -r -d '' us_dir; do
        ticket_num=$(basename "$us_dir" | sed 's/^us-//')
        if [ -n "$ticket_num" ]; then
            US_DIRS_CACHE["${project}-${ticket_num}"]="$us_dir"
        fi
    done < <(find "$project_dir" -type d -name "us-*" -print0 2>/dev/null)
done
log_debug "Cache US_DIRS_CACHE initialisé avec ${#US_DIRS_CACHE[@]} entrées"
echo ""

# Compteurs
processed_count=0
skipped_count=0
error_count=0

# Traiter chaque fichier XML
for xml_file in "${xml_files[@]}"; do
    # Parser le XML
    if ! parse_xml_file "$xml_file" 2>/dev/null; then
        log_error "Impossible d'extraire les informations de : $xml_file"
        error_count=$((error_count + 1))
        continue
    fi
    
    project=$(basename "$(dirname "$xml_file")")
    ticket_number=$(get_ticket_number "$KEY")
    
    # Utiliser le cache au lieu de find
    us_dir="${US_DIRS_CACHE[${project}-${ticket_number}]:-}"
    
    # Si non trouvé dans le cache, utiliser l'ancienne structure (rétrocompatibilité)
    if [ -z "$us_dir" ]; then
        us_dir="$PROJETS_DIR/$project/us-$ticket_number"
    fi
    
    log_info "Traitement de $project/$KEY : $TITLE"
    
    # Vérifier si l'US existe déjà
    if [ -d "$us_dir" ]; then
        if [ "$FORCE" = false ]; then
            log_warning "  US existe déjà : $us_dir"
            log_info "  Utilisez --force pour forcer la régénération"
            skipped_count=$((skipped_count + 1))
            echo ""
            continue
        else
            log_warning "  Régénération forcée de l'US existante"
        fi
    fi
    
    # Créer/régénérer la structure
    if [ "$DRY_RUN" != "true" ]; then
        # Créer le dossier si nécessaire
        if ! safe_mkdir "$us_dir"; then
            log_error "  Impossible de créer le dossier : $us_dir"
            error_count=$((error_count + 1))
            echo ""
            continue
        fi
        
        # Régénérer tous les documents
        log_info "  Régénération des documents..."
        
        # 1. Extraction Jira
        EXTRACTION_FILE="$us_dir/extraction-jira.md"
        DESCRIPTION=$(extract_description "$xml_file" 20)
        cat > "$EXTRACTION_FILE" <<EOF
# Extraction Jira - $KEY

## 📋 Informations générales

**Clé du ticket** : $KEY
**Titre/Summary** : $TITLE
**Type** : Story
**Statut** : [À extraire manuellement]
**Lien Jira** : $LINK

## 📝 Description / User Story

\`\`\`
$(echo "$DESCRIPTION" | head -100)
\`\`\`

> **Note** : Description complète disponible dans le fichier XML : \`../Jira/$project/$(basename "$xml_file")\`

## ✅ Critères d'acceptation

[À extraire manuellement depuis le XML - section Acceptance Criteria]

## 💻 Informations techniques

[À extraire manuellement depuis les commentaires du XML]

## 🎨 Designs

[À extraire manuellement depuis le XML - liens Figma]

## 📝 Commentaires de l'équipe

[À extraire manuellement depuis le XML - balise <comment>]

---

**Date d'extraction** : $(date +"%Y-%m-%d")
**Fichier source** : Jira/$project/$(basename "$xml_file")
EOF
        
        # 2. Questions et Clarifications
        log_info "    - Génération des questions de clarifications..."
        "$GENERATE_QUESTIONS_SCRIPT" "$us_dir" || {
            log_error "    Erreur lors de la génération des questions"
            error_count=$((error_count + 1))
            continue
        }
        
        # 3. Stratégie de Test
        log_info "    - Génération de la stratégie de test..."
        "$GENERATE_STRATEGY_SCRIPT" "$us_dir" || {
            log_error "    Erreur lors de la génération de la stratégie"
            error_count=$((error_count + 1))
            continue
        }
        
        # 4. Cas de Test
        log_info "    - Génération des cas de test..."
        "$GENERATE_TEST_CASES_SCRIPT" "$us_dir" || {
            log_error "    Erreur lors de la génération des cas de test"
            error_count=$((error_count + 1))
            continue
        }
        
        # 5. README
        log_info "    - Mise à jour du README..."
        if [ ! -f "$us_dir/README.md" ]; then
            if validate_file "$TEMPLATES_DIR/us-readme-template.md"; then
                cp "$TEMPLATES_DIR/us-readme-template.md" "$us_dir/README.md"
            fi
        fi
        "$UPDATE_README_SCRIPT" "$us_dir" || {
            log_warning "    Erreur lors de la mise à jour du README (non bloquant)"
        }
        
        processed_count=$((processed_count + 1))
        log_success "  $KEY traité avec succès"
    else
        log_info "  DRY-RUN : Les documents seraient régénérés pour $KEY"
        processed_count=$((processed_count + 1))
    fi
    
    echo ""
done

# Résumé
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
log_info "Résumé de la régénération"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "Total fichiers XML : ${#xml_files[@]}"
log_success "✓ Traités : $processed_count"
if [ "$skipped_count" -gt 0 ]; then
    log_warning "⚠ Ignorés (déjà existants) : $skipped_count"
    echo "   Utilisez --force pour forcer la régénération"
fi
if [ "$error_count" -gt 0 ]; then
    log_error "✗ Erreurs : $error_count"
fi
echo ""

if [ "$error_count" -eq 0 ] && [ "$processed_count" -gt 0 ]; then
    log_success "Régénération terminée avec succès !"
    exit 0
elif [ "$error_count" -gt 0 ]; then
    log_error "Régénération terminée avec des erreurs"
    exit 1
else
    log_info "Aucun fichier à traiter"
    exit 0
fi

