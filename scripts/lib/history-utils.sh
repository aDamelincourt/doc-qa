#!/bin/bash

# Bibliothèque de fonctions pour gérer l'historisation des traitements
# Usage: source "$(dirname "${BASH_SOURCE[0]}")/lib/history-utils.sh"

# Charger les fonctions communes
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
if [ -f "$SCRIPT_DIR/config.sh" ]; then
    source "$SCRIPT_DIR/config.sh"
else
    echo "❌ Erreur : Impossible de charger config.sh" >&2
    exit 1
fi

# Répertoire d'historisation
HISTORY_DIR="${BASE_DIR}/.history"
HISTORY_FILE="${HISTORY_DIR}/traitements.json"

# Initialiser le système d'historisation
init_history() {
    if [ ! -d "$HISTORY_DIR" ]; then
        mkdir -p "$HISTORY_DIR"
    fi
    
    if [ ! -f "$HISTORY_FILE" ]; then
        echo "{}" > "$HISTORY_FILE"
    fi
}

# Enregistrer un traitement
# Usage: record_treatment "SPEX-2990" "projets/SPEX/support/us-2990" "2024-01-15"
# Optionnel (pour Notion / rapports) : export RECORD_PROJECT_KEY, RECORD_PARENT_KEY, RECORD_ISSUE_TYPE avant l'appel
record_treatment() {
    local ticket_key="$1"
    local us_dir="$2"
    local treatment_date="${3:-$(date +"%Y-%m-%d %H:%M:%S")}"
    
    init_history
    
    # Utiliser Python ou jq si disponible, sinon utiliser sed/awk
    if command -v python3 &> /dev/null; then
        python3 <<PYEOF
import json
import os

history_file = "$HISTORY_FILE"
ticket_key = "$ticket_key"
us_dir = "$us_dir"
treatment_date = "$treatment_date"

try:
    with open(history_file, 'r') as f:
        history = json.load(f)
except (FileNotFoundError, json.JSONDecodeError):
    history = {}

entry = {
    "ticket_key": ticket_key,
    "us_dir": us_dir,
    "treatment_date": treatment_date,
    "last_update": treatment_date
}
# Métadonnées optionnelles (projet, EPIC, type) pour sync-notion et rapports
if os.environ.get("RECORD_PROJECT_KEY"):
    entry["projectKey"] = os.environ.get("RECORD_PROJECT_KEY", "").strip()
if os.environ.get("RECORD_PARENT_KEY"):
    entry["parentKey"] = os.environ.get("RECORD_PARENT_KEY", "").strip()
if os.environ.get("RECORD_ISSUE_TYPE"):
    entry["issuetype"] = os.environ.get("RECORD_ISSUE_TYPE", "").strip()

history[ticket_key] = entry

with open(history_file, 'w') as f:
    json.dump(history, f, indent=2, ensure_ascii=False)

print(f"✅ Traitement enregistré : {ticket_key}")
PYEOF
    elif command -v jq &> /dev/null; then
        local temp_file=$(mktemp)
        jq --arg key "$ticket_key" \
           --arg dir "$us_dir" \
           --arg date "$treatment_date" \
           --arg proj "${RECORD_PROJECT_KEY:-}" \
           --arg parent "${RECORD_PARENT_KEY:-}" \
           --arg itype "${RECORD_ISSUE_TYPE:-}" \
           '.[$key] = {
             "ticket_key": $key,
             "us_dir": $dir,
             "treatment_date": $date,
             "last_update": $date,
             "projectKey": $proj,
             "parentKey": $parent,
             "issuetype": $itype
           }' "$HISTORY_FILE" > "$temp_file" && mv "$temp_file" "$HISTORY_FILE"
        echo "✅ Traitement enregistré : $ticket_key"
    else
        # Fallback : utiliser un format simple (une ligne par traitement)
        echo "$ticket_key|$us_dir|$treatment_date" >> "${HISTORY_DIR}/traitements.txt"
        echo "✅ Traitement enregistré : $ticket_key"
    fi
}

