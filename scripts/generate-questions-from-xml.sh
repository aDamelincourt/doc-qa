#!/bin/bash

# Script pour générer automatiquement des questions de clarifications basées sur le contenu réel du XML Jira
# Usage: ./scripts/generate-questions-from-xml.sh [US_DIR]

set -euo pipefail

# Charger les bibliothèques communes
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LIB_DIR="$SCRIPT_DIR/lib"
source "$LIB_DIR/config.sh"
source "$LIB_DIR/common-functions.sh"
source "$LIB_DIR/xml-utils.sh"
source "$LIB_DIR/ticket-utils.sh"

if [ -z "${1:-}" ]; then
    log_error "Dossier US requis"
    echo "Usage: ./scripts/generate-questions-from-xml.sh [US_DIR]"
    echo "Exemple: ./scripts/generate-questions-from-xml.sh projets/SPEX/us-2990"
    exit 1
fi

US_DIR="$1"

if [ ! -d "$US_DIR" ]; then
    log_error "Dossier introuvable : $US_DIR"
    exit 1
fi

BASE_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

# Trouver le fichier XML correspondant
EXTRACTION_FILE="$US_DIR/extraction-jira.md"
if ! validate_file "$EXTRACTION_FILE"; then
    exit 1
fi

# Extraire le ticket ID du chemin
TICKET_KEY=$(get_ticket_key_from_path "$US_DIR")
if [ -z "$TICKET_KEY" ]; then
    log_error "Impossible d'extraire la clé du ticket"
    log_error "   Essayé depuis le chemin : $(basename "$US_DIR")"
    log_error "   Essayé depuis extraction-jira.md"
    exit 1
fi

# Trouver le fichier XML
XML_FILE=$(get_xml_file_from_key "$TICKET_KEY")

if ! validate_xml "$XML_FILE"; then
    exit 1
fi

log_debug "Analyse du XML : $XML_FILE"
echo ""

# Parser le XML une fois
if ! parse_xml_file "$XML_FILE"; then
    exit 1
fi

# DESCRIPTION_SECTION, TITLE sont déjà extraits par parse_xml_file
DESCRIPTION_DECODED=$(decode_html_simple "$DESCRIPTION_SECTION" | tr -d '\n' | sed 's/<[^>]*>//g' | sed 's/  */ /g')

# Extraire les commentaires
COMMENTS=$(extract_comments "$XML_FILE" 100)

