#!/bin/bash

# Bibliothèque pour utiliser l'agent IA intégré de Cursor
# Usage: source "$(dirname "${BASH_SOURCE[0]}")/lib/cursor-ai-utils.sh"

# Charger la configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
if [ -f "$SCRIPT_DIR/config.sh" ]; then
    source "$SCRIPT_DIR/config.sh"
fi

# Charger les autres bibliothèques nécessaires
if [ -f "$SCRIPT_DIR/common-functions.sh" ]; then
    source "$SCRIPT_DIR/common-functions.sh"
fi
if [ -f "$SCRIPT_DIR/xml-utils.sh" ]; then
    source "$SCRIPT_DIR/xml-utils.sh"
fi
if [ -f "$SCRIPT_DIR/acceptance-criteria-utils.sh" ]; then
    source "$SCRIPT_DIR/acceptance-criteria-utils.sh"
fi

# Préparer un contexte riche pour l'IA à partir du XML et du dossier US
# Usage: prepare_context_for_ai "/path/to/file.xml" "/path/to/us-dir"
prepare_context_for_ai() {
    local xml_file="$1"
    local us_dir="$2"
    
    if [ ! -f "$xml_file" ]; then
        log_error "Fichier XML introuvable : $xml_file"
        return 1
    fi
    
    if [ ! -d "$us_dir" ]; then
        log_error "Dossier US introuvable : $us_dir"
        return 1
    fi
    
    # Parser le XML
    if ! parse_xml_file "$xml_file"; then
        return 1
    fi
    
    # Extraire toutes les informations pertinentes
    local extraction_file="$us_dir/extraction-jira.md"
    local extraction_content=""
    if [ -f "$extraction_file" ]; then
        extraction_content=$(cat "$extraction_file")
    fi
    
    # Extraire les critères d'acceptation
    local acceptance_criteria=$(extract_acceptance_criteria "$xml_file" 2>/dev/null || echo "")
    
    # Extraire les commentaires
    local comments=$(extract_comments "$xml_file" 200 2>/dev/null || echo "")
    local comments_decoded=$(decode_html_cached "$comments" 2>/dev/null || echo "$comments")
    
    # Décoder la description
    local description_decoded=$(decode_html_cached "$DESCRIPTION_SECTION" 2>/dev/null || echo "$DESCRIPTION_SECTION")
    
    # Extraire les liens Figma et Miro
    local figma_links=$(extract_figma_links "$xml_file" 2>/dev/null || echo "")
    local miro_links=$(extract_miro_links "$xml_file" 2>/dev/null || echo "")
    
    # Extraire le statut, type, priorité
    local status=$(extract_status "$xml_file" 2>/dev/null || echo "")
    local type=$(extract_type "$xml_file" 2>/dev/null || echo "")
    local priority=$(extract_priority "$xml_file" 2>/dev/null || echo "")
    
    # Construire le contexte complet
    cat <<EOF
# Contexte complet de la User Story

## Informations générales du ticket

- **Clé du ticket** : $KEY
- **Titre** : $TITLE
- **Type** : ${type:-Story}
- **Statut** : ${status:-Non disponible}
- **Priorité** : ${priority:-Non disponible}
- **Lien Jira** : $LINK
- **Projet** : $PROJECT_NAME

## Description complète / User Story

$description_decoded

## Critères d'acceptation

$(if [ -n "$acceptance_criteria" ]; then
    echo "$acceptance_criteria" | while IFS='|' read -r ac_num title given when then_clause; do
        if [ -n "$ac_num" ] && [ -n "$title" ]; then
            echo "### $ac_num - $title"
            [ -n "$given" ] && echo "**Étant donné que** : $given"
            [ -n "$when" ] && echo "**Lorsque** : $when"
            [ -n "$then_clause" ] && echo "**Alors** : $then_clause"
            echo ""
        fi
    done
else
    echo "*Aucun critère d'acceptation trouvé dans le XML*"
fi)

## Commentaires de l'équipe

$(if [ -n "$comments_decoded" ]; then
    echo "$comments_decoded" | head -100
else
    echo "*Aucun commentaire trouvé*"
fi)

## Liens de design

$(if [ -n "$figma_links" ]; then
    echo "### Liens Figma"
    echo "$figma_links" | while read -r link; do
        [ -n "$link" ] && echo "- $link"
    done
    echo ""
fi)

$(if [ -n "$miro_links" ]; then
    echo "### Liens Miro (Event Modeling)"
    echo "$miro_links" | while read -r link; do
        [ -n "$link" ] && echo "- $link"
    done
    echo ""
fi)

## Extraction Jira complète

$(if [ -n "$extraction_content" ]; then
    echo "$extraction_content"
else
    echo "*Fichier extraction-jira.md non disponible*"
fi)

EOF
}

