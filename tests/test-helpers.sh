#!/bin/bash

# Bibliothèque de fonctions d'aide pour les tests
# Usage: source "$(dirname "$0")/test-helpers.sh"

# Compteurs globaux
TEST_PASSED=0
TEST_FAILED=0
TEST_TOTAL=0
TEST_SUITE_NAME=""

# Couleurs pour la sortie
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Mode verbose
VERBOSE="${VERBOSE:-0}"

# Afficher un message de test
test_log() {
    if [ "$VERBOSE" = "1" ] || [ "$1" = "error" ] || [ "$1" = "success" ]; then
        case "$1" in
            info)
                echo -e "${BLUE}ℹ${NC} $2"
                ;;
            success)
                echo -e "${GREEN}✓${NC} $2"
                ;;
            error)
                echo -e "${RED}✗${NC} $2"
                ;;
            warning)
                echo -e "${YELLOW}⚠${NC} $2"
                ;;
            *)
                echo "$2"
                ;;
        esac
    fi
}

# Démarrer une suite de tests
test_suite() {
    TEST_SUITE_NAME="$1"
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "🧪 Suite de tests: $TEST_SUITE_NAME"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
}

# Assertion simple
test_assert() {
    local description="$1"
    local condition="$2"
    local expected="${3:-true}"
    
    TEST_TOTAL=$((TEST_TOTAL + 1))
    
    if eval "$condition" 2>/dev/null; then
        TEST_PASSED=$((TEST_PASSED + 1))
        test_log "success" "$description"
        return 0
    else
        TEST_FAILED=$((TEST_FAILED + 1))
        test_log "error" "$description"
        if [ "$VERBOSE" = "1" ]; then
            echo "   Condition: $condition"
            echo "   Expected: $expected"
        fi
        return 1
    fi
}

# Assertion d'égalité
test_assert_equal() {
    local description="$1"
    local actual="$2"
    local expected="$3"
    
    TEST_TOTAL=$((TEST_TOTAL + 1))
    
    if [ "$actual" = "$expected" ]; then
        TEST_PASSED=$((TEST_PASSED + 1))
        test_log "success" "$description"
        return 0
    else
        TEST_FAILED=$((TEST_FAILED + 1))
        test_log "error" "$description"
        if [ "$VERBOSE" = "1" ]; then
            echo "   Expected: $expected"
            echo "   Actual:   $actual"
        fi
        return 1
    fi
}

# Assertion de non-égalité
test_assert_not_equal() {
    local description="$1"
    local actual="$2"
    local expected="$3"
    
    TEST_TOTAL=$((TEST_TOTAL + 1))
    
    if [ "$actual" != "$expected" ]; then
        TEST_PASSED=$((TEST_PASSED + 1))
        test_log "success" "$description"
        return 0
    else
        TEST_FAILED=$((TEST_FAILED + 1))
        test_log "error" "$description"
        if [ "$VERBOSE" = "1" ]; then
            echo "   Expected: NOT $expected"
            echo "   Actual:   $actual"
        fi
        return 1
    fi
}

# Assertion de fichier existe
test_assert_file_exists() {
    local description="$1"
    local file="$2"
    
    TEST_TOTAL=$((TEST_TOTAL + 1))
    
    if [ -f "$file" ]; then
        TEST_PASSED=$((TEST_PASSED + 1))
        test_log "success" "$description"
        return 0
    else
        TEST_FAILED=$((TEST_FAILED + 1))
        test_log "error" "$description"
        if [ "$VERBOSE" = "1" ]; then
            echo "   File: $file"
        fi
        return 1
    fi
}

# Assertion de répertoire existe
test_assert_dir_exists() {
    local description="$1"
    local dir="$2"
    
    TEST_TOTAL=$((TEST_TOTAL + 1))
    
    if [ -d "$dir" ]; then
        TEST_PASSED=$((TEST_PASSED + 1))
        test_log "success" "$description"
        return 0
    else
        TEST_FAILED=$((TEST_FAILED + 1))
        test_log "error" "$description"
        if [ "$VERBOSE" = "1" ]; then
            echo "   Directory: $dir"
        fi
        return 1
    fi
}

# Afficher le résumé des tests
test_summary() {
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "📊 Résumé des tests"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
    echo "Total:    $TEST_TOTAL"
    echo -e "${GREEN}Passés:   $TEST_PASSED${NC}"
    echo -e "${RED}Échoués:  $TEST_FAILED${NC}"
    echo ""
    
    if [ "$TEST_FAILED" -eq 0 ]; then
        echo -e "${GREEN}✓ Tous les tests sont passés !${NC}"
        return 0
    else
        echo -e "${RED}✗ Certains tests ont échoué${NC}"
        return 1
    fi
}

# Réinitialiser les compteurs
test_reset() {
    TEST_PASSED=0
    TEST_FAILED=0
    TEST_TOTAL=0
    TEST_SUITE_NAME=""
}