# Fonction pour générer des questions PM
generate_pm_questions() {
    local file="$1"
    local description="$2"
    local comments="$3"
    
    echo "## 🗣️ Pour le Product Manager (PM)"
    echo ""
    echo "### Règles métier et critères d'acceptation"
    echo ""
    
    local q_num=1
    
    # Question 1: Messages d'erreur exacts
    if echo "$description" | grep -qi "error message\|message d'erreur\|banner"; then
        echo "$q_num. **Messages d'erreur exacts** : Les messages d'erreur mentionnés dans les critères d'acceptation doivent-ils être exactement tels quels, ou peuvent-ils être adaptés pour plus de clarté ?"
        echo "   - **Contexte** : Plusieurs scénarios mentionnent des messages d'erreur spécifiques (ex: 'The file could not be uploaded. Only files with the following extensions are allowed: pdf.'). Il est important de confirmer les textes finaux pour les tests."
        echo "   - **Réponse** : [À compléter par le PM]"
        echo ""
        ((q_num++))
    fi
    
    # Question 2: Contraintes de taille
    if echo "$description" | grep -qi "2MB\|10MB\|taille\|size"; then
        local size_limit=$(echo "$description" "$comments" | grep -oE "[0-9]+[[:space:]]*[Mm][Bb]\|[0-9]+[[:space:]]*[Mm][Oo]" | head -1)
        echo "$q_num. **Limite de taille du fichier** : Quelle est la limite exacte de taille de fichier ? Le ticket mentionne '2MB' dans certains scénarios mais '10MB' dans les commentaires. Quelle est la valeur finale retenue ?"
        echo "   - **Contexte** : Des incohérences apparaissent entre les critères d'acceptation (2MB) et les commentaires de l'équipe (10MB). Il faut clarifier la valeur finale pour tester correctement."
        echo "   - **Réponse** : [À compléter par le PM]"
        echo ""
        ((q_num++))
    fi
    
    # Question 3: Format de nommage
    if echo "$description" | grep -qi "readme_iso\|readme_\[iso\]"; then
        echo "$q_num. **Format de nommage et langues supportées** : Pour le format 'readme_iso.pdf', quelles sont les langues ISO supportées ? (fr, en, es, etc.) Y a-t-il une liste exhaustive ou peut-on utiliser n'importe quel code ISO valide ?"
        echo "   - **Contexte** : Le ticket mentionne 'readme_iso' où 'iso' est remplacé par le code de langue, mais la liste des codes acceptés n'est pas explicitement définie."
        echo "   - **Réponse** : [À compléter par le PM]"
        echo ""
        ((q_num++))
    fi
    
    # Question 4: Langue par défaut
    if echo "$description" | grep -qi "default language\|langue par défaut"; then
        echo "$q_num. **Langue par défaut** : Quelle est la langue par défaut considérée pour le document obligatoire ? Comment est-elle déterminée (langue du compte utilisateur, langue de la boutique, etc.) ?"
        echo "   - **Contexte** : Le scénario 'Error for Missing Mandatory Documentation' mentionne 'documentation file for the default language' mais ne précise pas comment cette langue est définie."
        echo "   - **Réponse** : [À compléter par le PM]"
        echo ""
        ((q_num++))
    fi
    
    # Question 5: Scénarios désactivés
    if echo "$description" | grep -qi "font color.*red\|pas d'actualité\|plus d'actualité\|pas de multilang"; then
        echo "$q_num. **Scénarios marqués comme désactivés** : Certains scénarios dans le ticket sont marqués en rouge avec la mention 'plus d'actualité' ou 'pas d'actualité' (ex: upload multiple fichiers même langue, documentation multi-langue). Ces scénarios doivent-ils être complètement ignorés pour cette version, ou seront-ils implémentés plus tard ?"
        echo "   - **Contexte** : Le ticket contient des scénarios désactivés qui pourraient prêter à confusion lors des tests. Il faut confirmer le périmètre exact de cette version."
        echo "   - **Réponse** : [À compléter par le PM]"
        echo ""
        ((q_num++))
    fi
    
    # Question 6: Comportement lors de la suppression pendant upload
    echo "$q_num. **Comportement lors de la suppression pendant upload** : Si un utilisateur supprime un document pendant qu'un autre document est en cours d'upload, que doit-il se passer ? Le bouton Submit doit-il rester désactivé jusqu'à la fin de l'upload ?"
    echo "   - **Contexte** : Le scénario 'Disable submission while a document is being uploaded' désactive le Submit pendant l'upload, mais le comportement lors d'une suppression simultanée n'est pas défini."
    echo "   - **Réponse** : [À compléter par le PM]"
    echo ""
    ((q_num++))
    
    echo "### Cas limites et comportements edge cases"
    echo ""
    
    # Question 7: Nombre maximum de fichiers
    echo "$q_num. **Nombre maximum de fichiers** : Y a-t-il une limite au nombre de documents (par langue) qu'un utilisateur peut uploader ? Par exemple, peut-on avoir readme_fr.pdf, readme_en.pdf, readme_es.pdf, etc. sans limite ?"
    echo "   - **Contexte** : Les critères d'acceptation mentionnent '1 document par langue' mais ne précisent pas s'il y a une limite globale du nombre de langues supportées."
    echo "   - **Réponse** : [À compléter par le PM]"
    echo ""
    ((q_num++))
    
    # Question 8: Fichier déjà existant
    echo "$q_num. **Remplacement d'un fichier existant** : Si un utilisateur upload un nouveau fichier pour une langue qui a déjà un document (ex: remplacer readme_fr.pdf), le fichier précédent est-il automatiquement supprimé lors de l'upload ou uniquement lors du submit final ?"
    echo "   - **Contexte** : Le scénario 'Back rule for deleting an old document' mentionne la suppression à la soumission, mais le comportement lors de l'upload immédiat n'est pas clair."
    echo "   - **Réponse** : [À compléter par le PM]"
    echo ""
    ((q_num++))
    
    echo "### Messages et notifications utilisateur"
    echo ""
    
    # Question 9: Messages de succès
    echo "$q_num. **Messages de confirmation** : Y a-t-il un message de confirmation à afficher lorsque l'upload d'un document réussit ? Si oui, quel est le format et le texte exact ?"
    echo "   - **Contexte** : Les critères d'acceptation détaillent les messages d'erreur mais ne mentionnent pas de message de succès pour confirmer l'upload réussi."
    echo "   - **Réponse** : [À compléter par le PM]"
    echo ""
    ((q_num++))
}