# Préparer un prompt optimisé pour l'agent Cursor
prepare_cursor_prompt() {
    local document_type="$1"  # questions, strategy, test-cases
    local context_data="$2"   # Données extraites du XML
    local template_file="$3"  # Fichier template
    local output_file="$4"    # Fichier de sortie pour le prompt
    
    if [ ! -f "$template_file" ]; then
        log_error "Template introuvable : $template_file"
        return 1
    fi
    
    local template_content=$(cat "$template_file")
    
    # Construire le prompt selon le type de document
    local instructions=""
    
    case "$document_type" in
        questions)
            instructions="Génère un document COMPLET et EXHAUSTIF de questions et clarifications au format Markdown.

INSTRUCTIONS DÉTAILLÉES :
- Génère le MAXIMUM de questions pertinentes (minimum 50-60 questions, idéalement 80+)
- Organise les questions par catégorie avec des sous-sections détaillées :
  * PM : Règles métier, critères d'acceptation, cas limites, comportements edge cases, messages utilisateur, workflows, dépendances métier
  * Dev : Architecture, validation (client/serveur), API endpoints, stockage, logs, données de test, persistance, sécurité technique, performance, intégrations
  * Designer : Feedback visuel, états UI, positionnement, responsive, accessibilité, animations, transitions, états de chargement
- Pour CHAQUE question :
  * Fournis un contexte DÉTAILLÉ expliquant pourquoi elle est importante
  * Identifie les risques si la question n'est pas clarifiée
  * Propose des exemples concrets si pertinent
- Identifie TOUTES les ambiguïtés dans :
  * Les critères d'acceptation (interprétations possibles)
  * La description (zones floues)
  * Les commentaires (contradictions potentielles)
- Propose des questions sur :
  * TOUS les cas limites non couverts explicitement
  * Les comportements en cas d'erreur (tous les types d'erreurs possibles)
  * Les données de test nécessaires (formats, tailles, variantes)
  * Les environnements (dev, staging, preprod, prod)
  * Les dépendances techniques et métier
  * Les intégrations avec d'autres systèmes
  * Les migrations de données si applicable
  * Les rollbacks et annulations
  * Les permissions et autorisations
  * Les performances attendues
  * Les limites et quotas
- Analyse en profondeur :
  * Les scénarios décrits dans les AC pour identifier les zones d'ombre
  * Les commentaires pour détecter les points soulevés par l'équipe
  * Les liens de design pour identifier les aspects UI non documentés
- Utilise le format du template fourni EXACTEMENT
- Sois ULTRA-exhaustif et créatif : pense à TOUS les aspects possibles
- Chaque question doit être actionnable et permettre une réponse claire"
            ;;
        strategy)
            instructions="Génère une stratégie de test COMPLÈTE, DÉTAILLÉE et EXHAUSTIVE au format Markdown.

INSTRUCTIONS DÉTAILLÉES :
- Identifie TOUS les axes de test pertinents (minimum 10-12 axes, idéalement 15+)
- Pour CHAQUE axe de test, fournis :
  * Un objectif clair et détaillé
  * Une approche méthodologique précise
  * Des points de vigilance spécifiques et actionnables
  * Des exemples concrets adaptés au contexte
  * Des métriques de succès mesurables
