#!/bin/bash

# Script pour exporter l'ensemble du dossier "projets" au format CSV pour l'import dans Notion
# Usage: ./scripts/export-to-notion.sh [--force] [--output FILE.csv]

set -euo pipefail

# Charger les bibliothèques communes
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LIB_DIR="$SCRIPT_DIR/lib"
source "$LIB_DIR/config.sh"
source "$LIB_DIR/common-functions.sh"
source "$LIB_DIR/ticket-utils.sh"
source "$LIB_DIR/history-utils.sh"

# Gestion des arguments
FORCE=false
OUTPUT_FILE=""
if [ "${1:-}" == "--force" ]; then
    FORCE=true
    shift
fi
if [ "${1:-}" == "--output" ] && [ -n "${2:-}" ]; then
    OUTPUT_FILE="$2"
    shift 2
fi

# Définir le fichier de sortie par défaut
if [ -z "$OUTPUT_FILE" ]; then
    BASE_DIR=$(get_base_dir)
    OUTPUT_FILE="$BASE_DIR/exports/notion-export-$(date +%Y%m%d-%H%M%S).csv"
fi

# Créer le répertoire d'export si nécessaire
EXPORT_DIR=$(dirname "$OUTPUT_FILE")
if [ ! -d "$EXPORT_DIR" ]; then
    mkdir -p "$EXPORT_DIR" || {
        log_error "Impossible de créer le répertoire d'export : $EXPORT_DIR"
        exit 1
    }
fi

# Fichier d'historique des exports
HISTORY_FILE="$BASE_DIR/.history/exports-notion.json"

# Initialiser l'historique si nécessaire
if [ ! -f "$HISTORY_FILE" ]; then
    echo "{}" > "$HISTORY_FILE"
fi

# Fonction pour vérifier si une clé est déjà exportée (compatible Bash 3.x)
is_key_exported() {
    local ticket_key="$1"
    if [ ! -f "$HISTORY_FILE" ]; then
        return 1
    fi
    grep -q "\"$ticket_key\"" "$HISTORY_FILE" 2>/dev/null
}

log_info "📤 Export vers Notion CSV..."
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

