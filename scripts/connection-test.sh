#!/bin/bash

# =============================================================================
# connection-test.sh
# Teste la connexion à Jira Cloud et Xray Cloud (lecture, optionnellement écriture).
# Délègue au CLI jira-mcp-server qui charge son .env depuis jira-mcp-server/.env.
#
# Usage :
#   ./scripts/connection-test.sh
#   ./scripts/connection-test.sh --jira-only
#   ./scripts/connection-test.sh --xray-only
#   ./scripts/connection-test.sh --write --ticket SPEX-3143
#
# Options (transmises au CLI) :
#   --jira-only   Ne tester que Jira Cloud
#   --xray-only   Ne tester que Xray Cloud
#   --write       Inclure test d'écriture (Jira : --ticket KEY requis)
#   --ticket KEY  Ticket pour le test d'écriture Jira (add/remove label)
# =============================================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LIB_DIR="$SCRIPT_DIR/lib"
BASE_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
CLI_DIR="$BASE_DIR/jira-mcp-server"
CLI_SCRIPT="$CLI_DIR/dist/cli.js"

# Charger config et fonctions communes (pour log_* si besoin)
if [ -f "$LIB_DIR/config.sh" ]; then
  source "$LIB_DIR/config.sh"
fi
if [ -f "$LIB_DIR/common-functions.sh" ]; then
  source "$LIB_DIR/common-functions.sh"
fi

# Vérifier que le CLI est buildé
if [ ! -f "$CLI_SCRIPT" ]; then
  echo "Erreur : le CLI Jira n'est pas buildé. Lancer : make build" >&2
  exit 1
fi

# Charger le .env du sous-module dans l'environnement (optionnel ; le CLI charge aussi son .env)
if [ -f "$CLI_DIR/.env" ]; then
  set -a
  # shellcheck source=/dev/null
  source "$CLI_DIR/.env"
  set +a
fi

# Exécuter le test de connexion et reprendre le code de sortie
node "$CLI_SCRIPT" connection-test "$@" || exit $?
