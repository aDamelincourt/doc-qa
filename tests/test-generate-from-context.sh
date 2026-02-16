#!/bin/bash

# =============================================================================
# Tests unitaires pour generate-from-context.sh
# Vérifie le parsing de extraction-jira.md et la génération des 3 documents.
# =============================================================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BASE_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
source "$SCRIPT_DIR/test-helpers.sh"

GENERATE_SCRIPT="$BASE_DIR/scripts/generate-from-context.sh"

# ── Setup / Teardown ─────────────────────────────────────────────────────────

TEMP_DIR=""

setup_test_dir() {
    TEMP_DIR=$(mktemp -d)
    mkdir -p "$TEMP_DIR/projets/TEST/us-1234"
}

teardown_test_dir() {
    [ -d "$TEMP_DIR" ] && rm -rf "$TEMP_DIR"
}

create_extraction_api_format() {
    local us_dir="$1"
    cat > "$us_dir/extraction-jira.md" <<'EXTRACTION'
# TEST-1234: Ajouter la fonctionnalité de recherche avancée

## Informations générales

- **Clé**: TEST-1234
- **Type**: Story
- **Statut**: Ready
- **Priorité**: High
- **Assigné à**: John Doe
- **Rapporteur**: Jane Smith
- **Créé le**: 2025-01-15
- **Mis à jour**: 2025-02-10
- **Parent/Epic**: TEST-100 (Search Improvements)
- **Lien Jira**: https://example.atlassian.net/browse/TEST-1234
- **Labels**: search, frontend

## Description

En tant qu'utilisateur, je souhaite pouvoir effectuer une recherche avancée
avec des filtres multiples afin de trouver rapidement les produits qui
correspondent à mes critères.

## Critères d'acceptation (extraits)

- Given l'utilisateur est sur la page de recherche
- When il saisit un terme dans le champ de recherche
- Then les résultats correspondants s'affichent

## Commentaires

### Alice — 2025-01-20

Il faut penser au debounce pour les requêtes API.

### Bob — 2025-01-22

Attention à la performance avec les gros catalogues.
EXTRACTION
}

create_extraction_legacy_format() {
    local us_dir="$1"
    cat > "$us_dir/extraction-jira.md" <<'EXTRACTION'
# Extraction Jira - LEGACY-5678

**Titre/Summary** : Optimiser les performances du dashboard

## Description

Description de la story legacy.

## Commentaires

Pas de commentaire.
EXTRACTION
}

# ── Tests ────────────────────────────────────────────────────────────────────

test_suite "generate-from-context.sh"

# --- Test : format API - extraction des métadonnées ---
test_api_metadata_extraction() {
    setup_test_dir
    local us_dir="$TEMP_DIR/projets/TEST/us-1234"
    create_extraction_api_format "$us_dir"

    # Exécuter la génération de questions
    bash "$GENERATE_SCRIPT" questions "$us_dir" >/dev/null 2>&1
    local exit_code=$?

    test_assert_equal "Génération questions (API) retourne 0" "$exit_code" "0"
    test_assert_file_exists "01-questions-clarifications.md existe" "$us_dir/01-questions-clarifications.md"

    # Vérifier que le ticket key est correct dans le fichier généré
    if [ -f "$us_dir/01-questions-clarifications.md" ]; then
        local has_key
        has_key=$(grep -c "TEST-1234" "$us_dir/01-questions-clarifications.md" || echo "0")
        test_assert "Fichier contient la clé TEST-1234" "[ $has_key -gt 0 ]"

        local has_title
        has_title=$(grep -c "recherche avancée" "$us_dir/01-questions-clarifications.md" || echo "0")
        test_assert "Fichier contient le titre" "[ $has_title -gt 0 ]"
    fi

    teardown_test_dir
}

