#!/bin/bash

# Tests pour les utilitaires XML
# Usage: ./tests/test-xml-utils.sh

set -euo pipefail

# Charger les helpers de test
TEST_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$TEST_DIR/test-helpers.sh"

# Charger les fonctions à tester
SCRIPT_DIR="$(cd "$TEST_DIR/.." && pwd)"
source "$SCRIPT_DIR/scripts/lib/config.sh"
source "$SCRIPT_DIR/scripts/lib/common-functions.sh"
source "$SCRIPT_DIR/scripts/lib/xml-utils.sh"

test_suite "Utilitaires XML"

# Créer un fichier XML de test
TEMP_XML=$(mktemp)
cat > "$TEMP_XML" <<'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<rss>
    <channel>
        <item>
            <key>TEST-123</key>
            <summary>Test Summary</summary>
            <link>https://example.com/TEST-123</link>
            <description>
                &lt;h1&gt;User Story&lt;/h1&gt;
                &lt;p&gt;As a user, I want to test, so that I can verify.&lt;/p&gt;
            </description>
        </item>
    </channel>
</rss>
EOF

# Test extract_key
test_assert_equal "extract_key extrait la clé correctement" \
    "$(extract_key "$TEMP_XML")" \
    "TEST-123"

# Test extract_summary
test_assert_equal "extract_summary extrait le résumé correctement" \
    "$(extract_summary "$TEMP_XML")" \
    "Test Summary"

# Test extract_link
test_assert_equal "extract_link extrait le lien correctement" \
    "$(extract_link "$TEMP_XML")" \
    "https://example.com/TEST-123"

# Test extract_description
DESC=$(extract_description "$TEMP_XML" 10)
test_assert "extract_description extrait la description" \
    '[ -n "$DESC" ]'

# Test decode_html
DECODED=$(echo "$DESC" | decode_html)
test_assert "decode_html décode les entités HTML" \
    'echo "$DECODED" | grep -q "<h1>"'

# Test validate_xml
test_assert "validate_xml valide un XML valide" \
    "validate_xml '$TEMP_XML'"

# Test avec XML invalide
INVALID_XML=$(mktemp)
echo "<invalid>" > "$INVALID_XML"
test_assert "validate_xml rejette un XML invalide" \
    '! validate_xml "$INVALID_XML"'

# Nettoyage
rm -f "$TEMP_XML" "$INVALID_XML"

test_summary

