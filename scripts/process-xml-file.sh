#!/bin/bash

# Script pour traiter un fichier XML Jira et préparer la génération de documentation QA
# Usage: ./scripts/process-xml-file.sh [FICHIER_XML]

set -euo pipefail

# Charger les bibliothèques communes
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LIB_DIR="$SCRIPT_DIR/lib"
source "$LIB_DIR/config.sh"
source "$LIB_DIR/common-functions.sh"
source "$LIB_DIR/xml-utils.sh"
source "$LIB_DIR/processing-utils.sh"
source "$LIB_DIR/ticket-utils.sh"
source "$LIB_DIR/history-utils.sh"

# Gestion des erreurs avec trap
cleanup_on_error() {
    log_error "Erreur lors du traitement. Nettoyage..."
    exit 1
}
trap cleanup_on_error ERR

if [ -z "${1:-}" ]; then
    log_error "Fichier XML requis"
    echo "Usage: ./scripts/process-xml-file.sh [FICHIER_XML]"
    exit 1
fi

XML_FILE="$1"

# Valider le fichier XML
if ! validate_xml "$XML_FILE"; then
    exit 1
fi

# Parser le XML une fois
if ! parse_xml_file "$XML_FILE"; then
    exit 1
fi

PROJECT_DIR=$(basename "$(dirname "$XML_FILE")")
TICKET_ID=$(basename "$XML_FILE" .xml)
DESCRIPTION=$(extract_description "$XML_FILE" 20)

log_info "Informations extraites :"
log_info "   Projet : $PROJECT_DIR"
log_info "   Ticket : $KEY"
log_info "   Titre : $TITLE"
echo ""

# Vérifier si le ticket a déjà été traité (via historique)
if is_ticket_processed "$KEY"; then
    existing_info=$(get_treatment_info "$KEY")
    existing_dir=$(echo "$existing_info" | cut -d'|' -f1)
    existing_date=$(echo "$existing_info" | cut -d'|' -f2)
    
    log_warning "Le ticket $KEY a déjà été traité le $existing_date"
    log_info "   Dossier existant : $existing_dir"
    
    if [ -d "$existing_dir" ] && [ -f "$existing_dir/README.md" ]; then
        log_info "   Le dossier existe toujours et contient de la documentation"
        
        if [ "$DRY_RUN" != "true" ]; then
            read -p "Voulez-vous régénérer la documentation ? (o/N) " -n 1 -r
            echo
            if [[ ! $REPLY =~ ^[Oo]$ ]]; then
                log_info "Utilisation du dossier existant : $existing_dir"
                US_DIR="$existing_dir"
            else
                # Continuer avec la régénération
                US_DIR="$existing_dir"
            fi
        else
            log_info "DRY-RUN : Le dossier $existing_dir serait utilisé"
            US_DIR="$existing_dir"
        fi
    else
        log_warning "   Le dossier enregistré n'existe plus, création d'un nouveau dossier"
        # Continuer avec la création d'un nouveau dossier
        US_DIR=""
    fi
else
    US_DIR=""
fi

# Créer la structure de dossiers si nécessaire
if [ -z "$US_DIR" ]; then
    # Structure simplifiée : projets/PROJECT/us-XXXX (sans sous-dossiers)
    TICKET_NUMBER=$(get_ticket_number "$KEY")
    US_DIR="$PROJETS_DIR/$PROJECT_DIR/us-$TICKET_NUMBER"
    
    # Vérifier les permissions d'écriture
    if ! check_write_permissions "$PROJETS_DIR"; then
        exit 1
    fi
    
    if [ -d "$US_DIR" ]; then
        log_warning "Le dossier $US_DIR existe déjà"
        
        # Vérifier s'il y a déjà des fichiers de documentation
        if [ -f "$US_DIR/README.md" ] || [ -f "$US_DIR/01-questions-clarifications.md" ]; then
            log_warning "Des fichiers de documentation existent déjà dans ce dossier"
            log_info "   Pour éviter d'écraser, le script va créer un nouveau dossier ou demander confirmation"
        fi
        
        if [ "$DRY_RUN" != "true" ]; then
            read -p "Voulez-vous continuer et écraser ? (o/N) " -n 1 -r
            echo
            if [[ ! $REPLY =~ ^[Oo]$ ]]; then
                log_error "Abandonné"
                exit 1
            fi
        else
            log_info "DRY-RUN : Le dossier serait écrasé"
        fi
    fi
    
    if [ "$DRY_RUN" != "true" ]; then
        if ! safe_mkdir "$US_DIR"; then
            exit 1
        fi
    else
        log_info "DRY-RUN : Le répertoire $US_DIR serait créé"
    fi
    
    log_success "Structure créée : $US_DIR"
    echo ""
fi

if [ "$DRY_RUN" = "true" ]; then
    log_info "DRY-RUN : Les fichiers suivants seraient créés :"
    log_info "  - $US_DIR/extraction-jira.md"
    log_info "  - $US_DIR/README.md"
    log_info "  - $US_DIR/01-questions-clarifications.md"
    log_info "  - $US_DIR/02-strategie-test.md"
    log_info "  - $US_DIR/03-cas-test.md"
    exit 0
fi

# Créer un fichier d'extraction structuré
EXTRACTION_FILE="$US_DIR/extraction-jira.md"
cat > "$EXTRACTION_FILE" <<EOF
# Extraction Jira - $KEY

## 📋 Informations générales

**Clé du ticket** : $KEY
**Titre/Summary** : $TITLE
**Type** : Story
**Statut** : [À extraire manuellement]
**Lien Jira** : $LINK