# --- Test : format API - génération des 3 documents (all) ---
test_api_all_documents() {
    setup_test_dir
    local us_dir="$TEMP_DIR/projets/TEST/us-1234"
    create_extraction_api_format "$us_dir"

    bash "$GENERATE_SCRIPT" all "$us_dir" >/dev/null 2>&1
    local exit_code=$?

    test_assert_equal "Génération all (API) retourne 0" "$exit_code" "0"
    test_assert_file_exists "01-questions-clarifications.md existe" "$us_dir/01-questions-clarifications.md"
    test_assert_file_exists "02-strategie-test.md existe" "$us_dir/02-strategie-test.md"
    test_assert_file_exists "03-cas-test.md existe" "$us_dir/03-cas-test.md"

    # Vérifier que chaque document est non vide
    for doc in "01-questions-clarifications.md" "02-strategie-test.md" "03-cas-test.md"; do
        if [ -f "$us_dir/$doc" ]; then
            local size
            size=$(wc -c < "$us_dir/$doc" | tr -d ' ')
            test_assert "$doc est non vide (>100 octets)" "[ $size -gt 100 ]"
        fi
    done

    teardown_test_dir
}

# --- Test : format legacy - extraction du ticket key ---
test_legacy_metadata_extraction() {
    setup_test_dir
    local us_dir="$TEMP_DIR/projets/LEGACY/us-5678"
    mkdir -p "$us_dir"
    create_extraction_legacy_format "$us_dir"

    bash "$GENERATE_SCRIPT" questions "$us_dir" >/dev/null 2>&1
    local exit_code=$?

    test_assert_equal "Génération questions (legacy) retourne 0" "$exit_code" "0"
    test_assert_file_exists "01-questions-clarifications.md existe (legacy)" "$us_dir/01-questions-clarifications.md"

    if [ -f "$us_dir/01-questions-clarifications.md" ]; then
        local has_key
        has_key=$(grep -c "LEGACY-5678" "$us_dir/01-questions-clarifications.md" || echo "0")
        test_assert "Fichier contient la clé LEGACY-5678" "[ $has_key -gt 0 ]"
    fi

    teardown_test_dir
}

# --- Test : erreur si extraction-jira.md manquant ---
test_missing_extraction() {
    setup_test_dir
    local us_dir="$TEMP_DIR/projets/TEST/us-9999"
    mkdir -p "$us_dir"
    # Pas de extraction-jira.md

    bash "$GENERATE_SCRIPT" questions "$us_dir" >/dev/null 2>&1
    local exit_code=$?

    test_assert "Retourne erreur si extraction-jira.md manquant" "[ $exit_code -ne 0 ]"

    teardown_test_dir
}

# --- Test : erreur si dossier US inexistant ---
test_missing_us_dir() {
    bash "$GENERATE_SCRIPT" questions "/nonexistent/dir" >/dev/null 2>&1
    local exit_code=$?

    test_assert "Retourne erreur si dossier inexistant" "[ $exit_code -ne 0 ]"
}

# --- Test : erreur si arguments manquants ---
test_missing_arguments() {
    bash "$GENERATE_SCRIPT" >/dev/null 2>&1
    local exit_code=$?

    test_assert "Retourne erreur sans arguments" "[ $exit_code -ne 0 ]"
}

# --- Test : stratégie contient la description ---
test_strategy_has_description() {
    setup_test_dir
    local us_dir="$TEMP_DIR/projets/TEST/us-1234"
    create_extraction_api_format "$us_dir"

    bash "$GENERATE_SCRIPT" strategy "$us_dir" >/dev/null 2>&1

    if [ -f "$us_dir/02-strategie-test.md" ]; then
        local has_desc
        has_desc=$(grep -c "recherche avancée" "$us_dir/02-strategie-test.md" || echo "0")
        test_assert "Stratégie contient des éléments de la description" "[ $has_desc -gt 0 ]"
    fi

    teardown_test_dir
}

# --- Test : cas de test contient des scénarios ---
test_cases_has_scenarios() {
    setup_test_dir
    local us_dir="$TEMP_DIR/projets/TEST/us-1234"
    create_extraction_api_format "$us_dir"

    bash "$GENERATE_SCRIPT" test-cases "$us_dir" >/dev/null 2>&1

    if [ -f "$us_dir/03-cas-test.md" ]; then
        local has_scenario
        has_scenario=$(grep -ic "scénario\|scenario\|cas " "$us_dir/03-cas-test.md" || echo "0")
        test_assert "Cas de test contient des scénarios" "[ $has_scenario -gt 0 ]"
    fi

    teardown_test_dir
}

# ── Exécution ────────────────────────────────────────────────────────────────

test_api_metadata_extraction
test_api_all_documents
test_legacy_metadata_extraction
test_missing_extraction
test_missing_us_dir
test_missing_arguments
test_strategy_has_description
test_cases_has_scenarios

test_summary
exit $?
