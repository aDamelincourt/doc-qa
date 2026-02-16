#!/bin/bash

# =============================================================================
# validate-docs.sh — Validation automatique de la qualité des documents QA
#
# Vérifie que les documents générés par le pipeline respectent
# les critères de qualité minimaux avant d'être considérés comme valides.
#
# Critères vérifiés :
#   - Présence de tous les fichiers attendus (README, questions, stratégie, cas de test)
#   - Sections obligatoires dans chaque document
#   - Cohérence du ticket key
#   - Nombre minimum de scénarios dans 03-cas-test.md
#   - Taille minimale des fichiers (pas vides ou tronqués)
#
# Usage :
#   bash scripts/validate-docs.sh <us-directory>
#   bash scripts/validate-docs.sh projets/SPEX/us-3143
#   bash scripts/validate-docs.sh projets/SPEX/us-3143 --strict
#
# Codes retour :
#   0 = tous les critères satisfaits
#   1 = au moins un critère échoué
#   2 = erreur d'utilisation
# =============================================================================

set -euo pipefail

# ── Configuration ────────────────────────────────────────────────────────────

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
if [ -f "$SCRIPT_DIR/lib/config.sh" ]; then
    source "$SCRIPT_DIR/lib/config.sh"
fi

# Seuils configurables
MIN_FILE_SIZE=${QA_MIN_FILE_SIZE:-200}                # Taille minimale (octets)
MIN_SCENARIOS=${QA_MIN_SCENARIOS:-2}                   # Nombre min de scénarios
MIN_QUESTIONS=${QA_MIN_QUESTIONS:-5}                    # Nombre min de questions
MIN_SECTIONS_QUESTIONS=${QA_MIN_SECTIONS_QUESTIONS:-3}  # Sections min dans questions
MIN_SECTIONS_STRATEGY=${QA_MIN_SECTIONS_STRATEGY:-3}    # Sections min dans stratégie

# Compteurs de résultat
PASS=0
FAIL=0
WARN=0
STRICT=false

# ── Fonctions utilitaires ────────────────────────────────────────────────────

# Couleurs (si terminal interactif)
if [ -t 1 ]; then
    GREEN='\033[0;32m'
    RED='\033[0;31m'
    YELLOW='\033[0;33m'
    NC='\033[0m'
else
    GREEN=''
    RED=''
    YELLOW=''
    NC=''
fi

pass() {
    PASS=$((PASS + 1))
    echo -e "  ${GREEN}[OK]${NC} $1"
}

fail() {
    FAIL=$((FAIL + 1))
    echo -e "  ${RED}[FAIL]${NC} $1"
}

warn() {
    WARN=$((WARN + 1))
    if [ "$STRICT" = true ]; then
        FAIL=$((FAIL + 1))
        echo -e "  ${RED}[FAIL]${NC} $1 (strict)"
    else
        echo -e "  ${YELLOW}[WARN]${NC} $1"
    fi
}

# ── Validation d'un fichier ──────────────────────────────────────────────────

validate_file_exists() {
    local file="$1"
    local label="$2"
    if [ -f "$file" ]; then
        pass "$label existe"
        return 0
    else
        fail "$label manquant"
        return 1
    fi
}

validate_file_size() {
    local file="$1"
    local label="$2"
    local min_size="${3:-$MIN_FILE_SIZE}"

    if [ ! -f "$file" ]; then
        return 1 # Déjà signalé par validate_file_exists
    fi

    local size
    size=$(wc -c < "$file" | tr -d ' ')

    if [ "$size" -ge "$min_size" ]; then
        pass "$label taille OK (${size} octets)"
    else
        fail "$label trop petit (${size} octets, minimum : ${min_size})"
    fi
}

validate_contains_section() {
    local file="$1"
    local section_pattern="$2"
    local label="$3"

    if [ ! -f "$file" ]; then
        return 1
    fi

    if grep -qE "$section_pattern" "$file" 2>/dev/null; then
        pass "$label : section trouvée"
    else
        fail "$label : section manquante (pattern: $section_pattern)"
    fi
}

validate_heading_count() {
    local file="$1"
    local pattern="$2"
    local min_count="$3"
    local label="$4"

    if [ ! -f "$file" ]; then
        return 1
    fi

    local count
    count=$(grep -cE "$pattern" "$file" 2>/dev/null || echo "0")

    if [ "$count" -ge "$min_count" ]; then
        pass "$label ($count trouvé(s), minimum : $min_count)"
    else
        fail "$label ($count trouvé(s), minimum : $min_count)"
    fi
}

validate_ticket_coherence() {
    local file="$1"
    local expected_key="$2"
    local label="$3"

    if [ ! -f "$file" ]; then
        return 1
    fi

    if grep -q "$expected_key" "$file" 2>/dev/null; then
        pass "$label : ticket key $expected_key présent"
    else
        warn "$label : ticket key $expected_key absent du document"
    fi
}

# ── Validation d'un dossier US complet ───────────────────────────────────────