## 📝 Description / User Story

\`\`\`
$(echo "$DESCRIPTION" | head -100)
\`\`\`

> **Note** : Description complète disponible dans le fichier XML : \`../Jira/$PROJECT_DIR/$TICKET_ID.xml\`

## ✅ Critères d'acceptation

[À extraire manuellement depuis le XML - section Acceptance Criteria]

## 💻 Informations techniques

[À extraire manuellement depuis les commentaires du XML]

## 🎨 Designs

[À extraire manuellement depuis le XML - liens Figma]

## 📝 Commentaires de l'équipe

[À extraire manuellement depuis le XML - balise <comment>]

---

**Date d'extraction** : $(date +"%Y-%m-%d")
**Fichier source** : Jira/$PROJECT_DIR/$TICKET_ID.xml
EOF

log_success "Fichier d'extraction créé : extraction-jira.md"
echo ""

# Créer le README de l'US
if ! validate_file "$TEMPLATES_DIR/us-readme-template.md"; then
    exit 1
fi

cp "$TEMPLATES_DIR/us-readme-template.md" "$US_DIR/README.md"

# Remplacer les placeholders dans le README (compatible macOS)
# Utiliser la fonction centralisée pour l'échappement
TITLE_ESCAPED=$(escape_for_sed "$TITLE")
KEY_ESCAPED=$(escape_for_sed "$KEY")
PROJECT_DIR_ESCAPED=$(escape_for_sed "$PROJECT_DIR")
LINK_ESCAPED=$(escape_for_sed "$LINK")

sed -i '' "s|\[US-XXX\]|$KEY_ESCAPED|g" "$US_DIR/README.md"
sed -i '' "s|\[Nom de la User Story\]|$TITLE_ESCAPED|g" "$US_DIR/README.md"
sed -i '' "s|\[NOM_PROJET\]|$PROJECT_DIR_ESCAPED|g" "$US_DIR/README.md"
sed -i '' "s|\[NUMBER\]|$TICKET_NUMBER|g" "$US_DIR/README.md"
sed -i '' "s|\[URL du ticket\]|$LINK_ESCAPED|g" "$US_DIR/README.md"
sed -i '' "s|\[AAAA-MM-JJ\]|$(date +"%Y-%m-%d")|g" "$US_DIR/README.md"

log_success "README.md créé"
echo ""

# Créer les 3 fichiers de documentation avec liens vers le fichier d'extraction
log_info "Création des fichiers de documentation..."
echo ""

# 1. Questions et Clarifications - Générer avec Cursor ou méthode classique
log_info "Génération des questions de clarifications..."
log_info "   Préparation du prompt pour l'agent Cursor..."
"$GENERATE_WITH_CURSOR_SCRIPT" "questions" "$US_DIR" || {
    log_warning "Erreur avec la préparation du prompt, basculement vers méthode classique..."
    "$GENERATE_QUESTIONS_SCRIPT" "$US_DIR" || {
        log_error "Erreur lors de la génération des questions"
        exit 1
    }
}
echo ""

# 2. Stratégie de Test - Générer avec Cursor ou méthode classique
log_info "Génération de la stratégie de test..."
log_info "   Préparation du prompt pour l'agent Cursor..."
"$GENERATE_WITH_CURSOR_SCRIPT" "strategy" "$US_DIR" || {
    log_warning "Erreur avec la préparation du prompt, basculement vers méthode classique..."
    "$GENERATE_STRATEGY_SCRIPT" "$US_DIR" || {
        log_error "Erreur lors de la génération de la stratégie"
        exit 1
    }
}
echo ""

# 3. Cas de Test - Générer avec Cursor ou méthode classique
log_info "Génération des cas de test..."
log_info "   Préparation du prompt pour l'agent Cursor..."
"$GENERATE_WITH_CURSOR_SCRIPT" "test-cases" "$US_DIR" || {
    log_warning "Erreur avec la préparation du prompt, basculement vers méthode classique..."
    "$GENERATE_TEST_CASES_SCRIPT" "$US_DIR" || {
        log_error "Erreur lors de la génération des cas de test"
        exit 1
    }
}
echo ""

# Mettre à jour le README avec les informations extraites
log_info "Mise à jour du README avec les informations extraites..."
"$UPDATE_README_SCRIPT" "$US_DIR" || {
    log_warning "Erreur lors de la mise à jour du README (non bloquant)"
}
echo ""

log_success "Tous les fichiers de documentation créés"
echo ""

# Enregistrer le traitement dans l'historique
if [ "$DRY_RUN" != "true" ]; then
    record_treatment "$KEY" "$US_DIR"
fi

log_success "Traitement terminé pour $KEY"
echo ""
echo "📁 Fichiers créés dans : $US_DIR"
echo "   - README.md (vue d'ensemble)"
echo "   - extraction-jira.md (informations extraites du XML - À COMPLÉTER)"
echo "   - 01-questions-clarifications.md (⭐ généré automatiquement avec ~30-40 questions pertinentes)"
echo "   - 02-strategie-test.md (⭐ généré automatiquement avec 8 axes de test détaillés)"
echo "   - 03-cas-test.md (template pré-rempli)"
echo ""
echo "🔗 Prochaines étapes :"
echo "   1. Relire et ajuster les questions de clarifications générées (si nécessaire)"
echo "   2. Relire et ajuster la stratégie de test générée (si nécessaire)"
echo "   3. Compléter extraction-jira.md avec toutes les informations du XML"
echo "   4. Relire et compléter les cas de test générés"
echo ""

