#!/bin/bash

# Script pour archiver automatiquement les anciens traitements
# Usage: ./scripts/archive-treatments.sh [OPTIONS]
# Options:
#   --ticket TICKET_KEY    : Archiver un ticket spécifique (ex: SPEX-2990)
#   --project PROJECT      : Archiver tous les tickets d'un projet
#   --older-than DAYS      : Archiver les traitements plus anciens que X jours (défaut: 90)
#   --dry-run              : Afficher ce qui serait archivé sans le faire
#   --list                 : Lister les traitements pouvant être archivés

set -euo pipefail

# Charger les bibliothèques communes
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LIB_DIR="$SCRIPT_DIR/lib"
source "$LIB_DIR/config.sh"
source "$LIB_DIR/common-functions.sh"
source "$LIB_DIR/ticket-utils.sh"
source "$LIB_DIR/processing-utils.sh"
source "$LIB_DIR/history-utils.sh"

# Répertoire d'archivage
ARCHIVES_DIR="$BASE_DIR/archives"
ARCHIVE_HISTORY_FILE="$ARCHIVES_DIR/archive-history.json"

# Initialiser le répertoire d'archivage
init_archive_dir() {
    if [ ! -d "$ARCHIVES_DIR" ]; then
        mkdir -p "$ARCHIVES_DIR"
    fi
    
    if [ ! -f "$ARCHIVE_HISTORY_FILE" ]; then
        echo "{}" > "$ARCHIVE_HISTORY_FILE"
    fi
}

