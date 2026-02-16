#!/bin/bash

# =============================================================================
# sync-xray.sh — Synchronise les cas de test générés vers Xray Cloud
#
# Ce script est un wrapper autour de la commande CLI `sync-xray`.
# Il localise automatiquement le CLI compilé et passe les arguments.
#
# Usage :
#   bash scripts/sync-xray.sh TICKET-ID [--test-key KEY] [--force] [--dry-run]
#
# Exemples :
#   bash scripts/sync-xray.sh SPEX-3143                    # Sync vers le test nommé SPEX-3143
#   bash scripts/sync-xray.sh SPEX-3143 --test-key SPEX-T1 # Sync vers un test spécifique
#   bash scripts/sync-xray.sh SPEX-3143 --dry-run           # Voir ce qui serait fait
#   bash scripts/sync-xray.sh SPEX-3143 --force             # Forcer la mise à jour
# =============================================================================

set -euo pipefail

# Charger la configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
if [ -f "$SCRIPT_DIR/lib/config.sh" ]; then
    source "$SCRIPT_DIR/lib/config.sh"
else
    BASE_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
fi

CLI_DIR="${BASE_DIR}/jira-mcp-server"
CLI_JS="${CLI_DIR}/dist/cli.js"

# ── Vérifications ────────────────────────────────────────────────────────────

if [ $# -lt 1 ]; then
    echo "Usage : $0 TICKET-ID [--test-key KEY] [--force] [--dry-run]"
    echo ""
    echo "Synchronise les cas de test (03-cas-test.md) vers Xray Cloud."
    echo ""
    echo "Arguments :"
    echo "  TICKET-ID         Clé du ticket Story (ex: SPEX-3143)"
    echo "  --test-key KEY    Clé du ticket Test Xray si différente"
    echo "  --force           Force la mise à jour (même si steps identiques)"
    echo "  --dry-run         Affiche les steps sans modifier Xray"
    echo ""
    echo "Prérequis :"
    echo "  - XRAY_CLIENT_ID et XRAY_CLIENT_SECRET dans jira-mcp-server/.env"
    echo "  - Le document 03-cas-test.md doit exister (lancer 'make process T=ID' d'abord)"
    exit 1
fi

# Vérifier que le CLI est compilé
if [ ! -f "$CLI_JS" ]; then
    echo "Erreur : CLI non compilé ($CLI_JS introuvable)"
    echo "Lancer 'make build' d'abord."
    exit 1
fi

# Vérifier que le fichier .env existe
if [ ! -f "$CLI_DIR/.env" ]; then
    echo "Erreur : fichier .env manquant dans $CLI_DIR"
    echo "Copier .env.example et renseigner les identifiants :"
    echo "  cp $CLI_DIR/.env.example $CLI_DIR/.env"
    exit 1
fi

# ── Exécution ────────────────────────────────────────────────────────────────

# Passer le répertoire de base au CLI pour localiser les fichiers
exec node "$CLI_JS" sync-xray "$@" --base-dir "$BASE_DIR"
