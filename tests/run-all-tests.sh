#!/bin/bash

# Script pour exécuter tous les tests
# Usage: ./tests/run-all-tests.sh [--verbose]

set -euo pipefail

# Gestion des arguments
if [ "${1:-}" = "--verbose" ] || [ "${1:-}" = "-v" ]; then
    export VERBOSE=1
fi

# Répertoire des tests
TEST_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SCRIPT_DIR="$(cd "$TEST_DIR/.." && pwd)"

# Charger les helpers
source "$TEST_DIR/test-helpers.sh"

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🧪 Exécution de tous les tests"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Compteurs globaux
TOTAL_PASSED=0
TOTAL_FAILED=0
TOTAL_TOTAL=0

# Liste des fichiers de test
TEST_FILES=(
    "test-common-functions.sh"
    "test-xml-utils.sh"
    "test-processing-utils.sh"
    "test-generate-from-context.sh"
    "test-validate-docs.sh"
    "test-notify.sh"
    "test-metrics.sh"
)

# Exécuter chaque test
for test_file in "${TEST_FILES[@]}"; do
    if [ -f "$TEST_DIR/$test_file" ]; then
        # Réinitialiser les compteurs pour chaque suite
        test_reset
        
        # Exécuter le test
        if bash "$TEST_DIR/$test_file"; then
            TOTAL_PASSED=$((TOTAL_PASSED + TEST_PASSED))
            TOTAL_FAILED=$((TOTAL_FAILED + TEST_FAILED))
            TOTAL_TOTAL=$((TOTAL_TOTAL + TEST_TOTAL))
        else
            TOTAL_PASSED=$((TOTAL_PASSED + TEST_PASSED))
            TOTAL_FAILED=$((TOTAL_FAILED + TEST_FAILED))
            TOTAL_TOTAL=$((TOTAL_TOTAL + TEST_TOTAL))
        fi
    else
        echo "⚠️  Fichier de test introuvable: $test_file"
    fi
done

# Résumé final
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📊 Résumé global"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "Total:    $TOTAL_TOTAL"
echo -e "${GREEN}Passés:   $TOTAL_PASSED${NC}"
echo -e "${RED}Échoués:  $TOTAL_FAILED${NC}"
echo ""

if [ "$TOTAL_FAILED" -eq 0 ]; then
    echo -e "${GREEN}✓ Tous les tests sont passés !${NC}"
    exit 0
else
    echo -e "${RED}✗ Certains tests ont échoué${NC}"
    exit 1
fi