- Axes de test à couvrir en profondeur :
  * Scénarios nominaux (tous les parcours utilisateur possibles)
  * Cas limites et robustesse (valeurs extrêmes, conditions limites)
  * Gestion des erreurs (tous les types d'erreurs possibles avec détails)
  * Sécurité et autorisations (tous les aspects de sécurité)
  * Performance (charges, temps de réponse, scalabilité)
  * Intégration (toutes les intégrations avec détails)
  * Compatibilité (navigateurs, OS, résolutions, versions)
  * Accessibilité (WCAG, navigation clavier, lecteurs d'écran)
  * Régression (toutes les zones impactées)
  * Migration de données (si applicable)
  * Rollback et annulation (si applicable)
- Définis une stratégie ADAPTÉE au contexte :
  * Métier : Comprends le domaine métier et adapte la stratégie
  * Technique : Prends en compte l'architecture et les contraintes techniques
  * Utilisateur : Considère les différents types d'utilisateurs
- Précise en DÉTAIL :
  * Prérequis : Environnements, données, comptes, configurations
  * Données de test : Formats, tailles, variantes, cas limites
  * Environnements : Dev, staging, preprod avec spécificités
  * Outils : Outils de test nécessaires, frameworks, scripts
- Identifie TOUS les risques :
  * Risques fonctionnels (fonctionnalités impactées)
  * Risques techniques (performance, sécurité, intégration)
  * Risques métier (expérience utilisateur, données)
  * Risques de régression (zones critiques)
- Définis les priorités de test :
  * Critiques (bloquants)
  * Importants (impact significatif)
  * Normaux (fonctionnalités standard)
  * Faibles (nice-to-have)
- Propose un plan de test STRUCTURÉ :
  * Phases de test (unitaire, intégration, système, acceptation)
  * Ordre d'exécution logique
  * Dépendances entre tests
  * Estimation du temps nécessaire
- Utilise le format du template fourni EXACTEMENT
- Sois ULTRA-exhaustif : pense à TOUS les aspects possibles de test
- Adapte chaque section au contexte spécifique de cette US
- Fournis des exemples concrets et actionnables pour chaque point"
            ;;
        test-cases)
            instructions="Génère un document COMPLET et EXHAUSTIF de cas de test au format Markdown.

INSTRUCTIONS DÉTAILLÉES :
- Génère le MAXIMUM de cas de test pertinents (minimum 30-40 scénarios, idéalement 50+)
- Pour CHAQUE scénario, fournis TOUS les détails suivants :
  * Un titre CLAIR, DESCRIPTIF et ACTIONNABLE
  * Des étapes DÉTAILLÉES, NUMÉROTÉES et PRÉCISES :
    - Chaque étape doit être exécutable telle quelle
    - Inclus les actions exactes à effectuer
    - Précise les données à utiliser
    - Indique les vérifications intermédiaires
  * Des données de test PRÉCISES et RÉALISTES :
    - Formats exacts
    - Tailles spécifiques
    - Variantes nécessaires
    - Cas limites (min, max, valeurs spéciales)
  * Des résultats attendus DÉTAILLÉS avec :
    - Vérifications spécifiques et mesurables
    - Messages exacts attendus
    - Comportements UI précis
    - États système attendus
    - Données persistées attendues
  * Un objectif clair expliquant pourquoi ce test est important
  * Des prérequis spécifiques si nécessaire
- Organise par catégories COMPLÈTES :
  * CAS NOMINAUX : Tous les parcours utilisateur standards (minimum 5-8 scénarios)
  * CAS LIMITES : Valeurs extrêmes, conditions limites, edge cases (minimum 5-8 scénarios)
  * CAS D'ERREUR : Tous les types d'erreurs possibles (minimum 5-8 scénarios)
  * CAS DE PERFORMANCE : Charges, temps de réponse, volumétrie (minimum 3-5 scénarios)
  * CAS D'INTÉGRATION : Toutes les intégrations (minimum 3-5 scénarios)
  * CAS DE SÉCURITÉ : CSRF, autorisations, injection (minimum 3-5 scénarios)
  * CAS DE COMPATIBILITÉ : Navigateurs, OS, résolutions (minimum 2-3 scénarios)
  * CAS D'ACCESSIBILITÉ : Navigation clavier, lecteurs d'écran (minimum 2-3 scénarios)
  * CAS DE RÉGRESSION : Zones impactées (minimum 2-3 scénarios)
- Identifie TOUS les edge cases :
  * Cas limites non évidents
  * Comportements inattendus
  * Conditions rares mais possibles
  * Interactions complexes
- Génère des scénarios de régression :
  * Pour toutes les fonctionnalités connexes
  * Pour les zones critiques identifiées
  * Pour les dépendances
- Adapte les cas de test au contexte métier :
  * Utilise la terminologie métier exacte
  * Réfléchit aux workflows réels des utilisateurs
  * Considère les différents types d'utilisateurs
  * Prend en compte les contraintes métier
- Pour chaque critère d'acceptation :
  * Génère au minimum 2-3 scénarios de test
  * Couvre le cas nominal ET les cas limites
  * Inclus les vérifications de régression
- Utilise le format du template fourni EXACTEMENT
- Sois ULTRA-exhaustif : pense à TOUS les scénarios possibles
- Chaque scénario doit être COMPLET, ACTIONNABLE et DIRECTEMENT UTILISABLE pour l'exécution des tests
- Fournis des exemples concrets et réalistes pour chaque scénario"
            ;;
        *)
            log_error "Type de document non supporté : $document_type"
            return 1
            ;;
    esac
    
    # Créer le prompt complet et détaillé
    cat > "$output_file" <<EOF
