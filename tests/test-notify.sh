#!/bin/bash

# =============================================================================
# Tests pour notify.sh
# =============================================================================

set -euo pipefail

TEST_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$TEST_DIR/test-helpers.sh"

SCRIPT_DIR="$(cd "$TEST_DIR/../scripts" && pwd)"
NOTIFY_SCRIPT="$SCRIPT_DIR/notify.sh"

test_suite "notify.sh"

# Test 1 : Notification info sur console
OUTPUT=$(bash "$NOTIFY_SCRIPT" --type info --message "Test message" 2>&1 || true)
test_assert "Notification info affiche le message" '[ -n "$OUTPUT" ]'

# Test 2 : Notification success
OUTPUT=$(bash "$NOTIFY_SCRIPT" --type success --message "Tout OK" 2>&1 || true)
test_assert "Notification success fonctionne" 'echo "$OUTPUT" | grep -q "Tout OK"'

# Test 3 : Notification error
OUTPUT=$(bash "$NOTIFY_SCRIPT" --type error --message "Erreur critique" 2>&1 || true)
test_assert "Notification error fonctionne" 'echo "$OUTPUT" | grep -q "Erreur critique"'

# Test 4 : Notification warning
OUTPUT=$(bash "$NOTIFY_SCRIPT" --type warning --message "Attention" 2>&1 || true)
test_assert "Notification warning fonctionne" 'echo "$OUTPUT" | grep -q "Attention"'

# Test 5 : Sans message (devrait afficher une erreur ou usage)
if bash "$NOTIFY_SCRIPT" > /dev/null 2>&1; then
    test_assert "Sans message retourne erreur" "false"
else
    test_assert "Sans message retourne erreur" "true"
fi

# Test 6 : Aide --help
HELP_OUTPUT=$(bash "$NOTIFY_SCRIPT" --help 2>&1 || true)
test_assert "--help affiche l'usage" 'echo "$HELP_OUTPUT" | grep -q "Usage"'

# Test 7 : Titre personnalisé
OUTPUT=$(bash "$NOTIFY_SCRIPT" --type info --message "Test" --title "Mon titre" 2>&1 || true)
test_assert "Titre personnalisé accepté" '[ -n "$OUTPUT" ]'

# Test 8 : Canal console explicite
OUTPUT=$(bash "$NOTIFY_SCRIPT" --type info --message "Test console" --channel console 2>&1 || true)
test_assert "Canal console explicite fonctionne" 'echo "$OUTPUT" | grep -q "Test console"'

test_summary
