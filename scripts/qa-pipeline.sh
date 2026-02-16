#!/bin/bash

# =============================================================================
# qa-pipeline.sh
# Orchestrateur du pipeline QA automatisé.
#
# Détecte les tickets Jira sans documentation QA, les traite automatiquement
# et marque les tickets comme documentés.
#
# Usage :
#   ./scripts/qa-pipeline.sh [COMMANDE] [OPTIONS]
#
# Commandes :
#   detect       Liste les tickets nécessitant une documentation QA
#   process      Traite un ticket spécifique via l'API Jira
#   process-all  Détecte et traite tous les tickets non documentés
#   status       Affiche l'état du pipeline (tickets traités/en attente)
#   help         Affiche cette aide
#
# Exemples :
#   ./scripts/qa-pipeline.sh detect --projects SPEX,ACCOUNT
#   ./scripts/qa-pipeline.sh process SPEX-3143
#   ./scripts/qa-pipeline.sh process-all --projects SPEX --max 5
# =============================================================================

set -euo pipefail

# ── Configuration ────────────────────────────────────────────────────────────

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BASE_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
CLI_DIR="$BASE_DIR/jira-mcp-server"
CLI_CMD="node $CLI_DIR/dist/cli.js"
PROCESS_SCRIPT="$SCRIPT_DIR/process-from-api.sh"

# Fichier de log pour les erreurs stderr (au lieu de /dev/null)
LOG_DIR="${BASE_DIR}/logs"
mkdir -p "$LOG_DIR" 2>/dev/null || LOG_DIR="/tmp"
LOG_FILE="${LOG_DIR}/qa-pipeline-$(date +%Y%m%d-%H%M%S).log"

# Couleurs
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color
BOLD='\033[1m'

# ── Fonctions utilitaires ────────────────────────────────────────────────────

log_title() { echo -e "\n${BOLD}${CYAN}═══ $1 ═══${NC}\n"; }
log_info()  { echo -e "${BLUE}[INFO]${NC} $1"; }
log_ok()    { echo -e "${GREEN}[OK]${NC} $1"; }
log_warn()  { echo -e "${YELLOW}[WARN]${NC} $1"; }
log_err()   { echo -e "${RED}[ERR]${NC} $1"; }

# ── Vérifications préalables ─────────────────────────────────────────────────

check_prerequisites() {
    local errors=0

    if [ ! -f "$CLI_DIR/dist/cli.js" ]; then
        log_err "CLI Jira non buildé. Lancer : cd jira-mcp-server && npm run build"
        errors=$((errors + 1))
    fi

    if [ ! -f "$CLI_DIR/.env" ]; then
        log_err "Fichier .env manquant dans jira-mcp-server/"
        log_info "  cp jira-mcp-server/.env.example jira-mcp-server/.env"
        log_info "  Puis renseigner JIRA_EMAIL et JIRA_API_TOKEN"
        errors=$((errors + 1))
    fi

    if [ ! -f "$PROCESS_SCRIPT" ]; then
        log_err "Script process-from-api.sh introuvable"
        errors=$((errors + 1))
    fi

    if [ "$errors" -gt 0 ]; then
        log_err "$errors erreur(s) de prérequis. Corriger avant de continuer."
        exit 1
    fi
}

# ── Commande : detect ────────────────────────────────────────────────────────

cmd_detect() {
    local projects=""
    local statuses=""
    local max_results=50
    local format="table"

    while [ $# -gt 0 ]; do
        case "$1" in
            --projects|-p) projects="$2"; shift 2 ;;
            --statuses|-s) statuses="$2"; shift 2 ;;
            --max|-m) max_results="$2"; shift 2 ;;
            --format|-f) format="$2"; shift 2 ;;
            *) if [ -z "$projects" ]; then projects="$1"; fi; shift ;;
        esac
    done

    if [ -z "$projects" ]; then
        log_err "Projets requis. Exemple : --projects SPEX,ACCOUNT,MME"
        exit 1
    fi

    log_title "Détection des tickets sans documentation QA"
    log_info "Projets : $projects"
    [ -n "$statuses" ] && log_info "Statuts : $statuses"
    echo ""

    local cli_args="detect --projects $projects --max $max_results --format $format"
    [ -n "$statuses" ] && cli_args="$cli_args --statuses $statuses"

    cd "$CLI_DIR" && $CLI_CMD $cli_args
}