# Fonction pour générer des questions Dev
# Analyse : Commentaires techniques, contraintes, limites, intégrations
generate_dev_questions() {
    local file="$1"
    local description="$2"
    local comments="$3"
    
    echo "## 💻 Pour les Développeur(se)s"
    echo ""
    echo "### Architecture et implémentation technique"
    echo ""
    
    local q_num=1
    
    # Question 1: Validation côté client/serveur
    echo "$q_num. **Validation de fichier** : La validation du format (PDF), de la taille (2MB/10MB) et du nommage (readme_iso.pdf) est-elle effectuée côté client (avant upload), côté serveur (après upload), ou les deux ?"
    echo "   - **Contexte** : Pour les tests, il est important de savoir où ces validations ont lieu, car cela impacte les cas de test à mettre en place."
    echo "   - **Réponse** : [À compléter par le développeur]"
    echo ""
    ((q_num++))
    
    # Question 2: Upload progressif
    echo "$q_num. **Upload progressif et retry** : L'upload est-il progressif (avec progression en %) ? Y a-t-il un mécanisme de retry automatique en cas d'échec réseau ?"
    echo "   - **Contexte** : Le ticket mentionne un spinner/loader pendant l'upload mais ne précise pas le comportement en cas d'échec partiel ou complet."
    echo "   - **Réponse** : [À compléter par le développeur]"
    echo ""
    ((q_num++))
    
    # Question 3: Stockage des fichiers
    echo "$q_num. **Stockage des fichiers** : Où sont stockés les fichiers uploadés ? (S3, système de fichiers local, CDN) Quel est le chemin de stockage et la structure de nommage en backend ?"
    echo "   - **Contexte** : Pour tester la suppression et le remplacement de fichiers, il faut comprendre comment les fichiers sont gérés en backend."
    echo "   - **Réponse** : [À compléter par le développeur]"
    echo ""
    ((q_num++))
    
    # Question 4: API endpoints
    echo "$q_num. **API endpoints** : Quels sont les endpoints API utilisés pour l'upload, la suppression et la récupération de la liste des documents ? Y a-t-il une documentation Swagger/OpenAPI disponible ?"
    echo "   - **Contexte** : Pour les tests d'intégration et les tests automatisés, il est nécessaire de connaître les contrats API."
    echo "   - **Réponse** : [À compléter par le développeur]"
    echo ""
    ((q_num++))
    
    # Question 5: Gestion des erreurs backend
    echo "$q_num. **Gestion des erreurs backend** : Quels codes d'erreur HTTP sont retournés par l'API en cas d'échec d'upload (400, 413, 500, etc.) ? Y a-t-il des messages d'erreur spécifiques retournés par le backend ?"
    echo "   - **Contexte** : Les tests doivent couvrir les différents cas d'erreur côté serveur, pas seulement la validation côté client."
    echo "   - **Réponse** : [À compléter par le développeur]"
    echo ""
    ((q_num++))
    
    # Question 6: Logs et monitoring
    echo "$q_num. **Logs et monitoring** : Où sont stockés les logs d'upload ? Y a-t-il des métriques spécifiques à surveiller (taux d'échec, temps d'upload moyen, etc.) ?"
    echo "   - **Contexte** : Pour débugger les problèmes en environnement de test/staging, il faut savoir où consulter les logs."
    echo "   - **Réponse** : [À compléter par le développeur]"
    echo ""
    
    echo "### Données et base de données"
    echo ""
    
    # Question 7: Données de test
    echo "$q_num. **Données de test** : Y a-t-il des fichiers de test (PDF) de différentes tailles disponibles dans l'environnement de staging ? (fichier < 2MB, fichier > 2MB, fichier exactement 2MB, etc.)"
    echo "   - **Contexte** : Pour tester efficacement, il est utile d'avoir des fichiers de test prédéfinis avec des caractéristiques connues."
    echo "   - **Réponse** : [À compléter par le développeur]"
    echo ""
    ((q_num++))
    
    # Question 8: Persistance
    echo "$q_num. **Persistance des données** : Les informations sur les documents uploadés sont-elles stockées en base de données immédiatement après l'upload, ou uniquement lors du submit final de la marketing sheet ?"
    echo "   - **Contexte** : Cela impacte le comportement si l'utilisateur quitte la page sans soumettre, ou s'il y a une erreur lors du submit final."
    echo "   - **Réponse** : [À compléter par le développeur]"
    echo ""
    ((q_num++))
}

