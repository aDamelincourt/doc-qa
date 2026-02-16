#!/bin/bash

# =============================================================================
# notify.sh — Script de notification pour le pipeline QA
#
# Envoie des notifications via Slack webhook ou affiche dans le terminal.
# Utilisable depuis le pipeline, les GitHub Actions, ou manuellement.
#
# Usage :
#   bash scripts/notify.sh --type success --message "5 tickets traités"
#   bash scripts/notify.sh --type error --message "Échec pour SPEX-3143"
#   bash scripts/notify.sh --type info --message "10 tickets détectés"
#
# Variables d'environnement :
#   SLACK_WEBHOOK_URL    URL du webhook Slack (optionnel)
#   NOTIFY_CHANNEL       Canal de notification : slack, console, all (défaut: console)
# =============================================================================

set -euo pipefail

# ── Configuration ────────────────────────────────────────────────────────────

CHANNEL="${NOTIFY_CHANNEL:-console}"
SLACK_URL="${SLACK_WEBHOOK_URL:-}"

# ── Arguments ────────────────────────────────────────────────────────────────

TYPE="info"
MESSAGE=""
TITLE="Pipeline QA"

while [ $# -gt 0 ]; do
    case "$1" in
        --type|-t)     TYPE="$2"; shift 2 ;;
        --message|-m)  MESSAGE="$2"; shift 2 ;;
        --title)       TITLE="$2"; shift 2 ;;
        --channel|-c)  CHANNEL="$2"; shift 2 ;;
        --help|-h)
            echo "Usage : $0 --type info|success|error|warning --message \"texte\""
            echo ""
            echo "Options :"
            echo "  --type       Type de notification (info, success, error, warning)"
            echo "  --message    Message à envoyer"
            echo "  --title      Titre de la notification (défaut: Pipeline QA)"
            echo "  --channel    Canal : slack, console, all (défaut: console)"
            echo ""
            echo "Variables d'environnement :"
            echo "  SLACK_WEBHOOK_URL   URL du webhook Slack"
            echo "  NOTIFY_CHANNEL      Canal par défaut"
            exit 0
            ;;
        *)
            if [ -z "$MESSAGE" ]; then MESSAGE="$1"; fi
            shift
            ;;
    esac
done

if [ -z "$MESSAGE" ]; then
    echo "Erreur : --message requis"
    exit 1
fi

# ── Icônes et couleurs ───────────────────────────────────────────────────────

get_icon() {
    case "$TYPE" in
        success) echo ":white_check_mark:" ;;
        error)   echo ":x:" ;;
        warning) echo ":warning:" ;;
        info)    echo ":information_source:" ;;
        *)       echo ":speech_balloon:" ;;
    esac
}

get_color() {
    case "$TYPE" in
        success) echo '\033[0;32m' ;;
        error)   echo '\033[0;31m' ;;
        warning) echo '\033[0;33m' ;;
        info)    echo '\033[0;34m' ;;
        *)       echo '\033[0m' ;;
    esac
}

# ── Notification console ─────────────────────────────────────────────────────

notify_console() {
    local color
    color=$(get_color)
    local NC='\033[0m'
    local label
    case "$TYPE" in
        success) label="[OK]" ;;
        error)   label="[ERR]" ;;
        warning) label="[WARN]" ;;
        *)       label="[INFO]" ;;
    esac

    echo -e "${color}${label}${NC} ${TITLE}: ${MESSAGE}"
}

# ── Notification Slack ───────────────────────────────────────────────────────

notify_slack() {
    if [ -z "$SLACK_URL" ]; then
        echo "SLACK_WEBHOOK_URL non défini, notification Slack ignorée"
        return 0
    fi

    local icon
    icon=$(get_icon)
    local timestamp
    timestamp=$(date -u +"%Y-%m-%d %H:%M UTC")

    local payload
    payload=$(cat <<EOF
{
  "text": "${icon} ${TITLE}: ${MESSAGE}",
  "blocks": [
    {
      "type": "section",
      "text": {
        "type": "mrkdwn",
        "text": "${icon} *${TITLE}*\\n${MESSAGE}"
      }
    },
    {
      "type": "context",
      "elements": [
        {
          "type": "mrkdwn",
          "text": "${timestamp}"
        }
      ]
    }
  ]
}
EOF
)

    local http_code
    http_code=$(curl -s -o /dev/null -w "%{http_code}" \
        -X POST "$SLACK_URL" \
        -H 'Content-Type: application/json' \
        -d "$payload" 2>/dev/null || echo "000")

    if [ "$http_code" = "200" ]; then
        echo "Notification Slack envoyée"
    else
        echo "Erreur Slack (HTTP $http_code)"
    fi
}

# ── Dispatcher ───────────────────────────────────────────────────────────────

case "$CHANNEL" in
    console)
        notify_console
        ;;
    slack)
        notify_slack
        ;;
    all)
        notify_console
        notify_slack
        ;;
    *)
        echo "Canal inconnu : $CHANNEL"
        notify_console
        ;;
esac