# ── Commande : process ───────────────────────────────────────────────────────

cmd_process() {
    local ticket_id=""
    local force=false

    while [ $# -gt 0 ]; do
        case "$1" in
            --force) force=true; shift ;;
            *) if [ -z "$ticket_id" ]; then ticket_id="$1"; fi; shift ;;
        esac
    done

    if [ -z "$ticket_id" ]; then
        log_err "TICKET-ID requis. Exemple : process SPEX-3143"
        exit 1
    fi

    log_title "Traitement de $ticket_id"

    local process_args="$ticket_id"
    [ "$force" = true ] && process_args="$process_args --force"

    bash "$PROCESS_SCRIPT" $process_args
}

# ── Commande : process-all ───────────────────────────────────────────────────

cmd_process_all() {
    local projects=""
    local statuses=""
    local max_results=10
    local force=false
    local dry_run=false
    local parallel=0

    while [ $# -gt 0 ]; do
        case "$1" in
            --projects|-p) projects="$2"; shift 2 ;;
            --statuses|-s) statuses="$2"; shift 2 ;;
            --max|-m) max_results="$2"; shift 2 ;;
            --force) force=true; shift ;;
            --dry-run) dry_run=true; shift ;;
            --parallel|-j) parallel="$2"; shift 2 ;;
            *) if [ -z "$projects" ]; then projects="$1"; fi; shift ;;
        esac
    done

    if [ -z "$projects" ]; then
        log_err "Projets requis. Exemple : process-all --projects SPEX,ACCOUNT"
        exit 1
    fi

    # Charger la config centralisée pour les valeurs par défaut
    if [ -f "$SCRIPT_DIR/lib/config.sh" ]; then
        source "$SCRIPT_DIR/lib/config.sh"
    fi
    # Utiliser PARALLEL_WORKERS de config si --parallel non spécifié
    if [ "$parallel" -eq 0 ] && [ -n "${PARALLEL_WORKERS:-}" ] && [ "${PARALLEL_WORKERS:-0}" -gt 0 ]; then
        parallel="$PARALLEL_WORKERS"
    fi

    log_title "Traitement automatique de tous les tickets non documentés"
    log_info "Projets : $projects"
    log_info "Maximum : $max_results tickets"
    [ "$parallel" -gt 1 ] && log_info "Parallélisme : $parallel workers"
    [ "$dry_run" = true ] && log_warn "Mode dry-run : aucune modification"
    echo ""

    # Récupérer la liste des tickets (format : une clé par ligne)
    local cli_args="detect --projects $projects --max $max_results --format keys"
    [ -n "$statuses" ] && cli_args="$cli_args --statuses $statuses"

    local ticket_keys
    ticket_keys=$(cd "$CLI_DIR" && $CLI_CMD $cli_args 2>>"$LOG_FILE") || {
        log_err "Impossible de récupérer la liste des tickets (voir $LOG_FILE)"
        exit 1
    }

    if [ -z "$ticket_keys" ]; then
        log_ok "Tous les tickets sont documentés. Rien à faire."
        exit 0
    fi

    # Compter les tickets
    local count
    count=$(echo "$ticket_keys" | wc -l | tr -d ' ')
    log_info "$count ticket(s) à traiter"
    echo ""

    if [ "$dry_run" = true ]; then
        log_warn "Tickets qui seraient traités :"
        echo "$ticket_keys" | while read -r key; do
            echo "  - $key"
        done
        exit 0
    fi

    # ── Mode parallèle ───────────────────────────────────────────────

    if [ "$parallel" -gt 1 ]; then
        _process_all_parallel "$ticket_keys" "$count" "$force" "$parallel"
        return $?
    fi

    # ── Mode séquentiel (par défaut) ─────────────────────────────────

    # Note : on utilise une redirection <<< au lieu d'un pipe pour éviter
    # d'exécuter la boucle dans un sous-shell (ce qui empêcherait les
    # compteurs de persister après la boucle).
    local success=0
    local failed=0
    local skipped=0

    while read -r key; do
        if [ -z "$key" ]; then continue; fi

        echo ""
        log_title "[$((success + failed + skipped + 1))/$count] Traitement de $key"

        local process_args="$key"
        [ "$force" = true ] && process_args="$process_args --force"

        if bash "$PROCESS_SCRIPT" $process_args 2>&1; then
            success=$((success + 1))
            log_ok "$key traité avec succès"
        else
            failed=$((failed + 1))
            log_err "$key a échoué (non bloquant, on continue)"
        fi
    done <<< "$ticket_keys"

    # Résumé
    _print_summary "$count" "$success" "$failed" "$skipped"
}

