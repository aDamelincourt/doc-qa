#!/bin/bash

# Configuration centralisée pour les scripts QA
# Usage: source "$(dirname "${BASH_SOURCE[0]}")/lib/config.sh"

# Charger les fonctions communes
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
if [ -f "$SCRIPT_DIR/common-functions.sh" ]; then
    source "$SCRIPT_DIR/common-functions.sh"
else
    # Si common-functions.sh n'existe pas encore, définir get_base_dir manuellement
    get_base_dir() {
        # SCRIPT_DIR pointe vers scripts/lib, donc on remonte de 2 niveaux
        local script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
        if [[ "$script_dir" == */scripts/lib ]]; then
            echo "$(cd "$script_dir/../.." && pwd)"
        else
            echo "$(cd "$script_dir/.." && pwd)"
        fi
    }
fi

# Chemins de base (peuvent être surchargés par variables d'environnement)
BASE_DIR="${QA_BASE_DIR:-$(get_base_dir)}"

# ── Charger project.conf (configuration centralisée) ─────────────────────────
# Les variables d'environnement existantes ont priorité sur project.conf.
_PROJECT_CONF="$BASE_DIR/config/project.conf"
if [ -f "$_PROJECT_CONF" ]; then
    # Charger chaque ligne KEY=VALUE sans écraser les variables déjà définies
    while IFS='=' read -r _key _value; do
        # Ignorer les commentaires et lignes vides
        [[ "$_key" =~ ^[[:space:]]*# ]] && continue
        [[ -z "$_key" ]] && continue
        # Trim les espaces
        _key=$(echo "$_key" | xargs)
        _value=$(echo "$_value" | xargs)
        # Ne pas écraser si la variable est déjà définie dans l'environnement
        if [ -z "${!_key+x}" ]; then
            export "$_key=$_value"
        fi
    done < "$_PROJECT_CONF"
fi

# ── Charger .env à la racine (secrets, ex. CURSOR_API_KEY) ───────────────────
# Ne pas écraser les variables déjà définies. Ne pas commiter .env (voir .gitignore).
_ENV_FILE="$BASE_DIR/.env"
if [ -f "$_ENV_FILE" ]; then
    while IFS='=' read -r _key _value; do
        [[ "$_key" =~ ^[[:space:]]*# ]] && continue
        [[ -z "$_key" ]] && continue
        _key=$(echo "$_key" | xargs)
        _value=$(echo "$_value" | xargs)
        if [ -z "${!_key+x}" ]; then
            export "$_key=$_value"
        fi
    done < "$_ENV_FILE"
fi

# ── Chemins ──────────────────────────────────────────────────────────────────

JIRA_DIR="${QA_JIRA_DIR:-$BASE_DIR/${JIRA_SUBDIR:-Jira}}"
PROJETS_DIR="${QA_PROJETS_DIR:-$BASE_DIR/${PROJETS_SUBDIR:-projets}}"
TEMPLATES_DIR="${QA_TEMPLATES_DIR:-$BASE_DIR/${TEMPLATES_SUBDIR:-templates}}"
SCRIPTS_DIR="${QA_SCRIPTS_DIR:-$BASE_DIR/scripts}"

# ── Jira ─────────────────────────────────────────────────────────────────────

JIRA_BASE_URL="${QA_JIRA_BASE_URL:-${JIRA_BASE_URL:-https://prestashop-jira.atlassian.net}}"
QA_DOCUMENTED_LABEL="${QA_DOCUMENTED_LABEL:-qa-documented}"

# ── Pipeline ─────────────────────────────────────────────────────────────────

PARALLEL_WORKERS="${PARALLEL_WORKERS:-0}"
PROCESS_TIMEOUT="${PROCESS_TIMEOUT:-300}"

# ── Limites de contenu ───────────────────────────────────────────────────────

MAX_DESCRIPTION_LINES="${QA_MAX_DESCRIPTION_LINES:-${MAX_DESCRIPTION_LINES:-200}}"
MAX_SCENARIOS="${QA_MAX_SCENARIOS:-${MAX_SCENARIOS:-10}}"
MAX_COMMENTS="${QA_MAX_COMMENTS:-${MAX_COMMENTS:-100}}"

# ── Qualité des documents ────────────────────────────────────────────────────

QA_MIN_FILE_SIZE="${QA_MIN_FILE_SIZE:-${MIN_FILE_SIZE:-200}}"
QA_MIN_SCENARIOS="${QA_MIN_SCENARIOS:-${MIN_SCENARIOS:-2}}"
QA_MIN_QUESTIONS="${QA_MIN_QUESTIONS:-${MIN_QUESTIONS:-5}}"

# ── Modes ────────────────────────────────────────────────────────────────────

DEBUG="${DEBUG:-false}"
DRY_RUN="${DRY_RUN:-false}"

# Chemins des scripts (centralisés pour maintenabilité)
GENERATE_QUESTIONS_SCRIPT="$SCRIPTS_DIR/generate-questions-from-xml.sh"
GENERATE_STRATEGY_SCRIPT="$SCRIPTS_DIR/generate-strategy-from-xml.sh"
GENERATE_TEST_CASES_SCRIPT="$SCRIPTS_DIR/generate-test-cases-from-xml.sh"
GENERATE_WITH_CURSOR_SCRIPT="$SCRIPTS_DIR/generate-with-cursor.sh"
GENERATE_ALL_WITH_CURSOR_SCRIPT="$SCRIPTS_DIR/generate-all-with-cursor.sh"
UPDATE_README_SCRIPT="$SCRIPTS_DIR/update-readme-from-xml.sh"
UPDATE_ALL_READMES_SCRIPT="$SCRIPTS_DIR/update-all-readmes.sh"
REGENERATE_ALL_DOCS_SCRIPT="$SCRIPTS_DIR/regenerate-all-docs.sh"
ARCHIVE_TREATMENTS_SCRIPT="$SCRIPTS_DIR/archive-treatments.sh"
GENERATE_FROM_CONTEXT_SCRIPT="$SCRIPTS_DIR/generate-from-context.sh"
PROCESS_FROM_API_SCRIPT="$SCRIPTS_DIR/process-from-api.sh"
QA_PIPELINE_SCRIPT="$SCRIPTS_DIR/qa-pipeline.sh"

# Fonction pour afficher la configuration
show_config() {
    echo "📋 Configuration QA :"
    echo "   BASE_DIR: $BASE_DIR"
    echo "   JIRA_DIR: $JIRA_DIR"
    echo "   PROJETS_DIR: $PROJETS_DIR"
    echo "   TEMPLATES_DIR: $TEMPLATES_DIR"
    echo "   MAX_DESCRIPTION_LINES: $MAX_DESCRIPTION_LINES"
    echo "   MAX_SCENARIOS: $MAX_SCENARIOS"
    echo "   DEBUG: $DEBUG"
    echo "   DRY_RUN: $DRY_RUN"
}

