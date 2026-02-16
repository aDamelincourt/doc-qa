#!/bin/bash

# =============================================================================
# generate-from-context.sh
# Génère un document QA à partir de extraction-jira.md (API ou XML).
# C'est le générateur "fallback" quand Cursor AI n'est pas disponible.
# Fonctionne SANS fichier XML -- seulement extraction-jira.md est requis.
#
# Usage :
#   ./scripts/generate-from-context.sh questions  projets/SPEX/us-3143
#   ./scripts/generate-from-context.sh strategy   projets/SPEX/us-3143
#   ./scripts/generate-from-context.sh test-cases projets/SPEX/us-3143
#   ./scripts/generate-from-context.sh all        projets/SPEX/us-3143
# =============================================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LIB_DIR="$SCRIPT_DIR/lib"
source "$LIB_DIR/config.sh"
source "$LIB_DIR/common-functions.sh"

DOC_TYPE="${1:-}"
US_DIR="${2:-}"

if [ -z "$DOC_TYPE" ] || [ -z "$US_DIR" ]; then
    echo "Usage : $0 questions|strategy|test-cases|all US_DIR"
    exit 1
fi

if [ ! -d "$US_DIR" ]; then
    log_error "Dossier US introuvable : $US_DIR"
    exit 1
fi

EXTRACTION="$US_DIR/extraction-jira.md"
if [ ! -f "$EXTRACTION" ]; then
    log_error "extraction-jira.md introuvable dans $US_DIR"
    exit 1
fi

# ── Extraction des métadonnées depuis extraction-jira.md ─────────────────────
# Supporte 2 formats :
#   - API    : "# SPEX-3143: Titre de la story"
#   - Legacy : "# Extraction Jira - SPEX-3143" + "**Titre/Summary** : ..."

# Ticket key
TICKET_KEY=$(head -1 "$EXTRACTION" | sed -n 's/^# \([A-Z]*-[0-9]*\):.*/\1/p')
if [ -z "$TICKET_KEY" ]; then
    # Format legacy : "# Extraction Jira - SPEX-2990"
    TICKET_KEY=$(head -1 "$EXTRACTION" | sed -n 's/.*- \([A-Z]*-[0-9]*\).*/\1/p')
fi
if [ -z "$TICKET_KEY" ]; then
    # Fallback : lire la ligne "**Clé du ticket**"
    TICKET_KEY=$(grep -m1 'Clé du ticket' "$EXTRACTION" | sed 's/.*: //' | tr -d '* ' || echo "")
fi
if [ -z "$TICKET_KEY" ]; then
    # Dernier recours : construire depuis le chemin
    local_num=$(basename "$US_DIR" | sed 's/us-//')
    local_project=$(basename "$(dirname "$US_DIR")")
    TICKET_KEY="${local_project}-${local_num}"
fi

# Titre
TITLE=$(head -1 "$EXTRACTION" | sed "s/^# ${TICKET_KEY}: //" | sed 's/^# Extraction Jira.*//')
if [ -z "$TITLE" ] || [ "$TITLE" = "$(head -1 "$EXTRACTION")" ]; then
    # Format legacy : "**Titre/Summary** : ..."
    TITLE=$(grep -m1 'Titre\|Summary\|Résumé' "$EXTRACTION" | sed 's/.*: //' | sed 's/^\*\*.*\*\* : //' || echo "N/A")
fi

# Projet
PROJECT=$(echo "$TICKET_KEY" | sed 's/-[0-9]*//')

# Lien Jira
JIRA_LINK=$(grep -m1 'Lien Jira\|Lien Jira' "$EXTRACTION" | sed 's/.*: //' | sed 's/^- //' || echo "")
if [ -z "$JIRA_LINK" ]; then
    JIRA_LINK="${JIRA_BASE_URL:-https://prestashop-jira.atlassian.net}/browse/$TICKET_KEY"
fi

# Description — supporte les deux formats de section
DESCRIPTION=$(sed -n '/^## .*escription/,/^## /{//d;p;}' "$EXTRACTION" | head -30)