# Prompt pour génération $document_type avec l'agent Cursor IA

## 🎯 OBJECTIF

Génère un document QA COMPLET, EXHAUSTIF et DÉTAILLÉ au format Markdown pour la User Story suivante.
Le document doit être directement utilisable par une équipe QA sans modification supplémentaire.

## 📋 CONTEXTE COMPLET DE LA USER STORY

$context_data

## 📝 TEMPLATE À SUIVRE EXACTEMENT

\`\`\`markdown
$template_content
\`\`\`

## 🎓 INSTRUCTIONS DÉTAILLÉES

$instructions

## ✅ CRITÈRES DE QUALITÉ

Le document généré doit respecter les critères suivants :

1. **Exhaustivité** : Couvre TOUS les aspects pertinents de la fonctionnalité
2. **Détail** : Chaque section est détaillée avec des exemples concrets
3. **Actionnabilité** : Le contenu est directement utilisable sans interprétation
4. **Contexte** : Adapté au contexte métier et technique spécifique
5. **Complétude** : Aucune section du template n'est laissée vide ou générique
6. **Précision** : Utilise la terminologie exacte du projet et du domaine

## 🚀 TÂCHE

Génère le contenu COMPLET au format Markdown en suivant EXACTEMENT le template et les instructions ci-dessus.
Le contenu doit être :
- Exhaustif (maximum de détails)
- Adapté au contexte spécifique de cette US
- Directement utilisable par l'équipe QA
- Formaté correctement en Markdown
- Prêt à être sauvegardé dans le fichier de sortie

## 📌 NOTES IMPORTANTES

- Analyse en profondeur le contexte fourni
- Identifie TOUS les aspects à couvrir
- Génère le MAXIMUM de contenu pertinent
- Sois créatif dans l'identification des points à traiter
- Adapte chaque section au contexte spécifique
- Fournis des exemples concrets et réalistes
EOF

    log_success "✅ Prompt préparé : $output_file"
    log_info "   Copiez le contenu et demandez à l'agent Cursor de générer le document"
}

# Générer directement avec l'agent Cursor (via fichier de prompt)
generate_with_cursor_agent() {
    local document_type="$1"
    local context_data="$2"
    local template_file="$3"
    local output_file="$4"
    
    # Créer un fichier de prompt temporaire
    local prompt_file=$(mktemp)
    prepare_cursor_prompt "$document_type" "$context_data" "$template_file" "$prompt_file"
    
    if [ $? -ne 0 ]; then
        rm -f "$prompt_file"
        return 1
    fi
    
    log_info "📋 Fichier de prompt créé : $prompt_file"
    log_info ""
    log_info "🤖 Pour générer avec l'agent Cursor :"
    log_info "   1. Ouvrez le fichier : $prompt_file"
    log_info "   2. Copiez tout le contenu"
    log_info "   3. Dans Cursor, demandez à l'agent :"
    log_info "      'Génère le document $document_type en suivant ce prompt : [coller le contenu]'"
    log_info "   4. L'agent générera le contenu que vous pourrez sauvegarder dans : $output_file"
    log_info ""
    log_info "   OU utilisez le script interactif :"
    log_info "   ./scripts/generate-with-cursor.sh $document_type [US_DIR]"
    
    echo "$prompt_file"
}

