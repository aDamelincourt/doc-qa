#!/bin/bash

# =============================================================================
# sync-to-notion.sh — Envoie la doc QA (01, 02, 03) vers Notion
#
# Structure dans Notion : Page racine → Projet → EPIC (ou "Sans EPIC") → US/Bug
# Chaque page US contient les blocs 01, 02 et 03.
#
# Variables requises (ou dans .env à la racine du projet) :
#   NOTION_API_KEY         Secret d'intégration Notion
#   NOTION_PARENT_PAGE_ID  ID de la page racine "Doc QA" (32 caractères, avec ou sans tirets)
#
# La page racine doit être partagée avec l'intégration dans Notion.
#
# Usage :
#   bash scripts/sync-to-notion.sh [--base-dir DIR] [--dry-run]
# =============================================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BASE_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

if [ -f "$SCRIPT_DIR/lib/config.sh" ]; then
    source "$SCRIPT_DIR/lib/config.sh"
fi

# config.sh charge déjà .env ; vérifier les variables Notion
if [ -z "${NOTION_API_KEY:-}" ]; then
    echo "Erreur : NOTION_API_KEY non défini. Le définir ou l'ajouter dans $BASE_DIR/.env"
    exit 1
fi

if [ -z "${NOTION_PARENT_PAGE_ID:-}" ]; then
    echo "Erreur : NOTION_PARENT_PAGE_ID non défini (ID de la page racine Doc QA dans Notion)."
    exit 1
fi

exec node "$SCRIPT_DIR/sync-to-notion.js" --base-dir "$BASE_DIR" "$@"
