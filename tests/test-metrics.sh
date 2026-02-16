#!/bin/bash

# =============================================================================
# Tests pour metrics.sh
# =============================================================================

set -euo pipefail

TEST_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$TEST_DIR/test-helpers.sh"

SCRIPT_DIR="$(cd "$TEST_DIR/../scripts" && pwd)"
METRICS_SCRIPT="$SCRIPT_DIR/metrics.sh"

test_suite "metrics.sh"

# Test 1 : Format texte par défaut (ne doit pas planter même sans dossier projets)
OUTPUT=$(bash "$METRICS_SCRIPT" 2>&1 || true)
test_assert "Format texte ne plante pas" '[ -n "$OUTPUT" ]'

# Test 2 : Format JSON
OUTPUT=$(bash "$METRICS_SCRIPT" --format json 2>&1 || true)
test_assert "Format JSON produit du contenu" '[ -n "$OUTPUT" ]'
# Vérifier que c'est du JSON valide si python3 est disponible
if command -v python3 &>/dev/null; then
    if echo "$OUTPUT" | python3 -m json.tool > /dev/null 2>&1; then
        test_assert "Format JSON est du JSON valide" "true"
    else
        test_assert "Format JSON est du JSON valide" "false"
    fi
fi

# Test 3 : Format Markdown
OUTPUT=$(bash "$METRICS_SCRIPT" --format markdown 2>&1 || true)
test_assert "Format markdown produit du contenu" '[ -n "$OUTPUT" ]'
test_assert "Format markdown contient un titre" 'echo "$OUTPUT" | grep -q "^#"'

# Test 4 : Aide --help
HELP_OUTPUT=$(bash "$METRICS_SCRIPT" --help 2>&1 || true)
test_assert "--help affiche l'usage" 'echo "$HELP_OUTPUT" | grep -q "Usage"'

test_summary