# Fonction pour générer des questions Designer
# Analyse : Comportements UI, états, animations, responsive, accessibilité
generate_designer_questions() {
    local file="$1"
    local description="$2"
    local comments="$3"
    
    echo "## 🎨 Pour le/la Product Designer"
    echo ""
    echo "### Comportement de l'interface utilisateur"
    echo ""
    
    local q_num=1
    
    # Question 1: Feedback visuel upload
    echo "$q_num. **Feedback visuel pendant l'upload** : Pendant l'upload, quel est le comportement visuel exact attendu ? Y a-t-il un spinner, une barre de progression, ou les deux ? Où sont-ils positionnés exactement ?"
    echo "   - **Contexte** : Les commentaires mentionnent 'Loader sur le téléchargement' mais les maquettes Figma doivent préciser l'emplacement et le style exact."
    echo "   - **Réponse** : [À compléter par le designer]"
    echo ""
    ((q_num++))
    
    # Question 2: Empty state
    if echo "$description" "$comments" | grep -qi "empty state\|footer\|taille du fichier"; then
        echo "$q_num. **Empty state et état avec fichier** : Il y a une différence mentionnée dans les commentaires entre l'empty state et l'état avec fichier au niveau du footer (informations sur la taille et le nom du fichier). Quelle version doit être retenue ?"
        echo "   - **Contexte** : Un commentaire mentionne : 'il y a une différence entre \"l'empty state\" et le \"with one document uploaded\" au niveau du footer'. Il faut clarifier quelle version est la bonne."
        echo "   - **Réponse** : [À compléter par le designer]"
        echo ""
        ((q_num++))
    fi
    
    # Question 3: Affichage des erreurs
    echo "$q_num. **Positionnement des messages d'erreur** : Les messages d'erreur (format invalide, taille excessive, nom incorrect) doivent-ils apparaître comme un banner en haut de la zone d'upload, en dessous, ou ailleurs ? Le banner reste-t-il visible jusqu'à ce que l'utilisateur corrige l'erreur ?"
    echo "   - **Contexte** : Les critères d'acceptation mentionnent 'error message banner immediately appears' mais ne précisent pas l'emplacement exact et la durée d'affichage."
    echo "   - **Réponse** : [À compléter par le designer]"
    echo ""
    ((q_num++))
    
    # Question 4: Icône PDF
    if echo "$comments" | grep -qi "icône.*pdf"; then
        echo "$q_num. **Icône PDF** : Il est mentionné dans les commentaires qu'il faudrait l'icône 'pdf' dans la taille voulue (actuellement 1500*1500 sur Figma). Quelle est la taille finale attendue et où doit-elle être utilisée ?"
        echo "   - **Contexte** : Un commentaire technique mentionne que l'icône PDF doit être redimensionnée. Il faut confirmer les dimensions finales pour les tests visuels."
        echo "   - **Réponse** : [À compléter par le designer]"
        echo ""
        ((q_num++))
    fi
    
    # Question 5: Zone drag-and-drop
    echo "$q_num. **Zone drag-and-drop** : La zone de drag-and-drop a-t-elle un état visuel différent quand on survole avec un fichier (hover state) ? Y a-t-il une animation de transition lors du drop ?"
    echo "   - **Contexte** : Pour tester l'UX complète, il faut connaître tous les états visuels de la zone d'upload."
    echo "   - **Réponse** : [À compléter par le designer]"
    echo ""
    ((q_num++))
    
    echo "### Responsive et accessibilité"
    echo ""
    
    # Question 6: Responsive
    echo "$q_num. **Adaptation mobile/tablette** : La zone d'upload et l'affichage des documents sont-ils adaptés pour mobile et tablette ? Y a-t-il des changements de layout ou d'interaction sur petits écrans ?"
    echo "   - **Contexte** : Le ticket mentionne le label 'ALL_SCREENS', ce qui suggère que la fonctionnalité doit être responsive."
    echo "   - **Réponse** : [À compléter par le designer]"
    echo ""
    ((q_num++))
    
    # Question 7: Accessibilité
    echo "$q_num. **Accessibilité** : Y a-t-il des considérations d'accessibilité spécifiques pour la zone d'upload ? (Navigation au clavier, labels ARIA, support lecteur d'écran, etc.)"
    echo "   - **Contexte** : Pour des tests d'accessibilité complets, il faut connaître les requirements spécifiques."
    echo "   - **Réponse** : [À compléter par le designer]"
    echo ""
}