validate_us_directory() {
    local us_dir="$1"

    if [ ! -d "$us_dir" ]; then
        echo "Erreur : répertoire $us_dir introuvable"
        return 2
    fi

    # Extraire le ticket key depuis le nom du répertoire ou le README
    local dir_name
    dir_name=$(basename "$us_dir")
    local us_num="${dir_name#us-}"

    # Chercher le projet parent
    local project_dir
    project_dir=$(basename "$(dirname "$us_dir")")
    local ticket_key="${project_dir}-${us_num}"

    echo ""
    echo "=== Validation : $ticket_key ($us_dir) ==="
    echo ""

    # ── 1. Fichiers attendus ─────────────────────────────────────────

    echo "--- Fichiers ---"
    validate_file_exists "$us_dir/README.md" "README.md"
    validate_file_exists "$us_dir/extraction-jira.md" "extraction-jira.md"
    validate_file_exists "$us_dir/01-questions.md" "01-questions.md"
    validate_file_exists "$us_dir/02-strategie.md" "02-strategie.md"
    validate_file_exists "$us_dir/03-cas-test.md" "03-cas-test.md"

    # ── 2. Taille des fichiers ───────────────────────────────────────

    echo ""
    echo "--- Taille minimale ---"
    validate_file_size "$us_dir/extraction-jira.md" "extraction-jira.md" 100
    validate_file_size "$us_dir/01-questions.md" "01-questions.md" "$MIN_FILE_SIZE"
    validate_file_size "$us_dir/02-strategie.md" "02-strategie.md" "$MIN_FILE_SIZE"
    validate_file_size "$us_dir/03-cas-test.md" "03-cas-test.md" "$MIN_FILE_SIZE"

    # ── 3. Cohérence du ticket key ───────────────────────────────────

    echo ""
    echo "--- Cohérence ticket ---"
    validate_ticket_coherence "$us_dir/README.md" "$ticket_key" "README.md"
    validate_ticket_coherence "$us_dir/extraction-jira.md" "$ticket_key" "extraction-jira.md"
    validate_ticket_coherence "$us_dir/03-cas-test.md" "$ticket_key" "03-cas-test.md"

    # ── 4. Sections dans 01-questions.md ─────────────────────────────

    if [ -f "$us_dir/01-questions.md" ]; then
        echo ""
        echo "--- 01-questions.md ---"
        validate_contains_section "$us_dir/01-questions.md" "^#" "Titre principal"
        validate_heading_count "$us_dir/01-questions.md" "^\d+\." "$MIN_QUESTIONS" "Questions numérotées"
    fi

    # ── 5. Sections dans 02-strategie.md ─────────────────────────────

    if [ -f "$us_dir/02-strategie.md" ]; then
        echo ""
        echo "--- 02-strategie.md ---"
        validate_contains_section "$us_dir/02-strategie.md" "^#" "Titre principal"
        validate_heading_count "$us_dir/02-strategie.md" "^##" "$MIN_SECTIONS_STRATEGY" "Sections H2"
    fi

    # ── 6. Scénarios dans 03-cas-test.md ─────────────────────────────

    if [ -f "$us_dir/03-cas-test.md" ]; then
        echo ""
        echo "--- 03-cas-test.md ---"
        validate_contains_section "$us_dir/03-cas-test.md" "^#" "Titre principal"
        validate_heading_count "$us_dir/03-cas-test.md" "^### Sc[eé]nario" "$MIN_SCENARIOS" "Scénarios de test"
        validate_contains_section "$us_dir/03-cas-test.md" "\*\*[EÉ]tapes?\*\*" "Section étapes"
        validate_contains_section "$us_dir/03-cas-test.md" "\*\*R[eé]sultat" "Section résultat attendu"
    fi

    # ── Résumé ───────────────────────────────────────────────────────

    echo ""
    echo "=== Résumé $ticket_key ==="
    echo -e "  ${GREEN}OK${NC}: $PASS  |  ${RED}FAIL${NC}: $FAIL  |  ${YELLOW}WARN${NC}: $WARN"
    echo ""

    if [ "$FAIL" -gt 0 ]; then
        return 1
    fi
    return 0
}

# ── Point d'entrée ───────────────────────────────────────────────────────────

if [ $# -lt 1 ]; then
    echo "Usage : $0 <us-directory> [--strict]"
    echo ""
    echo "Valide la qualité des documents QA générés dans un répertoire US."
    echo ""
    echo "  --strict    Les warnings deviennent des erreurs"
    echo ""
    echo "Exemples :"
    echo "  $0 projets/SPEX/us-3143"
    echo "  $0 projets/SPEX/us-3143 --strict"
    echo ""
    echo "Variables configurables :"
    echo "  QA_MIN_FILE_SIZE=$MIN_FILE_SIZE (taille minimale en octets)"
    echo "  QA_MIN_SCENARIOS=$MIN_SCENARIOS (nombre min de scénarios)"
    echo "  QA_MIN_QUESTIONS=$MIN_QUESTIONS (nombre min de questions)"
    exit 2
fi

US_DIR="$1"
shift

# Options supplémentaires
for arg in "$@"; do
    case "$arg" in
        --strict) STRICT=true ;;
        *) echo "Option inconnue : $arg"; exit 2 ;;
    esac
done

validate_us_directory "$US_DIR"
exit $?
