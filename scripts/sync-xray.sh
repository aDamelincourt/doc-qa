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
    echo "Usage : $0 TICKET-ID [--test-key KEY] [--force] [--dry-run] [--skip-validate]"
    echo ""
    echo "Synchronise les cas de test (03-cas-test.md) vers Xray Cloud."
    echo "Par défaut, exécute validate-docs.sh sur le dossier US avant la sync."
    echo ""
    echo "Arguments :"
    echo "  TICKET-ID         Clé du ticket Story (ex: SPEX-3143)"
    echo "  --test-key KEY    Clé du ticket Test Xray si différente"
    echo "  --force           Force la mise à jour (même si steps identiques)"
    echo "  --dry-run         Affiche les steps sans modifier Xray"
    echo "  --skip-validate   Ne pas lancer la validation des documents avant sync"
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

# ── Validation du 03-cas-test.md avant sync (option --skip-validate pour contourner) ─

TICKET_ID="$1"
SKIP_VALIDATE=false
ARGS=()
for a in "$@"; do
    if [ "$a" = "--skip-validate" ]; then
        SKIP_VALIDATE=true
    else
        ARGS+=("$a")
    fi
done

if [ "$SKIP_VALIDATE" = false ]; then
    PROJECT_KEY="${TICKET_ID%-*}"
    TICKET_NUM="${TICKET_ID#*-}"
    US_DIR_CANDIDATE="$BASE_DIR/projets/$PROJECT_KEY/us-$TICKET_NUM"
    if [ ! -d "$US_DIR_CANDIDATE" ]; then
        _proj_lower=$(echo "$PROJECT_KEY" | tr '[:upper:]' '[:lower:]')
        US_DIR_CANDIDATE="$BASE_DIR/projets/$_proj_lower/us-$TICKET_NUM"
    fi
    VALIDATE_SCRIPT="$SCRIPT_DIR/validate-docs.sh"
    if [ -d "$US_DIR_CANDIDATE" ] && [ -f "$US_DIR_CANDIDATE/03-cas-test.md" ] && [ -f "$VALIDATE_SCRIPT" ]; then
        if ! bash "$VALIDATE_SCRIPT" "$US_DIR_CANDIDATE" 2>/dev/null; then
            echo "Erreur : la validation des documents a échoué pour $TICKET_ID."
            echo "Corriger les documents dans $US_DIR_CANDIDATE puis relancer."
            echo "Pour ignorer la validation : $0 $* --skip-validate"
            exit 1
        fi
    fi
fi

# ── Exécution ────────────────────────────────────────────────────────────────

# Passer le répertoire de base au CLI pour localiser les fichiers
exec node "$CLI_JS" sync-xray "${ARGS[@]}" --base-dir "$BASE_DIR"