# ── Traitement parallèle avec xargs ─────────────────────────────────────────
#
# Chaque ticket est traité dans un sous-processus indépendant.
# Les résultats sont écrits dans des fichiers temporaires pour le résumé.

_process_all_parallel() {
    local ticket_keys="$1"
    local count="$2"
    local force="$3"
    local workers="$4"

    # Créer un répertoire temporaire pour les résultats
    local tmp_dir
    tmp_dir=$(mktemp -d "${TMPDIR:-/tmp}/qa_parallel_XXXXXX")

    # Nettoyage du répertoire temporaire en cas d'interruption (Ctrl+C, kill).
    # En sortie normale, le code en fin de fonction décide s'il faut
    # conserver les logs (en cas d'échecs) ou supprimer le dossier.
    trap 'log_warn "Interruption — nettoyage de $tmp_dir"; rm -rf "$tmp_dir"' INT TERM

    log_info "Traitement parallèle : $workers workers (logs dans $tmp_dir)"
    echo ""

    # Exporter les variables nécessaires aux sous-processus
    export QA_PROCESS_SCRIPT="$PROCESS_SCRIPT"
    export QA_FORCE="$force"
    export QA_TMP_DIR="$tmp_dir"
    export QA_PROCESS_TIMEOUT="${PROCESS_TIMEOUT:-300}"

    # Fonction de traitement d'un ticket (exécutée en parallèle via xargs)
    # Chaque worker écrit un fichier .ok ou .fail dans le tmp_dir
    _process_single_ticket() {
        local key="$1"
        local log_file="$QA_TMP_DIR/${key}.log"
        local process_args="$key"
        [ "$QA_FORCE" = true ] && process_args="$process_args --force"

        echo "[START] $key" >> "$log_file"

        if timeout "$QA_PROCESS_TIMEOUT" bash "$QA_PROCESS_SCRIPT" $process_args > "$log_file" 2>&1; then
            touch "$QA_TMP_DIR/${key}.ok"
            echo "[DONE] $key — succès"
        else
            local exit_code=$?
            touch "$QA_TMP_DIR/${key}.fail"
            if [ "$exit_code" -eq 124 ]; then
                echo "[TIMEOUT] $key — dépassement du timeout (${QA_PROCESS_TIMEOUT}s)"
            else
                echo "[FAIL] $key — code de sortie $exit_code (voir $log_file)"
            fi
        fi
    }
    export -f _process_single_ticket

    # Lancer xargs en parallèle
    echo "$ticket_keys" | xargs -P "$workers" -I {} bash -c '_process_single_ticket "$@"' _ {}

    # Compter les résultats
    local success
    local failed
    success=$(find "$tmp_dir" -name "*.ok" 2>/dev/null | wc -l | tr -d ' ')
    failed=$(find "$tmp_dir" -name "*.fail" 2>/dev/null | wc -l | tr -d ' ')

    _print_summary "$count" "$success" "$failed" "0"

    # Nettoyer si tout a réussi
    if [ "$failed" -eq 0 ]; then
        rm -rf "$tmp_dir"
    else
        log_warn "Logs des échecs conservés dans : $tmp_dir"
    fi
}

_print_summary() {
    local count="$1"
    local success="$2"
    local failed="$3"
    local skipped="$4"

    echo ""
    log_title "Résumé du traitement"
    log_info "Total     : $count"
    [ "$success" -gt 0 ] && log_ok  "Succès    : $success"
    [ "$failed" -gt 0 ]  && log_err "Échoués   : $failed"
    [ "$skipped" -gt 0 ] && log_warn "Ignorés   : $skipped"
}