# Fonction pour extraire le contenu d'un fichier markdown (limité)
extract_markdown_content() {
    local file="$1"
    local max_chars="${2:-5000}"
    
    if [ ! -f "$file" ]; then
        echo ""
        return 0
    fi
    
    # Extraire le contenu, enlever les balises markdown complexes, limiter la taille
    local content=$(cat "$file" | sed 's/^#* //g' | sed 's/\*\*//g' | sed 's/`//g' | tr '\n' ' ' | sed 's/  */ /g')
    
    # Limiter la longueur
    if [ ${#content} -gt $max_chars ]; then
        content="${content:0:$max_chars}..."
    fi
    
    # Échapper les guillemets et retours à la ligne pour CSV
    echo "$content" | sed 's/"/""/g' | sed 's/\n/ /g' | sed 's/\r//g'
}

# Fonction pour extraire la clé du ticket depuis un dossier US
get_ticket_key_from_us_dir() {
    local us_dir="$1"
    
    # Essayer depuis extraction-jira.md
    local extraction_file="$us_dir/extraction-jira.md"
    if [ -f "$extraction_file" ]; then
        local key=$(grep "^\*\*Clé du ticket\*\*" "$extraction_file" 2>/dev/null | sed 's/.*: //' | sed 's/[[:space:]]*$//' | head -1)
        if [ -n "$key" ]; then
            echo "$key"
            return 0
        fi
    fi
    
    # Utiliser la fonction de ticket-utils
    if command -v get_ticket_key_from_path &> /dev/null; then
        local key=$(get_ticket_key_from_path "$us_dir" 2>/dev/null)
        if [ -n "$key" ]; then
            echo "$key"
            return 0
        fi
    fi
    
    return 1
}

# Fonction pour extraire le titre depuis README.md
extract_title() {
    local readme_file="$1"
    if [ ! -f "$readme_file" ]; then
        echo ""
        return 0
    fi
    
    # Chercher le titre dans le README (format: # TICKET - Titre)
    local title=$(head -5 "$readme_file" | grep -E "^# " | sed 's/^# //' | sed 's/^[A-Z]\+-[0-9]\+ - //' | head -1)
    if [ -z "$title" ]; then
        # Essayer depuis extraction-jira.md
        local extraction_file="$(dirname "$readme_file")/extraction-jira.md"
        if [ -f "$extraction_file" ]; then
            title=$(grep "^\*\*Titre/Summary\*\*" "$extraction_file" 2>/dev/null | sed 's/.*: //' | sed 's/[[:space:]]*$//' | head -1)
        fi
    fi
    echo "$title"
}

# Fonction pour extraire la description depuis README.md
extract_description() {
    local readme_file="$1"
    if [ ! -f "$readme_file" ]; then
        echo ""
        return 0
    fi
    
    # Extraire la section Description
    local desc=$(awk '/^## 📝 Description/,/^---/' "$readme_file" 2>/dev/null | grep -v "^##" | grep -v "^---" | head -20 | tr '\n' ' ' | sed 's/  */ /g')
    if [ -z "$desc" ]; then
        # Essayer depuis extraction-jira.md
        local extraction_file="$(dirname "$readme_file")/extraction-jira.md"
        if [ -f "$extraction_file" ]; then
            desc=$(awk '/^## 📝 Description/,/^---/' "$extraction_file" 2>/dev/null | grep -v "^##" | grep -v "^---" | head -20 | tr '\n' ' ' | sed 's/  */ /g')
        fi
    fi
    
    # Limiter et échapper pour CSV
    if [ ${#desc} -gt 2000 ]; then
        desc="${desc:0:2000}..."
    fi
    echo "$desc" | sed 's/"/""/g' | sed 's/\n/ /g' | sed 's/\r//g'
}

# Fonction pour extraire le lien Jira
extract_jira_link() {
    local us_dir="$1"
    local extraction_file="$us_dir/extraction-jira.md"
    
    if [ -f "$extraction_file" ]; then
        local link=$(grep "^\*\*Lien Jira\*\*" "$extraction_file" 2>/dev/null | sed 's/.*: //' | sed 's/[[:space:]]*$//' | head -1)
        if [ -n "$link" ]; then
            echo "$link"
            return 0
        fi
    fi
    
    # Essayer depuis README.md
    local readme_file="$us_dir/README.md"
    if [ -f "$readme_file" ]; then
        local link=$(grep "Lien Jira/Ticket" "$readme_file" 2>/dev/null | sed 's/.*: //' | sed 's/[[:space:]]*$//' | head -1)
        if [ -n "$link" ]; then
            echo "$link"
            return 0
        fi
    fi
    
    echo ""
}

# Fonction pour obtenir la date de traitement
get_treatment_date() {
    local ticket_key="$1"
    local history_file="$BASE_DIR/.history/traitements.json"
    
    if [ -f "$history_file" ]; then
        local date=$(grep -A 5 "\"$ticket_key\"" "$history_file" 2>/dev/null | grep "treatment_date" | sed 's/.*: "//' | sed 's/".*//' | head -1)
        if [ -n "$date" ]; then
            echo "$date"
            return 0
        fi
    fi
    
    # Fallback : date de modification du README
    echo ""
}

# Préparer le CSV avec les en-têtes
CSV_TEMP=$(mktemp)
cat > "$CSV_TEMP" << 'CSV_HEADER'
Name,Ticket Key,Project,Description,Questions,Strategy,Test Cases,Status,Link,Created Date,Last Updated
CSV_HEADER

# Compteurs
exported_count=0
skipped_count=0
error_count=0

# Traiter chaque dossier US
for us_dir in "${us_dirs[@]}"; do
    # Extraire la clé du ticket
    ticket_key=$(get_ticket_key_from_us_dir "$us_dir" 2>/dev/null || echo "")
    
    if [ -z "$ticket_key" ]; then
        log_warning "Impossible d'extraire la clé du ticket pour : $us_dir"
        error_count=$((error_count + 1))
        continue
    fi
    
    # Vérifier si déjà exporté (sauf si --force)
    if [ "$FORCE" = false ] && is_key_exported "$ticket_key"; then
        log_debug "Déjà exporté (ignoré) : $ticket_key"
        skipped_count=$((skipped_count + 1))
        continue
    fi
    
    log_info "📄 Traitement de : $ticket_key"
    
    # Extraire les informations
    readme_file="$us_dir/README.md"
    title=$(extract_title "$readme_file")
    if [ -z "$title" ]; then
        title="$ticket_key"
    fi
    
    description=$(extract_description "$readme_file")
    questions=$(extract_markdown_content "$us_dir/01-questions-clarifications.md" 3000)
    strategy=$(extract_markdown_content "$us_dir/02-strategie-test.md" 3000)
    test_cases=$(extract_markdown_content "$us_dir/03-cas-test.md" 5000)
    link=$(extract_jira_link "$us_dir")
    created_date=$(get_treatment_date "$ticket_key")
    last_updated=$(stat -f "%Sm" -t "%Y-%m-%d" "$readme_file" 2>/dev/null || stat -c "%y" "$readme_file" 2>/dev/null | cut -d' ' -f1 || echo "")
    
    # Extraire le projet depuis la clé (ex: MME-1332 -> MME)
    project=$(echo "$ticket_key" | sed 's/-[0-9]*$//')
    
    # Statut par défaut
    status="Draft"
    
    # Écrire la ligne CSV (échapper les guillemets et virgules)
    {
        echo -n "\"$title\","
        echo -n "\"$ticket_key\","
        echo -n "\"$project\","
        echo -n "\"$description\","
        echo -n "\"$questions\","
        echo -n "\"$strategy\","
        echo -n "\"$test_cases\","
        echo -n "\"$status\","
        echo -n "\"$link\","
        echo -n "\"$created_date\","
        echo "\"$last_updated\""
    } >> "$CSV_TEMP"
    
    exported_count=$((exported_count + 1))
    
    # Mettre à jour l'historique
    if [ "$FORCE" = false ]; then
        # Ajouter à l'historique (format JSON simple)
        if ! is_key_exported "$ticket_key"; then
            # Ajouter la clé à l'historique en utilisant Python pour gérer le JSON proprement
            python3 << PYTHON_SCRIPT
import json
import sys
from datetime import datetime

history_file = "$HISTORY_FILE"
ticket_key = "$ticket_key"
export_date = datetime.now().strftime("%Y-%m-%d")

try:
    with open(history_file, 'r') as f:
        history = json.load(f)
except (FileNotFoundError, json.JSONDecodeError):
    history = {}

if ticket_key not in history:
    history[ticket_key] = {
        "export_date": export_date,
        "export_file": "$OUTPUT_FILE"
    }
    
    with open(history_file, 'w') as f:
        json.dump(history, f, indent=2)
PYTHON_SCRIPT
        fi
    fi
done

# Déplacer le fichier temporaire vers le fichier de sortie
mv "$CSV_TEMP" "$OUTPUT_FILE"

# Résumé
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
log_info "📊 Résumé de l'export"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
log_success "✅ Exportés : $exported_count"
if [ $skipped_count -gt 0 ]; then
    log_info "⏭️  Ignorés (déjà exportés) : $skipped_count"
fi
if [ $error_count -gt 0 ]; then
    log_error "❌ Erreurs : $error_count"
fi
echo ""
log_success "📁 Fichier CSV créé : $OUTPUT_FILE"
echo ""
log_info "💡 Pour importer dans Notion :"
echo "   1. Ouvrir Notion"
echo "   2. Créer une nouvelle base de données"
echo "   3. Importer depuis CSV"
echo "   4. Sélectionner le fichier : $OUTPUT_FILE"
echo ""

