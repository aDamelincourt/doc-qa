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
JIRA_DIR="${QA_JIRA_DIR:-$BASE_DIR/Jira}"
PROJETS_DIR="${QA_PROJETS_DIR:-$BASE_DIR/projets}"
TEMPLATES_DIR="${QA_TEMPLATES_DIR:-$BASE_DIR/templates}"
SCRIPTS_DIR="${QA_SCRIPTS_DIR:-$BASE_DIR/scripts}"

# Paramètres configurables
MAX_DESCRIPTION_LINES="${QA_MAX_DESCRIPTION_LINES:-200}"
MAX_SCENARIOS="${QA_MAX_SCENARIOS:-10}"
MAX_COMMENTS="${QA_MAX_COMMENTS:-100}"

# Niveau de debug (peut être activé avec DEBUG=true)
DEBUG="${DEBUG:-false}"

# Mode dry-run (peut être activé avec DRY_RUN=true)
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