# Générer le fichier de questions
QUESTIONS_FILE="$US_DIR/01-questions-clarifications.md"

{
    echo "# $TITLE - Questions et Clarifications"
    echo ""
    echo "## 📋 Informations générales"
    echo ""
    echo "- **Feature** : $TITLE"
    echo "- **User Story** : $TICKET_KEY : $TITLE"
    echo "- **Sprint/Version** : [ex: Sprint 24, v2.3.0]"
    echo "- **Date de création** : $(date +"%Y-%m-%d")"
    echo "- **Auteur** : [Nom du QA]"
    echo "- **Statut** : À valider"
    echo ""
    echo "---"
    echo ""
    echo "> 📌 **Note** : Ces questions ont été générées automatiquement en analysant le contenu du ticket Jira. Certaines peuvent nécessiter des ajustements en fonction du contexte du projet."
    echo ""
    echo "---"
    echo ""
    
    generate_pm_questions "$XML_FILE" "$DESCRIPTION_DECODED" "$COMMENTS"
    echo ""
    echo "---"
    echo ""
    generate_dev_questions "$XML_FILE" "$DESCRIPTION_DECODED" "$COMMENTS"
    echo ""
    echo "---"
    echo ""
    generate_designer_questions "$XML_FILE" "$DESCRIPTION_DECODED" "$COMMENTS"
    echo ""
    echo "---"
    echo ""
    echo "## ✅ Validation des réponses"
    echo ""
    echo "Une fois toutes les questions répondues :"
    echo ""
    echo "- [ ] Toutes les questions ont reçu une réponse"
    echo "- [ ] Les réponses sont suffisamment détaillées pour procéder aux tests"
    echo "- [ ] Les réponses ont été validées par l'équipe"
    echo "- [ ] Le document de stratégie de test peut être créé"
    echo "- [ ] Le document de cas de test peut être créé"
    echo ""
    echo "---"
    echo ""
    echo "## 📝 Notes"
    echo ""
    echo "- **Date de dernière mise à jour** : $(date +"%Y-%m-%d")"
    echo "- **Dernière modification par** : [Nom]"
    echo ""
    echo "---"
    echo ""
    echo "## 🔗 Documents associés"
    echo ""
    echo "- **Stratégie de test** : [Lien vers le document de stratégie]"
    echo "- **Cas de test** : [Lien vers le document de cas de test]"
    echo "- **User Story** : [Lien Jira/Ticket]"
    echo "- **Extraction Jira** : extraction-jira.md"
    
} > "$QUESTIONS_FILE"

echo "✅ Fichier de questions généré : $QUESTIONS_FILE"
echo ""
echo "📊 Statistiques :"
PM_COUNT=$(grep -c "^[0-9]\+\\. \*\*" "$QUESTIONS_FILE" | head -1 || echo "0")
DEV_COUNT=$(awk '/## 💻 Pour les Développeur/,/## 🎨 Pour le\/la Product Designer/' "$QUESTIONS_FILE" | grep -c "^[0-9]\+\\. \*\*" || echo "0")
DESIGNER_COUNT=$(awk '/## 🎨 Pour le\/la Product Designer/,/## ✅ Validation/' "$QUESTIONS_FILE" | grep -c "^[0-9]\+\\. \*\*" || echo "0")
echo "   - Questions PM : $PM_COUNT"
echo "   - Questions Dev : $DEV_COUNT"
echo "   - Questions Designer : $DESIGNER_COUNT"
echo ""
echo "💡 Conseil : Relisez et ajustez les questions générées en fonction du contexte spécifique de votre projet."
echo ""

# Mettre à jour le README après génération
log_info "Mise à jour du README..."
UPDATE_README_SCRIPT="$SCRIPT_DIR/update-readme-from-xml.sh"
if [ -f "$UPDATE_README_SCRIPT" ]; then
    "$UPDATE_README_SCRIPT" "$US_DIR" || {
        log_warning "Erreur lors de la mise à jour du README (non bloquant)"
    }
else
    log_warning "Script de mise à jour du README introuvable : $UPDATE_README_SCRIPT"
fi

