#!/bin/bash

# Tests pour les fonctions communes
# Usage: ./tests/test-common-functions.sh

set -euo pipefail

# Charger les helpers de test
TEST_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$TEST_DIR/test-helpers.sh"

# Charger les fonctions à tester
SCRIPT_DIR="$(cd "$TEST_DIR/.." && pwd)"
source "$SCRIPT_DIR/scripts/lib/config.sh"
source "$SCRIPT_DIR/scripts/lib/common-functions.sh"

test_suite "Fonctions communes"

# Test decode_html
test_assert "decode_html décode &lt; en <" \
    '[ "$(echo "&lt;test&gt;" | decode_html)" = "<test>" ]'

test_assert "decode_html décode &gt; en >" \
    '[ "$(echo "&lt;test&gt;" | decode_html)" = "<test>" ]'

test_assert "decode_html décode &amp; en &" \
    '[ "$(echo "test&amp;test" | decode_html)" = "test&test" ]'

test_assert "decode_html décode &quot; en \"" \
    '[ "$(echo "&quot;test&quot;" | decode_html)" = "\"test\"" ]'

# Test log_info
test_assert "log_info fonctionne sans erreur" \
    'log_info "Test message" > /dev/null 2>&1'

# Test log_error
test_assert "log_error fonctionne sans erreur" \
    'log_error "Test error" > /dev/null 2>&1'

# Test log_success
test_assert "log_success fonctionne sans erreur" \
    'log_success "Test success" > /dev/null 2>&1'

# Test log_warning
test_assert "log_warning fonctionne sans erreur" \
    'log_warning "Test warning" > /dev/null 2>&1'

# Test validate_directory
TEMP_DIR=$(mktemp -d)
test_assert "validate_directory retourne 0 pour un répertoire valide" \
    "validate_directory '$TEMP_DIR'"
rm -rf "$TEMP_DIR"

test_assert "validate_directory retourne 1 pour un répertoire inexistant" \
    '! validate_directory "/tmp/nonexistent_$(date +%s)"'

# Test validate_file
TEMP_FILE=$(mktemp)
test_assert "validate_file retourne 0 pour un fichier valide" \
    "validate_file '$TEMP_FILE'"
rm -f "$TEMP_FILE"

test_assert "validate_file retourne 1 pour un fichier inexistant" \
    '! validate_file "/tmp/nonexistent_$(date +%s).txt"'

test_summary