# Critères d'acceptation — supporte "## Critères" et "Acceptance Criteria" dans la description
AC_SECTION=$(sed -n '/^## Crit/,/^## /{//d;p;}' "$EXTRACTION" 2>/dev/null || echo "")
if [ -z "$AC_SECTION" ]; then
    # Tenter d'extraire les Given/When/Then de la description ou du fichier entier
    AC_SECTION=$(grep -iE '^\s*(Given|When|Then|And|But|Scenario|Étant|Lorsque|Alors)' "$EXTRACTION" 2>/dev/null || echo "")
fi

# Commentaires
COMMENTS_SECTION=$(sed -n '/^## Commentaires/,/^## /{//d;p;}' "$EXTRACTION" 2>/dev/null | head -50 || echo "")

# Date du jour
TODAY=$(date +"%Y-%m-%d")

log_info "Génération pour $TICKET_KEY: $TITLE"

# ── Fonctions de génération ──────────────────────────────────────────────────

generate_questions() {
    local output="$US_DIR/01-questions-clarifications.md"
    log_info "Génération de $output..."

    cat > "$output" <<QUESTIONS_EOF
# $TITLE - Questions et Clarifications

## Informations générales

- **Feature** : $TITLE
- **User Story** : $TICKET_KEY : $TITLE
- **Date de création** : $TODAY
- **Auteur** : QA Automatisé (pipeline Doc QA)
- **Statut** : A valider
- **Lien Jira** : $JIRA_LINK

---

## Pour le Product Manager (PM)

### Règles métier et critères d'acceptation

QUESTIONS_EOF

    # Générer des questions à partir des scénarios/AC
    local q_num=1
    if [ -n "$AC_SECTION" ]; then
        # Extraire les lignes de scénarios
        local scenarios
        scenarios=$(echo "$AC_SECTION" | grep -iE '^\s*Scenario' | head -10 || true)
        if [ -n "$scenarios" ]; then
            while IFS= read -r line; do
                local clean_line
                clean_line=$(echo "$line" | sed 's/^[[:space:]]*//' | sed 's/"/\\"/g')
                echo "" >> "$output"
                echo "$q_num. Concernant le scénario : \"$clean_line\" — Quels sont les cas limites non couverts ?" >> "$output"
                echo "   - **Contexte** : Critère d'acceptation à clarifier" >> "$output"
                echo "   - **Réponse** : _A compléter_" >> "$output"
                q_num=$((q_num + 1))
            done <<< "$scenarios"
        fi
    fi

    cat >> "$output" <<QUESTIONS_MORE

$q_num. Quels sont les messages d'erreur exacts attendus pour chaque cas d'échec ?
   - **Contexte** : Nécessaire pour la validation des cas d'erreur
   - **Réponse** : _A compléter_

$((q_num + 1)). Quels types d'utilisateurs sont concernés par cette fonctionnalité ?
   - **Contexte** : Impact sur les scénarios de test selon les rôles
   - **Réponse** : _A compléter_

$((q_num + 2)). Y a-t-il des limites de volume ou de fréquence d'utilisation ?
   - **Contexte** : Nécessaire pour les tests de performance
   - **Réponse** : _A compléter_

### Cas limites et comportements edge cases

$((q_num + 3)). Que se passe-t-il en cas de connexion interrompue pendant l'opération ?
   - **Contexte** : Comportement réseau dégradé
   - **Réponse** : _A compléter_

$((q_num + 4)). Quelles sont les valeurs minimales et maximales acceptées pour les champs de saisie ?
   - **Contexte** : Validation des bornes
   - **Réponse** : _A compléter_

$((q_num + 5)). Comment la fonctionnalité se comporte-t-elle avec des données existantes (migration) ?
   - **Contexte** : Compatibilité ascendante
   - **Réponse** : _A compléter_

---

## Pour les Développeurs (Dev)

### Architecture et implémentation

$((q_num + 6)). Quels endpoints API sont impactés ? Y a-t-il des changements de contrat ?
   - **Contexte** : Impact sur les tests d'intégration
   - **Réponse** : _A compléter_

$((q_num + 7)). Y a-t-il des logs spécifiques à ajouter pour le monitoring ?
   - **Contexte** : Observabilité et debugging
   - **Réponse** : _A compléter_

$((q_num + 8)). Quelles sont les dépendances techniques (services, bases de données) ?
   - **Contexte** : Impact sur l'environnement de test
   - **Réponse** : _A compléter_

$((q_num + 9)). Y a-t-il des impacts sur les performances (requêtes, cache, index) ?
   - **Contexte** : Tests de performance à prévoir
   - **Réponse** : _A compléter_

---

## Pour les Designers (UX/UI)

### Interface et expérience utilisateur

$((q_num + 10)). Quel est le comportement attendu en responsive (mobile, tablette) ?
   - **Contexte** : Tests de compatibilité
   - **Réponse** : _A compléter_

$((q_num + 11)). Y a-t-il des animations ou transitions spécifiques ?
   - **Contexte** : Vérification de l'expérience utilisateur
   - **Réponse** : _A compléter_

$((q_num + 12)). Les maquettes couvrent-elles tous les états (vide, chargement, erreur, succès) ?
   - **Contexte** : Exhaustivité des tests visuels
   - **Réponse** : _A compléter_

---

> **Note** : Ce document a été généré automatiquement depuis le contexte Jira.
> Il doit être enrichi manuellement ou régénéré avec Cursor AI pour plus de détails.
> Commande : \`make process-force T=$TICKET_KEY\`
QUESTIONS_MORE

    log_success "01-questions-clarifications.md généré ($TICKET_KEY)"
}

generate_strategy() {
    local output="$US_DIR/02-strategie-test.md"
    log_info "Génération de $output..."

    cat > "$output" <<STRATEGY_EOF
# $TITLE - Stratégie de Test

## Informations générales

- **Feature** : $TITLE
- **User Story** : $TICKET_KEY : $TITLE
- **Date de création** : $TODAY
- **Auteur** : QA Automatisé (pipeline Doc QA)
- **Statut** : Draft
- **Lien Jira** : $JIRA_LINK

---

## Objectif de la fonctionnalité

**Description** :

$DESCRIPTION

**User Story couverte** :

- $TICKET_KEY : $TITLE

---

## Prérequis

### Environnement

- **Navigateurs** : Chrome (dernière version), Firefox, Safari, Edge
- **Résolutions** : Desktop (1920x1080), Tablette (768x1024), Mobile (375x667)

### Données nécessaires

- [ ] Utilisateur de test avec les permissions appropriées
- [ ] Environnement de staging configuré
- [ ] Données de test préparées

---

## Axes de test

### 1. Scénarios nominaux

- **Objectif** : Valider les parcours utilisateur standards décrits dans les AC
- **Approche** : Exécuter chaque critère d'acceptation dans les conditions normales
- **Points de vigilance** : Vérifier que chaque AC est couvert par au moins un scénario

### 2. Cas limites et robustesse

- **Objectif** : Tester les valeurs extrêmes et conditions limites
- **Approche** : Identifier les bornes (min/max) et les tester systématiquement
- **Points de vigilance** : Champs vides, valeurs maximales, caractères spéciaux

### 3. Gestion des erreurs

- **Objectif** : Valider les messages d'erreur et le comportement en cas d'échec
- **Approche** : Provoquer chaque type d'erreur identifié
- **Points de vigilance** : Messages clairs, pas de perte de données, retour à l'état stable

### 4. Sécurité et autorisations

- **Objectif** : Vérifier les contrôles d'accès et la protection des données
- **Approche** : Tester avec différents rôles et niveaux d'autorisation
- **Points de vigilance** : CSRF, injection, accès non autorisés

### 5. Performance

- **Objectif** : Valider les temps de réponse et le comportement sous charge
- **Approche** : Mesurer les temps de réponse des opérations critiques
- **Points de vigilance** : Temps de chargement < 3s, pas de dégradation

### 6. Intégration

- **Objectif** : Valider les interactions avec les autres composants/services
- **Approche** : Tester les flux de bout en bout
- **Points de vigilance** : Cohérence des données entre systèmes

### 7. Compatibilité

- **Objectif** : Vérifier le fonctionnement sur différents environnements
- **Approche** : Tester sur les navigateurs et résolutions cibles
- **Points de vigilance** : Comportement identique sur tous les supports

### 8. Accessibilité

- **Objectif** : Vérifier la conformité WCAG 2.1 AA
- **Approche** : Navigation clavier, lecteur d'écran, contrastes
- **Points de vigilance** : Focus visible, labels, rôles ARIA

---

## Risques identifiés

| Risque | Probabilité | Impact | Mitigation |
|--------|------------|--------|------------|
| Régression sur fonctionnalités existantes | Moyen | Élevé | Tests de régression ciblés |
| Problèmes de performance | Faible | Élevé | Tests de charge précoces |
| Incompatibilité navigateur | Faible | Moyen | Tests cross-browser |

---

## Priorités de test

1. **Critique** : Scénarios nominaux (AC), gestion des erreurs bloquantes
2. **Important** : Cas limites, sécurité, intégration
3. **Normal** : Performance, compatibilité
4. **Faible** : Accessibilité, scénarios rares

---

> **Note** : Ce document a été généré automatiquement depuis le contexte Jira.
> Enrichir avec Cursor AI : \`make process-force T=$TICKET_KEY\`
STRATEGY_EOF

    log_success "02-strategie-test.md généré ($TICKET_KEY)"
}

generate_test_cases() {
    local output="$US_DIR/03-cas-test.md"
    log_info "Génération de $output..."

    cat > "$output" <<TESTCASES_HEADER
# $TITLE - Cas de Test

## Informations générales

- **Feature** : $TITLE
- **User Story** : $TICKET_KEY : $TITLE
- **Date de création** : $TODAY
- **Auteur** : QA Automatisé (pipeline Doc QA)
- **Statut** : Draft
- **Lien Jira** : $JIRA_LINK

---

## Documents associés

- **Stratégie de test** : [02-strategie-test.md](02-strategie-test.md)
- **Questions et Clarifications** : [01-questions-clarifications.md](01-questions-clarifications.md)
- **Extraction Jira** : [extraction-jira.md](extraction-jira.md)

---

## Scénarios de test

### CAS NOMINAUX

TESTCASES_HEADER

    # Générer des scénarios à partir des critères d'acceptation
    local scenario_num=1

    if [ -n "$AC_SECTION" ]; then
        # Extraire les blocs Given/When/Then (supporte espaces en début de ligne)
        local current_given=""
        local current_when=""
        local current_then=""

        while IFS= read -r line; do
            local trimmed
            trimmed=$(echo "$line" | sed 's/^[[:space:]]*//')
            local lower_trimmed
            lower_trimmed=$(echo "$trimmed" | tr '[:upper:]' '[:lower:]')

            if echo "$lower_trimmed" | grep -qiE '^(given|étant donné)'; then
                current_given="$trimmed"
            elif echo "$lower_trimmed" | grep -qiE '^(when|lorsque)'; then
                current_when="$trimmed"
            elif echo "$lower_trimmed" | grep -qiE '^(then|alors)'; then
                current_then="$trimmed"

                # Bloc complet : générer le scénario
                if [ -n "$current_given" ] && [ -n "$current_when" ]; then
                    local short_when="${current_when:0:60}"
                    echo "" >> "$output"
                    echo "### Scénario $scenario_num : ${short_when}" >> "$output"
                    echo "" >> "$output"
                    echo "**Objectif** : Vérifier le comportement décrit dans les AC" >> "$output"
                    echo "" >> "$output"
                    echo "**Étapes** :" >> "$output"
                    echo "" >> "$output"
                    echo "1. $current_given" >> "$output"
                    echo "2. $current_when" >> "$output"
                    echo "" >> "$output"
                    echo "**Résultat attendu** :" >> "$output"
                    echo "" >> "$output"
                    echo "- $current_then" >> "$output"
                    echo "" >> "$output"
                    echo "**Statut** : [ ] A exécuter" >> "$output"
                    echo "" >> "$output"
                    echo "---" >> "$output"

                    scenario_num=$((scenario_num + 1))
                    current_given=""
                    current_when=""
                    current_then=""
                fi
            fi
        done <<< "$AC_SECTION"
    fi

    # Ajouter des scénarios génériques si peu de scénarios ont été générés
    cat >> "$output" <<TESTCASES_GENERIC

### Scénario $scenario_num : Parcours nominal complet

**Objectif** : Vérifier le parcours utilisateur standard de bout en bout

**Étapes** :

1. Se connecter avec un utilisateur ayant les permissions requises
2. Accéder à la fonctionnalité "$TITLE"
3. Effectuer l'action principale décrite dans la User Story
4. Vérifier le résultat

**Résultat attendu** :

- L'action se déroule sans erreur
- Les données sont correctement sauvegardées
- L'interface affiche la confirmation

**Statut** : [ ] A exécuter

---

### CAS LIMITES

### Scénario $((scenario_num + 1)) : Champs vides / données manquantes

**Objectif** : Vérifier le comportement avec des données incomplètes

**Étapes** :

1. Accéder à la fonctionnalité
2. Laisser les champs obligatoires vides
3. Tenter la validation

**Résultat attendu** :

- Les champs obligatoires sont signalés
- Un message d'erreur clair est affiché
- Aucune donnée n'est enregistrée

**Statut** : [ ] A exécuter

---

### CAS D'ERREUR

### Scénario $((scenario_num + 2)) : Erreur réseau pendant l'opération

**Objectif** : Vérifier la gestion de la perte de connexion

**Étapes** :

1. Commencer l'action principale
2. Simuler une coupure réseau
3. Rétablir la connexion

**Résultat attendu** :

- Un message d'erreur approprié est affiché
- Aucune donnée n'est corrompue
- L'utilisateur peut réessayer

**Statut** : [ ] A exécuter

---

### CAS DE SÉCURITÉ

### Scénario $((scenario_num + 3)) : Accès non autorisé

**Objectif** : Vérifier que les contrôles d'accès sont en place

**Étapes** :

1. Se connecter avec un utilisateur sans les permissions requises
2. Tenter d'accéder à la fonctionnalité

**Résultat attendu** :

- L'accès est refusé
- Un message approprié est affiché
- Aucune action n'est possible

**Statut** : [ ] A exécuter

---

## Résumé

| Catégorie | Nombre | Statut |
|-----------|--------|--------|
| Cas nominaux | $scenario_num | A exécuter |
| Cas limites | 1 | A exécuter |
| Cas d'erreur | 1 | A exécuter |
| Cas sécurité | 1 | A exécuter |
| **Total** | **$((scenario_num + 3))** | **A exécuter** |

---

> **Note** : Ce document a été généré automatiquement depuis le contexte Jira.
> Pour une couverture exhaustive, régénérer avec Cursor AI :
> \`make process-force T=$TICKET_KEY\`
TESTCASES_GENERIC

    log_success "03-cas-test.md généré ($TICKET_KEY)"
}

# ── Point d'entrée ───────────────────────────────────────────────────────────

case "$DOC_TYPE" in
    questions)  generate_questions ;;
    strategy)   generate_strategy ;;
    test-cases) generate_test_cases ;;
    all)
        generate_questions
        echo ""
        generate_strategy
        echo ""
        generate_test_cases
        ;;
    *)
        log_error "Type inconnu : $DOC_TYPE (attendu: questions|strategy|test-cases|all)"
        exit 1
        ;;
esac