# Récupérer les informations d'un traitement
# Usage: get_treatment_info "SPEX-2990"
get_treatment_info() {
    local ticket_key="$1"
    
    if [ ! -f "$HISTORY_FILE" ]; then
        return 1
    fi
    
    if command -v python3 &> /dev/null; then
        python3 <<EOF
import json
import sys

history_file = "$HISTORY_FILE"
ticket_key = "$ticket_key"

try:
    with open(history_file, 'r') as f:
        history = json.load(f)
    
    if ticket_key in history:
        info = history[ticket_key]
        print(f"{info['us_dir']}|{info['treatment_date']}|{info.get('last_update', '')}")
        sys.exit(0)
    else:
        sys.exit(1)
except (FileNotFoundError, json.JSONDecodeError, KeyError):
    sys.exit(1)
EOF
    elif command -v jq &> /dev/null; then
        jq -r --arg key "$ticket_key" \
           'if .[$key] then "\(.[$key].us_dir)|\(.[$key].treatment_date)|\(.[$key].last_update // "")" else empty end' \
           "$HISTORY_FILE"
    else
        # Fallback : chercher dans le fichier texte
        grep "^${ticket_key}|" "${HISTORY_DIR}/traitements.txt" 2>/dev/null | head -1 | cut -d'|' -f2-
    fi
}

# Vérifier si un ticket a déjà été traité
# Usage: is_ticket_processed "SPEX-2990"
is_ticket_processed() {
    local ticket_key="$1"
    local info=$(get_treatment_info "$ticket_key")
    
    if [ -n "$info" ]; then
        local us_dir=$(echo "$info" | cut -d'|' -f1)
        if [ -d "$us_dir" ] && [ -f "$us_dir/README.md" ]; then
            return 0  # Traité
        fi
    fi
    
    return 1  # Non traité
}

# Lister tous les traitements
# Usage: list_treatments
list_treatments() {
    if [ ! -f "$HISTORY_FILE" ]; then
        echo "Aucun traitement enregistré"
        return
    fi
    
    if command -v python3 &> /dev/null; then
        python3 <<EOF
import json

history_file = "$HISTORY_FILE"

try:
    with open(history_file, 'r') as f:
        history = json.load(f)
    
    for key, info in sorted(history.items()):
        print(f"{key:20} | {info['us_dir']:50} | {info['treatment_date']}")
except (FileNotFoundError, json.JSONDecodeError):
    print("Aucun traitement enregistré")
EOF
    elif command -v jq &> /dev/null; then
        jq -r 'to_entries | .[] | "\(.key)|\(.value.us_dir)|\(.value.treatment_date)"' "$HISTORY_FILE" | \
        while IFS='|' read -r key dir date; do
            printf "%-20s | %-50s | %s\n" "$key" "$dir" "$date"
        done
    else
        # Fallback : afficher le fichier texte
        if [ -f "${HISTORY_DIR}/traitements.txt" ]; then
            cat "${HISTORY_DIR}/traitements.txt"
        else
            echo "Aucun traitement enregistré"
        fi
    fi
}

# Déterminer le sous-dossier pour une US
# Usage: get_subdirectory "ACCOUNT-3182" "SPIKE / PREPA: Interface de gestion"
get_subdirectory() {
    local ticket_key="$1"
    local title="${2:-}"
    
    # Extraire le type depuis le titre (SPIKE, BUG, FEATURE, etc.)
    local ticket_type=""
    if echo "$title" | grep -qi "spike\|prepa\|preparation"; then
        ticket_type="spikes"
    elif echo "$title" | grep -qi "bug\|fix"; then
        ticket_type="bugs"
    elif echo "$title" | grep -qi "feature\|story"; then
        ticket_type="features"
    else
        # Par défaut, utiliser "support" ou le nom du projet en minuscules
        local project_prefix=$(echo "$ticket_key" | sed 's/-[0-9]*$//' | tr '[:upper:]' '[:lower:]')
        ticket_type="support"
    fi
    
    echo "$ticket_type"
}