# Archiver un traitement spécifique
# Usage: archive_treatment "SPEX-2990" [dry_run]
archive_treatment() {
    local ticket_key="$1"
    local dry_run="${2:-false}"
    
    # Récupérer les informations du traitement
    local info=$(get_treatment_info "$ticket_key")
    if [ -z "$info" ]; then
        log_warning "Ticket $ticket_key non trouvé dans l'historique"
        return 1
    fi
    
    local us_dir=$(echo "$info" | cut -d'|' -f1)
    local treatment_date=$(echo "$info" | cut -d'|' -f2)
    
    if [ ! -d "$us_dir" ]; then
        log_warning "Dossier $us_dir n'existe plus"
        return 1
    fi
    
    # Déterminer le projet et créer la structure d'archivage
    local project_dir=$(basename "$(dirname "$us_dir")")
    local ticket_number=$(get_ticket_number "$ticket_key")
    local archive_dir="$ARCHIVES_DIR/$project_dir/us-$ticket_number"
    
    if [ "$dry_run" = "true" ]; then
        log_info "DRY-RUN : $ticket_key serait archivé vers $archive_dir"
        return 0
    fi
    
    # Créer le dossier d'archivage
    if ! safe_mkdir "$archive_dir"; then
        log_error "Impossible de créer le dossier d'archivage : $archive_dir"
        return 1
    fi
    
    # Copier le contenu (pas déplacer, pour garder une trace)
    log_info "Archivage de $ticket_key..."
    cp -r "$us_dir"/* "$archive_dir/" 2>/dev/null || {
        log_error "Erreur lors de la copie vers $archive_dir"
        return 1
    }
    
    # Enregistrer dans l'historique d'archivage
    if command -v python3 &> /dev/null; then
        python3 <<EOF
import json
from datetime import datetime

archive_file = "$ARCHIVE_HISTORY_FILE"
ticket_key = "$ticket_key"
us_dir = "$us_dir"
archive_dir = "$archive_dir"
treatment_date = "$treatment_date"
archive_date = datetime.now().strftime("%Y-%m-%d %H:%M:%S")

try:
    with open(archive_file, 'r') as f:
        archive_history = json.load(f)
except (FileNotFoundError, json.JSONDecodeError):
    archive_history = {}

archive_history[ticket_key] = {
    "ticket_key": ticket_key,
    "original_dir": us_dir,
    "archive_dir": archive_dir,
    "treatment_date": treatment_date,
    "archive_date": archive_date
}

with open(archive_file, 'w') as f:
    json.dump(archive_history, f, indent=2, ensure_ascii=False)
EOF
    fi
    
    log_success "✅ $ticket_key archivé vers $archive_dir"
    
    # Optionnel : supprimer le dossier original (décommenter si souhaité)
    # log_info "Suppression du dossier original..."
    # rm -rf "$us_dir"
    
    return 0
}

# Archiver les traitements plus anciens que X jours
# Usage: archive_old_treatments DAYS [dry_run]
archive_old_treatments() {
    local days="${1:-90}"
    local dry_run="${2:-false}"
    
    log_info "Recherche des traitements plus anciens que $days jours..."
    echo ""
    
    if [ ! -f "$HISTORY_FILE" ]; then
        log_warning "Aucun historique trouvé"
        return 0
    fi
    
    local archived_count=0
    
    if command -v python3 &> /dev/null; then
        python3 <<EOF
import json
from datetime import datetime, timedelta

history_file = "$HISTORY_FILE"
days = $days
dry_run = $dry_run == "true"

try:
    with open(history_file, 'r') as f:
        history = json.load(f)
except (FileNotFoundError, json.JSONDecodeError):
    print("Aucun historique trouvé")
    exit(0)

cutoff_date = datetime.now() - timedelta(days=days)
archived = []

for ticket_key, info in history.items():
    try:
        treatment_date = datetime.strptime(info['treatment_date'], "%Y-%m-%d %H:%M:%S")
        if treatment_date < cutoff_date:
            archived.append(ticket_key)
            if dry_run:
                print(f"DRY-RUN : {ticket_key} serait archivé (traité le {info['treatment_date']})")
            else:
                print(f"Archivage de {ticket_key} (traité le {info['treatment_date']})")
    except (KeyError, ValueError):
        continue

if not archived:
    print(f"Aucun traitement plus ancien que {days} jours trouvé")
else:
    print(f"\nTotal : {len(archived)} traitement(s) à archiver")
EOF
    else
        log_warning "Python3 requis pour l'archivage automatique par date"
    fi
}

# Lister les traitements pouvant être archivés
list_archivable() {
    log_info "Traitements pouvant être archivés :"
    echo ""
    
    if [ ! -f "$HISTORY_FILE" ]; then
        log_warning "Aucun historique trouvé"
        return 0
    fi
    
    if command -v python3 &> /dev/null; then
        python3 <<EOF
import json
from datetime import datetime

history_file = "$HISTORY_FILE"

try:
    with open(history_file, 'r') as f:
        history = json.load(f)
except (FileNotFoundError, json.JSONDecodeError):
    print("Aucun historique trouvé")
    exit(0)

print(f"{'Ticket':<20} {'Date traitement':<20} {'Dossier':<50}")
print("-" * 90)

for ticket_key, info in sorted(history.items()):
    print(f"{ticket_key:<20} {info.get('treatment_date', 'N/A'):<20} {info.get('us_dir', 'N/A'):<50}")
EOF
    else
        # Fallback simple
        if [ -f "$HISTORY_FILE" ]; then
            cat "$HISTORY_FILE"
        fi
    fi
}

# Archiver tous les tickets d'un projet
archive_project() {
    local project="$1"
    local dry_run="${2:-false}"
    
    log_info "Archivage de tous les tickets du projet $project..."
    echo ""
    
    if [ ! -f "$HISTORY_FILE" ]; then
        log_warning "Aucun historique trouvé"
        return 0
    fi
    
    if command -v python3 &> /dev/null; then
        python3 <<EOF
import json
import os

history_file = "$HISTORY_FILE"
project = "$project"
dry_run = $dry_run == "true"

try:
    with open(history_file, 'r') as f:
        history = json.load(f)
except (FileNotFoundError, json.JSONDecodeError):
    print("Aucun historique trouvé")
    exit(0)

project_tickets = []
for ticket_key, info in history.items():
    us_dir = info.get('us_dir', '')
    if project.lower() in us_dir.lower():
        project_tickets.append(ticket_key)
        if dry_run:
            print(f"DRY-RUN : {ticket_key} serait archivé")
        else:
            print(f"Archivage de {ticket_key}")

if not project_tickets:
    print(f"Aucun ticket trouvé pour le projet {project}")
else:
    print(f"\nTotal : {len(project_tickets)} ticket(s) du projet {project}")
EOF
    fi
}

# Main
init_archive_dir

# Gestion des arguments
DRY_RUN=false
ACTION=""

while [[ $# -gt 0 ]]; do
    case $1 in
        --ticket)
            TICKET_KEY="$2"
            ACTION="ticket"
            shift 2
            ;;
        --project)
            PROJECT="$2"
            ACTION="project"
            shift 2
            ;;
        --older-than)
            DAYS="$2"
            ACTION="old"
            shift 2
            ;;
        --dry-run)
            DRY_RUN=true
            shift
            ;;
        --list)
            ACTION="list"
            shift
            ;;
        *)
            log_error "Option inconnue : $1"
            echo "Usage: $0 [--ticket TICKET_KEY] [--project PROJECT] [--older-than DAYS] [--dry-run] [--list]"
            exit 1
            ;;
    esac
done

# Exécuter l'action demandée
case $ACTION in
    ticket)
        archive_treatment "$TICKET_KEY" "$DRY_RUN"
        ;;
    project)
        archive_project "$PROJECT" "$DRY_RUN"
        ;;
    old)
        archive_old_treatments "${DAYS:-90}" "$DRY_RUN"
        ;;
    list)
        list_archivable
        ;;
    *)
        log_info "Script d'archivage des traitements"
        echo ""
        echo "Usage: $0 [OPTIONS]"
        echo ""
        echo "Options:"
        echo "  --ticket TICKET_KEY    Archiver un ticket spécifique (ex: SPEX-2990)"
        echo "  --project PROJECT      Archiver tous les tickets d'un projet"
        echo "  --older-than DAYS      Archiver les traitements plus anciens que X jours (défaut: 90)"
        echo "  --dry-run              Afficher ce qui serait archivé sans le faire"
        echo "  --list                 Lister les traitements pouvant être archivés"
        echo ""
        echo "Exemples:"
        echo "  $0 --list                           # Lister tous les traitements"
        echo "  $0 --ticket SPEX-2990                # Archiver SPEX-2990"
        echo "  $0 --ticket SPEX-2990 --dry-run      # Voir ce qui serait archivé"
        echo "  $0 --project SPEX                    # Archiver tous les tickets SPEX"
        echo "  $0 --older-than 180                  # Archiver les traitements > 180 jours"
        ;;
esac