# ── Commande : status ────────────────────────────────────────────────────────

cmd_status() {
    local projects="${1:-}"

    log_title "État du pipeline QA"

    # Compter les projets traités localement
    local projets_dir="$BASE_DIR/projets"
    if [ -d "$projets_dir" ]; then
        local total_us
        total_us=$(find "$projets_dir" -type d -name "us-*" 2>/dev/null | wc -l | tr -d ' ')
        log_info "Dossiers US locaux : $total_us"

        # Lister par projet
        for project_dir in "$projets_dir"/*/; do
            if [ -d "$project_dir" ]; then
                local project_name
                project_name=$(basename "$project_dir")
                local us_count
                us_count=$(find "$project_dir" -type d -name "us-*" 2>/dev/null | wc -l | tr -d ' ')
                if [ "$us_count" -gt 0 ]; then
                    echo "  $project_name : $us_count US documentées"
                fi
            fi
        done
    else
        log_warn "Aucun dossier projets/ trouvé"
    fi

    echo ""

    # Si des projets sont spécifiés, vérifier aussi côté Jira
    if [ -n "$projects" ]; then
        log_info "Vérification Jira pour $projects..."
        cd "$CLI_DIR" && $CLI_CMD detect --projects "$projects" --format json 2>>"$LOG_FILE" | {
            if command -v python3 &>/dev/null; then
                python3 -c "
import sys, json
try:
    data = json.load(sys.stdin)
    print(f\"  Tickets sans doc QA : {data.get('total', 0)}\")
except:
    print('  Impossible de lire la réponse Jira')
"
            else
                echo "  (installer python3 pour le résumé JSON)"
            fi
        }
    fi
}

# ── Aide ─────────────────────────────────────────────────────────────────────

cmd_help() {
    cat <<'HELP'
QA Pipeline — Orchestrateur de documentation QA automatisée

COMMANDES :

  detect       Liste les tickets nécessitant une documentation QA
               Options : --projects, --statuses, --max, --format (table|json|keys)

  process      Traite un ticket spécifique via l'API Jira
               Options : --force

  process-all  Détecte et traite tous les tickets non documentés
               Options : --projects, --statuses, --max, --force, --dry-run

  status       Affiche l'état du pipeline
               Arguments : [PROJETS] (optionnel)

  help         Affiche cette aide

EXEMPLES :

  # Voir les tickets non documentés
  ./scripts/qa-pipeline.sh detect --projects SPEX,ACCOUNT,MME

  # Traiter un ticket
  ./scripts/qa-pipeline.sh process SPEX-3143

  # Traiter tous les tickets non documentés (max 5)
  ./scripts/qa-pipeline.sh process-all --projects SPEX --max 5

  # Dry-run : voir ce qui serait traité sans rien faire
  ./scripts/qa-pipeline.sh process-all --projects SPEX --dry-run

  # État du pipeline
  ./scripts/qa-pipeline.sh status SPEX,ACCOUNT

PRÉREQUIS :

  1. jira-mcp-server/.env configuré avec les identifiants Jira
  2. CLI buildé : cd jira-mcp-server && npm run build
  3. Ou utiliser : make setup (depuis la racine)
HELP
}

# ── Point d'entrée ───────────────────────────────────────────────────────────

COMMAND="${1:-help}"
shift 2>/dev/null || true

# L'aide ne nécessite pas les prérequis
case "$COMMAND" in
    help|--help|-h)
        cmd_help
        exit 0
        ;;
    status)
        # status fonctionne partiellement sans prérequis (données locales)
        cmd_status "$@"
        exit $?
        ;;
esac

# Toutes les autres commandes nécessitent les prérequis
check_prerequisites

case "$COMMAND" in
    detect)      cmd_detect "$@" ;;
    process)     cmd_process "$@" ;;
    process-all) cmd_process_all "$@" ;;
    status)      cmd_status "$@" ;;
    *)
        log_err "Commande inconnue : $COMMAND"
        echo ""
        cmd_help
        exit 1
        ;;
esac
