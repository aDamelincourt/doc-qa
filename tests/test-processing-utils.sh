#!/bin/bash

# Tests pour les utilitaires de traitement
# Usage: ./tests/test-processing-utils.sh

set -euo pipefail

# Charger les helpers de test
TEST_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$TEST_DIR/test-helpers.sh"

# Charger les fonctions à tester
SCRIPT_DIR="$(cd "$TEST_DIR/.." && pwd)"
source "$SCRIPT_DIR/scripts/lib/config.sh"
source "$SCRIPT_DIR/scripts/lib/common-functions.sh"
source "$SCRIPT_DIR/scripts/lib/processing-utils.sh"

test_suite "Utilitaires de traitement"

# Test check_write_permissions
TEMP_DIR=$(mktemp -d)
test_assert "check_write_permissions retourne 0 pour un répertoire accessible en écriture" \
    "check_write_permissions '$TEMP_DIR'"
rm -rf "$TEMP_DIR"

# Test safe_mkdir
TEMP_DIR="/tmp/test_safe_mkdir_$(date +%s)"
test_assert "safe_mkdir crée un répertoire" \
    "safe_mkdir '$TEMP_DIR' && [ -d '$TEMP_DIR' ]"
rm -rf "$TEMP_DIR"

# Test safe_mkdir avec répertoire existant
TEMP_DIR=$(mktemp -d)
test_assert "safe_mkdir gère un répertoire existant" \
    "safe_mkdir '$TEMP_DIR'"
rm -rf "$TEMP_DIR"

# Test is_processed (nécessite une structure de projet)
# Créer une structure de test
TEST_BASE=$(mktemp -d)
TEST_PROJETS="$TEST_BASE/projets"
TEST_PROJECT="$TEST_PROJETS/TESTPROJ"
TEST_US="$TEST_PROJECT/us-123"
mkdir -p "$TEST_US"
echo "TEST-123" > "$TEST_US/README.md"

# Créer un fichier XML de test
TEST_XML=$(mktemp)
cat > "$TEST_XML" <<'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<rss>
    <channel>
        <item>
            <key>TEST-123</key>
            <summary>Test Summary</summary>
        </item>
    </channel>
</rss>
EOF

# Test is_processed avec fichier traité
test_assert "is_processed détecte un fichier traité" \
    "is_processed '$TEST_XML' '$TEST_BASE'"

# Test is_processed avec fichier non traité
UNPROCESSED_XML=$(mktemp)
cat > "$UNPROCESSED_XML" <<'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<rss>
    <channel>
        <item>
            <key>TEST-999</key>
            <summary>Untested</summary>
        </item>
    </channel>
</rss>
EOF

test_assert "is_processed détecte un fichier non traité" \
    '! is_processed "$UNPROCESSED_XML" "$TEST_BASE"'

# Nettoyage
rm -rf "$TEST_BASE" "$TEST_XML" "$UNPROCESSED_XML"

test_summary

