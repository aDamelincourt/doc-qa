#!/bin/bash

# =============================================================================
# Tests pour validate-docs.sh
# =============================================================================

set -euo pipefail

TEST_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$TEST_DIR/test-helpers.sh"

SCRIPT_DIR="$(cd "$TEST_DIR/../scripts" && pwd)"
VALIDATE_SCRIPT="$SCRIPT_DIR/validate-docs.sh"

# ── Setup ────────────────────────────────────────────────────────────────────

TMP_DIR=$(mktemp -d)
trap 'rm -rf "$TMP_DIR"' EXIT

# Créer une structure de documents valide
create_valid_docs() {
    local dir="$1"
    # Le validate-docs.sh déduit le ticket key depuis la structure du chemin :
    # parent_dir-us_num → ex: SPEX-1234 si on a .../SPEX/us-1234/
    # Pour nos tests, on crée cette structure complète.
    mkdir -p "$dir"

    # README.md
    cat > "$dir/README.md" <<'EOF'
# Documentation QA — SPEX-1234

## Informations
| Champ | Valeur |
| --- | --- |
| Ticket | SPEX-1234 |
| Statut QA | Documenté |

## Documents
- 01-questions.md
- 02-strategie.md
- 03-cas-test.md
EOF

    # extraction-jira.md
    cat > "$dir/extraction-jira.md" <<'EOF'
# Contexte complet — SPEX-1234
## Description
Ceci est une description de test suffisamment longue pour satisfaire le seuil de taille minimale.
Encore du texte pour atteindre la taille requise par la validation.
## Critères d'acceptation
- Critère 1
- Critère 2
## Commentaires
Aucun commentaire pour le moment.
EOF

    # 01-questions.md (nom attendu par validate-docs.sh)
    cat > "$dir/01-questions.md" <<'EOF'
# Questions et Clarifications — SPEX-1234

## Fonctionnelles
1. Question fonctionnelle 1 ?
2. Question fonctionnelle 2 ?
3. Question fonctionnelle 3 ?

## Techniques
4. Question technique 1 ?
5. Question technique 2 ?

## UX/Design
6. Question UX 1 ?
EOF

    # 02-strategie.md (nom attendu par validate-docs.sh)
    cat > "$dir/02-strategie.md" <<'EOF'
# Stratégie de Test — SPEX-1234

## Périmètre
Le périmètre de test couvre les fonctionnalités.

## Approche
Approche basée sur les risques.

## Environnement
Tests sur staging.

## Priorités
Haute priorité pour les tests fonctionnels.
EOF

    # 03-cas-test.md
    cat > "$dir/03-cas-test.md" <<'EOF'
# Cas de Test — SPEX-1234

## Métadonnées
- Ticket: SPEX-1234

### Scénario 1 : Connexion valide
**Objectif** : Vérifier la connexion
**Étapes** :
1. Aller sur la page de login
2. Entrer les identifiants
**Résultat attendu** : Connexion réussie

### Scénario 2 : Connexion invalide
**Objectif** : Vérifier le rejet
**Étapes** :
1. Aller sur la page de login
2. Entrer des identifiants invalides
**Résultat attendu** : Message d'erreur

### Scénario 3 : Déconnexion
**Objectif** : Vérifier la déconnexion
**Étapes** :
1. Cliquer sur déconnexion
**Résultat attendu** : Retour à la page de login
EOF
}

# ── Tests ────────────────────────────────────────────────────────────────────

test_suite "validate-docs.sh"

# Test 1 : Documents valides
# Structure : TMP_DIR/SPEX/us-1234/ pour que le ticket key soit SPEX-1234
VALID_DIR="$TMP_DIR/SPEX/us-1234"
create_valid_docs "$VALID_DIR"
if bash "$VALIDATE_SCRIPT" "$VALID_DIR" > /dev/null 2>&1; then
    test_assert "Documents valides passent la validation" "true"
else
    test_assert "Documents valides passent la validation" "false"
fi

# Test 2 : Répertoire inexistant
if bash "$VALIDATE_SCRIPT" "$TMP_DIR/non-existent" > /dev/null 2>&1; then
    test_assert "Répertoire inexistant retourne erreur" "false"
else
    test_assert "Répertoire inexistant retourne erreur" "true"
fi

# Test 3 : Sans argument
if bash "$VALIDATE_SCRIPT" > /dev/null 2>&1; then
    test_assert "Sans argument retourne code 2" "false"
else
    test_assert "Sans argument retourne code 2" "true"
fi

# Test 4 : Fichier README manquant
MISSING_README_DIR="$TMP_DIR/PROJ1/us-100"
create_valid_docs "$MISSING_README_DIR"
rm "$MISSING_README_DIR/README.md"
if bash "$VALIDATE_SCRIPT" "$MISSING_README_DIR" > /dev/null 2>&1; then
    test_assert "README manquant cause un échec" "false"
else
    test_assert "README manquant cause un échec" "true"
fi

# Test 5 : Fichier de cas de test manquant
MISSING_TESTS_DIR="$TMP_DIR/PROJ2/us-200"
create_valid_docs "$MISSING_TESTS_DIR"
rm "$MISSING_TESTS_DIR/03-cas-test.md"
if bash "$VALIDATE_SCRIPT" "$MISSING_TESTS_DIR" > /dev/null 2>&1; then
    test_assert "03-cas-test.md manquant cause un échec" "false"
else
    test_assert "03-cas-test.md manquant cause un échec" "true"
fi

# Test 6 : Fichier trop petit
SMALL_DIR="$TMP_DIR/PROJ3/us-300"
create_valid_docs "$SMALL_DIR"
echo "tiny" > "$SMALL_DIR/01-questions.md"
if bash "$VALIDATE_SCRIPT" "$SMALL_DIR" > /dev/null 2>&1; then
    test_assert "Fichier trop petit cause un échec" "false"
else
    test_assert "Fichier trop petit cause un échec" "true"
fi

# Test 7 : Mode strict avec --strict
if bash "$VALIDATE_SCRIPT" "$VALID_DIR" --strict > /dev/null 2>&1; then
    test_assert "Mode --strict accepte des documents valides" "true"
else
    test_assert "Mode --strict accepte des documents valides" "false"
fi

test_summary
