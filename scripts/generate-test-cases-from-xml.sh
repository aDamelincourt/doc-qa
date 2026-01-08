#!/bin/bash

# Script pour générer automatiquement des cas de test complets basés sur le contenu réel du XML Jira
# Usage: ./scripts/generate-test-cases-from-xml.sh [US_DIR]

set -euo pipefail

# Charger les bibliothèques communes
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LIB_DIR="$SCRIPT_DIR/lib"
source "$LIB_DIR/config.sh"
source "$LIB_DIR/common-functions.sh"
source "$LIB_DIR/xml-utils.sh"
source "$LIB_DIR/ticket-utils.sh"
source "$LIB_DIR/acceptance-criteria-utils.sh"

# Initialiser le compteur de scénarios
if [ -z "${SCENARIO_NUM:-}" ]; then
    SCENARIO_NUM=1
fi

# Gestion des erreurs avec trap
cleanup_on_error() {
    log_error "Erreur lors de la génération des cas de test. Nettoyage..."
    exit 1
}
trap cleanup_on_error ERR

if [ -z "${1:-}" ]; then
    log_error "Dossier US requis"
    echo "Usage: ./scripts/generate-test-cases-from-xml.sh [US_DIR]"
    echo "Exemple: ./scripts/generate-test-cases-from-xml.sh projets/SPEX/us-2990"
    exit 1
fi

US_DIR="$1"

# Valider le répertoire US
if ! validate_directory "$US_DIR"; then
    exit 1
fi

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

# DESCRIPTION_SECTION est déjà extrait par parse_xml_file
# Optimisation #3 : Utiliser decode_html_cached pour éviter de décoder plusieurs fois
DESCRIPTION_DECODED=$(decode_html_cached "$DESCRIPTION_SECTION" 2>/dev/null || echo "$DESCRIPTION_SECTION")

# Extraire les commentaires pour les détails techniques (optimisation : utiliser extract_comments)
COMMENTS_SECTION=$(extract_comments "$XML_FILE" 200) || COMMENTS_SECTION=""
COMMENTS_DECODED=$(decode_html_cached "$COMMENTS_SECTION" 2>/dev/null || echo "$COMMENTS_SECTION")

# Extraire la limite de taille (chercher dans les commentaires et la description)
# Note: Désactiver temporairement set -e pour éviter l'échec si grep ne trouve rien
set +e
FILE_SIZE_LIMIT=$(echo "$DESCRIPTION_DECODED $COMMENTS_DECODED" | grep -oE "[0-9]+[[:space:]]*[Mm][Bb]|[0-9]+[[:space:]]*[Mm][Oo]" | head -1 | sed 's/[^0-9]//g' || echo "")
set -e
if [ -z "$FILE_SIZE_LIMIT" ]; then
    FILE_SIZE_LIMIT="10"
fi

# ============================================================================
# GÉNÉRATION DES CAS DE TEST
# ============================================================================
# Les cas de test sont générés en analysant :
# - Les scénarios Given/When/Then du XML
# - Les critères d'acceptation
# - Les messages d'erreur mentionnés
# - Les contraintes (taille, format, nommage)
# - Le type de fonctionnalité (Benefits vs File Upload)

# Créer le fichier de cas de test
OUTPUT_FILE="$US_DIR/03-cas-test.md"

# Compteur de scénarios (initialiser si pas déjà défini)
if [ -z "${SCENARIO_NUM:-}" ]; then
    SCENARIO_NUM=1
fi

# Fonction pour générer un cas de test
# Convertit les clauses Given/When/Then en étapes numérotées avec données et résultats
generate_test_case() {
    local scenario_title="${1:-Scénario}"
    local given="${2:-}"
    local when="${3:-}"
    local then_clause="${4:-}"
    local test_data="${5:-Données de test à compléter}"
    local expected_result="${6:-✅ Le scénario fonctionne correctement}"
    
    echo ""
    echo "### Scénario $SCENARIO_NUM : $scenario_title"
    echo ""
    echo "**Objectif** : Vérifier que $scenario_title"
    echo ""
    echo "**Étapes** :"
    echo ""
    
    # Convertir Given/When/Then en étapes numérotées
    local step_num=1
    if [ -n "$given" ]; then
        local given_clean=$(echo "$given" | sed 's/^Given[[:space:]]*//i; s/^I am[[:space:]]*/Je suis /i; s/^I have[[:space:]]*/J'\''ai /i')
        echo "$step_num. $given_clean"
        ((step_num++))
    fi
    if [ -n "$when" ]; then
        local when_clean=$(echo "$when" | sed 's/^When[[:space:]]*//i; s/^I[[:space:]]*/Je /i')
        echo "$step_num. $when_clean"
        ((step_num++))
    fi
    
    echo ""
    echo "**Données de test** :"
    echo ""
    echo "\`\`\`"
    echo "$test_data"
    echo "\`\`\`"
    echo ""
    echo "**Résultat attendu** :"
    echo ""
    echo "$expected_result"
    echo ""
    echo "**Résultat obtenu** : [À compléter lors du test]"
    echo ""
    echo "**Statut** : [ ] Passé / [ ] Échoué / [ ] Bloqué"
    echo ""
    echo "---"
    
    ((SCENARIO_NUM++))
}

# ============================================================================
# GÉNÉRATION DU CONTENU DU FICHIER
# ============================================================================

# Générer le fichier de cas de test
# Note: Désactiver temporairement set -e dans le bloc pour éviter les erreurs silencieuses
set +e
{
    echo "# $TITLE - Cas de Test"
    echo ""
    echo "## 📋 Informations générales"
    echo ""
    echo "- **Feature** : $TITLE"
    echo "- **User Story** : $TICKET_KEY : $TITLE"
    echo "- **Sprint/Version** : [ex: Sprint 24, v2.3.0]"
    echo "- **Date de création** : $(date +"%Y-%m-%d")"
    echo "- **Auteur** : [Nom du QA]"
    echo "- **Statut** : Draft"
    echo "- **Lien Jira/Ticket** : $LINK"
    echo ""
    echo "---"
    echo ""
    echo "## 🔗 Documents associés"
    echo ""
    echo "- **Stratégie de test** : [02-strategie-test.md]"
    echo "- **Questions et Clarifications** : [01-questions-clarifications.md]"
    echo ""
    echo "---"
    echo ""
    echo "## 🧪 Scénarios de test"
    echo ""
    
    # ========== CAS NOMINAUX ==========
    echo "### 📌 CAS NOMINAUX"
    echo ""
    
    # Extraire les critères d'acceptation du XML
    ACCEPTANCE_CRITERIA=$(extract_acceptance_criteria "$XML_FILE")
    
    # Détecter le type de fonctionnalité : Benefits, Upload, ou Autre
    # Cette détection permet de générer des cas de test spécifiques à chaque type
    IS_BENEFITS_FEATURE=false
    IS_UPLOAD_FEATURE=false
    
    if echo "$DESCRIPTION_DECODED" | grep -qi "benefit\|benefits\|checkbox.*benefit\|Conversion rate\|Would you mention some benefits"; then
        IS_BENEFITS_FEATURE=true
    elif echo "$DESCRIPTION_DECODED" | grep -qiE "upload.*documentation|documentation.*upload|drag.*drop.*file|readme.*pdf|upload.*readme|file.*upload.*documentation"; then
        # Détection plus précise pour éviter les faux positifs (ex: "documentation technique" seule)
        IS_UPLOAD_FEATURE=true
    fi
    
    # Si des critères d'acceptation sont trouvés, les convertir en scénarios de test
    # Utiliser un fichier temporaire pour éviter les problèmes de sous-shell
    if [ -n "$ACCEPTANCE_CRITERIA" ]; then
        temp_ac_file=$(mktemp)
        echo "$ACCEPTANCE_CRITERIA" > "$temp_ac_file"
        
        while IFS='|' read -r ac_num title given when then_clause <&3; do
            if [ -n "$ac_num" ] && [ -n "$title" ]; then
                # Convertir l'AC en scénario
                scenario_data=$(ac_to_test_scenario "$ac_num" "$title" "$given" "$when" "$then_clause")
                IFS='|' read -r scenario_title scenario_given scenario_when scenario_then scenario_test_data scenario_expected <<< "$scenario_data"
                
                generate_test_case \
                    "$scenario_title" \
                    "${scenario_given:-Se connecter et accéder à la fonctionnalité}" \
                    "${scenario_when:-Effectuer l'action décrite}" \
                    "${scenario_then:-Vérifier le résultat attendu}" \
                    "${scenario_test_data:-Données de test à compléter}" \
                    "${scenario_expected:-✅ Le critère d'acceptation est respecté}"
            fi
        done 3< "$temp_ac_file"
        
        rm -f "$temp_ac_file"
    fi
    
    # ========== FONCTIONNALITÉ BENEFITS ==========
    # Générer des scénarios spécifiques Benefits uniquement si c'est vraiment une fonctionnalité Benefits
    if [ "$IS_BENEFITS_FEATURE" = true ]; then
        # Scénario 1: Input display selon le type de produit
        if echo "$DESCRIPTION_DECODED" | grep -qi "Input display\|What benefits can your clients gain"; then
            generate_test_case \
                "Affichage de la section bénéfices selon le type de produit" \
                "Se connecter en tant que vendeur" \
                "Naviguer vers la page marketing sheet et accéder à la catégorie 'What will users do with your product?'" \
                "Vérifier que la section 'What benefits can your clients gain from your module/pack?' est visible uniquement pour les produits de type Module ou Pack, et non visible pour Theme ou Email" \
                "Type de produit: Module / Pack / Theme / Email
Section: 'What will users do with your product?'" \
                "- ✅ Pour un produit Module : La section bénéfices est visible avec le titre 'What benefits can your clients gain from your module?'
- ✅ Pour un produit Pack : La section bénéfices est visible avec le titre 'What benefits can your clients gain from your pack?'
- ✅ Pour un produit Theme : La section bénéfices n'est PAS visible
- ✅ Pour un produit Email : La section bénéfices n'est PAS visible"
        fi
        
        # Scénario 2: Sélection d'un bénéfice quand la limite est 1
        if echo "$DESCRIPTION_DECODED" | grep -qi "Selecting a benefit when the limit is 1\|benefit limit is 1"; then
            generate_test_case \
                "Sélection d'un bénéfice quand la limite est 1" \
                "Créer un nouveau produit avec une limite de bénéfices de 1" \
                "Cliquer sur une checkbox sous 'Would you mention some benefits for customers?' (par exemple 'Conversion rate')" \
                "Le bénéfice 'Conversion rate' est marqué comme sélectionné et toutes les autres checkboxes de bénéfices non sélectionnées sont désactivées" \
                "Produit: Nouveau produit
Limite de bénéfices: 1
Bénéfice sélectionné: Conversion rate" \
                "- ✅ La checkbox 'Conversion rate' est cochée
- ✅ Toutes les autres checkboxes de bénéfices sont désactivées (grisées, non cliquables)
- ✅ Le message informatif sur la limite est affiché correctement"
        fi
        
        # Scénario 3: Désélection d'un bénéfice quand la limite est 1
        if echo "$DESCRIPTION_DECODED" | grep -qi "Deselecting a benefit when the limit is 1"; then
            generate_test_case \
                "Désélection d'un bénéfice quand la limite est 1" \
                "Avoir un produit avec 'Conversion rate' actuellement sélectionné (limite de 1)" \
                "Cliquer à nouveau sur la checkbox 'Conversion rate'" \
                "Le bénéfice 'Conversion rate' est désélectionné et toutes les autres checkboxes redeviennent actives et disponibles pour sélection" \
                "Produit: Produit existant
Limite de bénéfices: 1
Bénéfice actuellement sélectionné: Conversion rate
Action: Désélection de 'Conversion rate'" \
                "- ✅ La checkbox 'Conversion rate' est décochée
- ✅ Toutes les autres checkboxes de bénéfices redeviennent actives (cliquables)
- ✅ L'utilisateur peut maintenant sélectionner un autre bénéfice"
        fi
        
        # Scénario 4: Gestion des bénéfices après augmentation de la limite
        if echo "$DESCRIPTION_DECODED" | grep -qi "Managing benefits after the limit has been increased\|benefit limit.*permanently increased"; then
            generate_test_case \
                "Gestion des bénéfices après augmentation permanente de la limite par un admin" \
                "Avoir un produit existant avec 1 bénéfice sélectionné ('Conversion rate'), puis un admin PrestaShop augmente la limite à 3 bénéfices depuis le back-office" \
                "Retourner sur la page d'édition du produit et vérifier l'affichage, puis sélectionner un 4ème bénéfice" \
                "Les 3 bénéfices précédemment ajoutés par l'admin sont visibles et sélectionnés, et on peut gérer les bénéfices jusqu'à la nouvelle limite" \
                "Produit: Produit existant
Bénéfices initiaux: Conversion rate (1)
Action admin: Ajout de 2 bénéfices (SEO optimized, Customer loyalty)
Nouvelle limite: 3 bénéfices" \
                "- ✅ Les 3 bénéfices ('Conversion rate', 'SEO optimized', 'Customer loyalty') sont tous sélectionnés
- ✅ La règle de sélection est mise à jour pour permettre un maximum de 3 sélections
- ✅ L'utilisateur peut désélectionner n'importe quel bénéfice et en sélectionner d'autres, tant que le total ne dépasse pas 3
- ✅ Si on tente de sélectionner un 4ème bénéfice, les autres checkboxes non sélectionnées se désactivent"
        fi
        
        # ========== CAS D'ERREUR pour Benefits ==========
        echo ""
        echo "### ❌ CAS D'ERREUR"
        echo ""
        
        # Scénario 5: Soumission sans sélectionner de bénéfice
        if echo "$DESCRIPTION_DECODED" | grep -qi "Submitting Without Selecting benefit\|You must select at least one benefit"; then
            ERROR_MSG=$(echo "$DESCRIPTION_DECODED" | grep -i "You must select at least one benefit" | sed 's/.*"\([^"]*\)".*/\1/' | head -1)
            if [ -z "$ERROR_MSG" ]; then
                ERROR_MSG="You must select at least one benefit to sell your product on the marketplace."
            fi
            
            generate_test_case \
                "Tentative de soumission sans sélectionner de bénéfice" \
                "Se connecter en tant que vendeur et accéder à la page marketing sheet" \
                "Ne pas choisir de bénéfice et cliquer sur 'submit'" \
                "L'utilisateur est redirigé vers le haut de la page, un banner d'erreur apparaît avec le message '$ERROR_MSG', et un banner apparaît au-dessus du champ bénéfices" \
                "Produit: Module ou Pack
Action: Soumission sans sélectionner de bénéfice" \
                "- ✅ L'utilisateur est redirigé vers le haut de la page
- ✅ Un banner d'erreur apparaît avec le texte 'Oops, it seems there is a mistake! Please correct the error highlighted below to submit your product sheet.'
- ✅ Un banner apparaît au-dessus du champ bénéfices avec le message exact: '$ERROR_MSG'
- ✅ Le formulaire n'est pas soumis"
        fi
        
        # ========== CAS DE PERFORMANCE pour Benefits ==========
        echo ""
        echo "### ⚡ CAS DE PERFORMANCE"
        echo ""
        
        # Scénario: Performance avec un grand nombre de bénéfices
        generate_test_case \
            "Performance avec un grand nombre de bénéfices disponibles" \
            "Se connecter en tant que vendeur et accéder à la section 'What benefits can your clients gain from your module/pack?'" \
            "Vérifier le temps de chargement et la réactivité de l'interface lorsque la liste contient 50+ bénéfices disponibles" \
            "L'interface reste réactive et le temps de chargement est acceptable (< 2 secondes)" \
            "Nombre de bénéfices: 50+
Type de produit: Module ou Pack
Résolution: 1920x1080" \
            "- ✅ Le temps de chargement de la liste des bénéfices est acceptable (< 2 secondes)
- ✅ L'interface reste réactive lors du scroll dans la liste
- ✅ La sélection/désélection de bénéfices est instantanée
- ✅ Aucun freeze ou lag perceptible
- ✅ La désactivation automatique des autres checkboxes fonctionne rapidement même avec 50+ bénéfices"
        
        # Scénario: Réactivité lors de sélection/désélection rapide
        generate_test_case \
            "Réactivité lors de sélection/désélection rapide de bénéfices" \
            "Avoir accès à la section bénéfices avec plusieurs bénéfices disponibles" \
            "Sélectionner et désélectionner rapidement plusieurs bénéfices (5-10 clics en moins de 2 secondes)" \
            "L'interface reste réactive et toutes les actions sont correctement enregistrées" \
            "Action: Sélection/désélection rapide de 5-10 bénéfices
Temps: < 2 secondes" \
            "- ✅ Aucun lag ou freeze lors des clics rapides
- ✅ Toutes les sélections/désélections sont correctement enregistrées
- ✅ L'état des checkboxes est cohérent avec les actions effectuées
- ✅ La limite de bénéfices est correctement appliquée même lors d'actions rapides"
    fi
    
    # ========== FONCTIONNALITÉ UPLOAD DE FICHIERS ==========
    # Générer des scénarios spécifiques Upload uniquement si c'est vraiment une fonctionnalité Upload
    if [ "$IS_UPLOAD_FEATURE" = true ]; then
        # Scénario 1: Upload Interface Display
        if echo "$DESCRIPTION_DECODED" | grep -qi "Upload Interface Display\|drag-and-drop area"; then
            generate_test_case \
                "Affichage de l'interface d'upload" \
                "Se connecter en tant que vendeur avec un produit de type Module ou Theme" \
                "Naviguer vers la page marketing sheet, accéder à la section 'How to install your product?' puis scroller jusqu'à la section 'Share your product documentation'" \
                "Vérifier que la zone de drag-and-drop pour les fichiers de documentation est visible, accompagnée d'un message informatif sur la convention de nommage readme_iso.pdf" \
                "Type de produit: Module ou Theme
Section: 'Share your product documentation'
Résolution: 1920x1080" \
                "- ✅ La zone de drag-and-drop est visible et fonctionnelle
- ✅ Le message informatif sur la convention de nommage readme_iso.pdf est affiché correctement
- ✅ L'interface est responsive et s'adapte à différentes tailles d'écran"
        fi
    
    # Scénario 2: Upload via Drag and Drop
    if echo "$DESCRIPTION_DECODED" | grep -qi "Upload via Drag and Drop\|drag and drop a valid PDF"; then
        generate_test_case \
            "Upload d'un fichier PDF valide via drag-and-drop" \
            "Se connecter en tant que vendeur et accéder à la section 'Share your product documentation'" \
            "Glisser-déposer un fichier PDF valide dans la zone d'upload OU cliquer sur la zone pour sélectionner le fichier" \
            "Le fichier apparaît dans la zone d'upload, affichant son nom et une icône de suppression X, et il n'est pas possible d'uploader un autre fichier pour la même langue" \
            "Fichier: readme_fr.pdf
Taille: 1.5MB
Format: PDF
Nommage: readme_fr.pdf conforme" \
            "- ✅ Le fichier apparaît immédiatement dans la zone d'upload après le drag-and-drop
- ✅ Le nom du fichier readme_fr.pdf est affiché correctement
- ✅ L'icône de suppression X est visible à côté du nom du fichier
- ✅ Il n'est pas possible d'uploader un deuxième fichier pour la langue fr
- ✅ Le fichier est correctement uploadé et sauvegardé"
    fi
    
    # Scénario 3: Upload via Click
    if echo "$DESCRIPTION_DECODED" | grep -qi "click the area to select"; then
        generate_test_case \
            "Upload d'un fichier PDF valide via clic" \
            "Se connecter en tant que vendeur et accéder à la section 'Share your product documentation'" \
            "Cliquer sur la zone d'upload et sélectionner un fichier PDF valide depuis l'explorateur de fichiers" \
            "Le fichier apparaît dans la zone d'upload, affichant son nom et une icône de suppression X" \
            "Fichier: readme_en.pdf
Taille: 2MB
Format: PDF
Nommage: readme_en.pdf conforme" \
            "- ✅ Le sélecteur de fichier s'ouvre correctement au clic
- ✅ Le fichier sélectionné apparaît dans la zone d'upload
- ✅ Le nom du fichier readme_*.pdf est affiché correctement
- ✅ L'icône de suppression X est visible"
    fi
    
    # Scénario 4: Delete an Uploaded File
    if echo "$DESCRIPTION_DECODED" | grep -qi "Delete an Uploaded File\|click the.*X.*icon"; then
        generate_test_case \
            "Suppression d'un fichier uploadé" \
            "Avoir uploadé avec succès un fichier de documentation readme_*.pdf" \
            "Cliquer sur l'icône 'X' à côté du nom du fichier" \
            "Le fichier est retiré de l'interface et la zone d'upload redevient disponible" \
            "Fichier uploadé: readme_fr.pdf
Action: Clic sur l'icône 'X'" \
            "- ✅ Le fichier est immédiatement retiré de l'interface
- ✅ La zone d'upload redevient vide et disponible pour un nouvel upload
- ✅ Aucune trace du fichier ne reste dans l'interface
- ✅ Le fichier est supprimé du serveur (vérification backend)"
        fi
    fi
    
    # ========== CAS LIMITES (uniquement pour Upload) ==========
    if [ "$IS_UPLOAD_FEATURE" = true ]; then
        echo ""
        echo "### 🔢 CAS LIMITES"
        echo ""
        
        # Scénario 5: Valeur limite - Taille maximale
        if echo "$DESCRIPTION_DECODED" | grep -qi "Oversized File\|larger than.*MB"; then
            generate_test_case \
                "Upload d'un fichier à la limite de taille maximale" \
                "Se connecter en tant que vendeur et accéder à la section 'Share your product documentation'" \
                "Uploader un fichier PDF valide readme_*.pdf d'exactement ${FILE_SIZE_LIMIT}MB" \
                "Le fichier est accepté et uploadé avec succès" \
                "Fichier: readme_fr.pdf
Taille: ${FILE_SIZE_LIMIT}MB limite exacte
Format: PDF
Nommage: readme_fr.pdf conforme" \
                "- ✅ Le fichier de ${FILE_SIZE_LIMIT}MB est accepté
- ✅ L'upload se termine avec succès
- ✅ Le fichier apparaît dans la zone d'upload avec son nom et l'icône 'X'"
        fi
        
        # Scénario 6: Valeur limite - Taille minimale
        generate_test_case \
            "Upload d'un fichier très petit" \
            "Se connecter en tant que vendeur et accéder à la section 'Share your product documentation'" \
            "Uploader un fichier PDF valide (readme_fr.pdf) de très petite taille (< 1KB)" \
            "Le fichier est accepté et uploadé avec succès" \
            "Fichier: readme_fr.pdf
Taille: 0.5KB
Format: PDF
Nommage: readme_fr.pdf (conforme)" \
            "- ✅ Le fichier très petit est accepté
- ✅ L'upload se termine avec succès
- ✅ Le fichier apparaît dans la zone d'upload"
        
        # Scénario 7: Upload de fichiers pour différentes langues
        if echo "$DESCRIPTION_DECODED" | grep -qi "readme_fr\|readme_en\|readme_es\|language"; then
            generate_test_case \
                "Upload de fichiers pour différentes langues" \
                "Se connecter en tant que vendeur et accéder à la section 'Share your product documentation'" \
                "Uploader successivement readme_fr.pdf, puis readme_en.pdf, puis readme_es.pdf" \
                "Tous les fichiers sont acceptés et affichés correctement, chaque fichier correspondant à sa langue" \
                "Fichier 1: readme_fr.pdf (français)
Fichier 2: readme_en.pdf (anglais)
Fichier 3: readme_es.pdf (espagnol)
Taille: 1MB chacun
Format: PDF" \
                "- ✅ Chaque fichier est accepté pour sa langue respective
- ✅ Tous les fichiers sont affichés dans l'interface
- ✅ Chaque fichier peut être supprimé indépendamment
- ✅ La convention de nommage readme_iso.pdf est respectée pour chaque langue"
        fi
    fi
    
    # CAS D'ERREUR (uniquement pour Upload)
    if [ "$IS_UPLOAD_FEATURE" = true ]; then
        echo ""
        echo "### ❌ CAS D'ERREUR"
        echo ""
        
        # Scénario 8: Fichier non-PDF
        if echo "$DESCRIPTION_DECODED" | grep -qi "Invalid File Format\|non-PDF file\|Only files with the following extensions"; then
            ERROR_MSG=$(echo "$DESCRIPTION_DECODED" | grep -i "Only files with the following extensions are allowed" | sed 's/.*"\([^"]*\)".*/\1/' | head -1)
            if [ -z "$ERROR_MSG" ]; then
                ERROR_MSG="The file could not be uploaded. Only files with the following extensions are allowed: pdf."
            fi
            
            generate_test_case \
            "Tentative d'upload d'un fichier non-PDF" \
            "Se connecter en tant que vendeur et accéder à la section 'Share your product documentation'" \
            "Sélectionner ou glisser-déposer un fichier non-PDF (ex: .docx, .txt, .jpg)" \
            "Un message d'erreur banner apparaît immédiatement avec le texte '$ERROR_MSG', et l'upload est rejeté" \
            "Fichier: document.docx
Format: DOCX (non-PDF)
Taille: 1MB" \
            "- ✅ Le message d'erreur banner apparaît immédiatement sans attendre la fin de l'upload
- ✅ Le message d'erreur exact est: '$ERROR_MSG'
- ✅ L'upload est rejeté et le fichier n'apparaît pas dans la zone
- ✅ La zone d'upload reste disponible pour un nouvel essai"
        fi
        
        # Scénario 9: Fichier trop volumineux
        if echo "$DESCRIPTION_DECODED" | grep -qi "Oversized File\|larger than.*MB\|File size must not exceed"; then
            ERROR_MSG=$(echo "$DESCRIPTION_DECODED" | grep -i "File size must not exceed" | sed 's/.*"\([^"]*\)".*/\1/' | head -1)
            if [ -z "$ERROR_MSG" ]; then
                ERROR_MSG="The file could not be uploaded. File size must not exceed ${FILE_SIZE_LIMIT}MB"
            fi
            FILE_SIZE_LIMIT_PLUS_ONE=$((FILE_SIZE_LIMIT + 1))
            
            generate_test_case \
            "Tentative d'upload d'un fichier dépassant la limite de taille" \
            "Se connecter en tant que vendeur et accéder à la section 'Share your product documentation'" \
            "Sélectionner ou glisser-déposer un fichier PDF de taille supérieure à ${FILE_SIZE_LIMIT}MB" \
            "Un message d'erreur banner apparaît immédiatement avec le texte '$ERROR_MSG', et l'upload est rejeté" \
            "Fichier: readme_fr.pdf
Format: PDF
Taille: ${FILE_SIZE_LIMIT_PLUS_ONE}MB" \
            "- ✅ Le message d'erreur banner apparaît immédiatement sans attendre la fin de l'upload
- ✅ Le message d'erreur exact est: '$ERROR_MSG'
- ✅ L'upload est rejeté et le fichier n'apparaît pas dans la zone
- ✅ La zone d'upload reste disponible"
        fi
        
        # Scénario 10: Nom de fichier incorrect
        if echo "$DESCRIPTION_DECODED" | grep -qi "Incorrect Filename\|mydocument.pdf\|must be titled readme_iso.pdf"; then
            ERROR_MSG=$(echo "$DESCRIPTION_DECODED" | grep -i "File must be titled readme_iso.pdf" | sed 's/.*"\([^"]*\)".*/\1/' | head -1)
            if [ -z "$ERROR_MSG" ]; then
                ERROR_MSG="The file could not be uploaded. File must be titled readme_iso.pdf"
            fi
            
            generate_test_case \
            "Tentative d'upload d'un fichier avec un nom incorrect" \
            "Se connecter en tant que vendeur et accéder à la section 'Share your product documentation'" \
            "Sélectionner ou glisser-déposer un fichier PDF nommé mydocument.pdf (au lieu de readme_*.pdf)" \
            "Un message d'erreur banner apparaît immédiatement avec le texte '$ERROR_MSG', et l'upload est rejeté" \
            "Fichier: mydocument.pdf
Format: PDF
Taille: 1MB
Nommage: incorrect (ne respecte pas readme_iso.pdf)" \
            "- ✅ Le message d'erreur banner apparaît immédiatement
- ✅ Le message d'erreur exact est: '$ERROR_MSG'
- ✅ L'upload est rejeté et le fichier n'apparaît pas dans la zone
- ✅ La zone d'upload reste disponible"
        fi
    fi
    
    # CAS DE PERFORMANCE (uniquement pour Upload)
    if [ "$IS_UPLOAD_FEATURE" = true ]; then
        echo ""
        echo "### ⚡ CAS DE PERFORMANCE"
        echo ""
        
        # Scénario 11: Performance lors de l'upload d'un fichier à la limite de taille
        if echo "$DESCRIPTION_DECODED" | grep -qi "Oversized File\|larger than.*MB"; then
            generate_test_case \
            "Performance lors de l'upload d'un fichier à la limite de taille" \
            "Se connecter en tant que vendeur et accéder à la section 'Share your product documentation'" \
            "Uploader un fichier PDF de ${FILE_SIZE_LIMIT}MB (readme_fr.pdf)" \
            "L'upload se termine dans un délai raisonnable (< 30 secondes) et le fichier apparaît correctement dans l'interface" \
            "Fichier: readme_fr.pdf
Taille: ${FILE_SIZE_LIMIT}MB (limite)
Format: PDF" \
            "- ✅ Le temps d'upload est acceptable (< 30 secondes pour ${FILE_SIZE_LIMIT}MB)
- ✅ Un indicateur de progression est visible pendant l'upload
- ✅ Le fichier apparaît correctement après l'upload
- ✅ Aucun timeout ou erreur de performance"
        fi
    fi
    
    # CAS D'INTÉGRATION
    echo ""
    echo "### 🔄 CAS D'INTÉGRATION"
    echo ""
    
    # Scénario: Persistance (pour Benefits ou Upload uniquement) - GÉNÉRÉ SYSTÉMATIQUEMENT
    if [ "$IS_BENEFITS_FEATURE" = true ]; then
        # Persistance des bénéfices après soumission - TOUJOURS généré
        generate_test_case \
            "Persistance des bénéfices sélectionnés après soumission" \
            "Avoir sélectionné des bénéfices (ex: 'Conversion rate', 'SEO optimized') et soumis la marketing sheet avec succès" \
            "Recharger la page de la marketing sheet ou y revenir ultérieurement" \
            "Les bénéfices sélectionnés sont toujours présents et affichés comme sélectionnés dans la section 'What benefits can your clients gain from your module/pack?'" \
            "Bénéfices sélectionnés: Conversion rate, SEO optimized
Action: Soumission puis rechargement de la page" \
            "- ✅ Les bénéfices sélectionnés sont toujours présents après rechargement
- ✅ Les checkboxes correspondantes sont cochées
- ✅ La limite de bénéfices est correctement appliquée
- ✅ Les données sont correctement persistées en base de données"
    elif [ "$IS_UPLOAD_FEATURE" = true ]; then
        # Persistance de la documentation après soumission - TOUJOURS généré pour Upload
        generate_test_case \
            "Persistance de la documentation après soumission de la marketing sheet" \
            "Avoir uploadé un fichier de documentation (readme_fr.pdf) et soumis la marketing sheet avec succès" \
            "Recharger la page de la marketing sheet ou y revenir ultérieurement" \
            "Le fichier de documentation (readme_fr.pdf) est toujours présent et affiché dans la section 'Share your product documentation'" \
            "Fichier uploadé: readme_fr.pdf
Action: Soumission puis rechargement de la page" \
            "- ✅ Le fichier de documentation est toujours présent après rechargement
- ✅ Le nom du fichier (readme_fr.pdf) est correctement affiché
- ✅ L'icône de suppression ('X') est toujours visible
- ✅ Les données sont correctement persistées en base de données"
    fi
    
    # ========== CAS DE COMPATIBILITÉ ==========
    echo ""
    echo "### 🌐 CAS DE COMPATIBILITÉ"
    echo ""
    
    if [ "$IS_BENEFITS_FEATURE" = true ]; then
        # Scénario 13: Fonctionnement sur différents navigateurs (Benefits)
        generate_test_case \
            "Fonctionnement sur différents navigateurs" \
            "Ouvrir un navigateur (Chrome 120+, Firefox 115+, Safari 17+, Edge)" \
            "Accéder à la section 'What benefits can your clients gain from your module/pack?' et tester la sélection de bénéfices" \
            "Le fonctionnement est identique sur tous les navigateurs testés" \
            "Navigateur: Chrome 120+ / Firefox 115+ / Safari 17+ / Edge
Type de produit: Module ou Pack" \
            "- ✅ Les checkboxes de bénéfices fonctionnent sur tous les navigateurs
- ✅ La désactivation automatique des autres checkboxes fonctionne correctement
- ✅ L'affichage des bénéfices est identique
- ✅ Aucune régression visuelle"
        
        # Scénario 14: Adaptation sur différentes tailles d'écran (Benefits)
        generate_test_case \
            "Adaptation sur différentes tailles d'écran" \
            "Ouvrir le navigateur et redimensionner la fenêtre à différentes résolutions" \
            "Accéder à la section 'What benefits can your clients gain from your module/pack?' et tester la sélection de bénéfices" \
            "L'interface s'adapte correctement à chaque résolution et tous les éléments restent accessibles" \
            "Résolutions:
- Desktop: 1920x1080
- Tablet: 768x1024
- Mobile: 375x667
Type de produit: Module ou Pack" \
            "- ✅ La section bénéfices est visible et fonctionnelle sur toutes les résolutions
- ✅ Les checkboxes sont accessibles et cliquables sur toutes les tailles d'écran
- ✅ Le texte et les labels sont lisibles
- ✅ Aucune perte de fonctionnalité sur mobile/tablette"
    elif [ "$IS_UPLOAD_FEATURE" = true ]; then
        # Scénario 13: Fonctionnement sur différents navigateurs (Upload)
        generate_test_case \
            "Fonctionnement sur différents navigateurs" \
            "Ouvrir un navigateur (Chrome 120+, Firefox 115+, Safari 17+, Edge)" \
            "Accéder à la section 'Share your product documentation' et uploader un fichier PDF valide (readme_fr.pdf)" \
            "Le fonctionnement est identique sur tous les navigateurs testés" \
            "Navigateur: Chrome 120+ / Firefox 115+ / Safari 17+ / Edge
Fichier: readme_fr.pdf
Taille: 1MB" \
            "- ✅ Le drag-and-drop fonctionne sur tous les navigateurs
- ✅ Le sélecteur de fichier fonctionne sur tous les navigateurs
- ✅ L'affichage du fichier uploadé est identique
- ✅ Aucune régression visuelle"
        
        # Scénario 14: Adaptation sur différentes tailles d'écran (Upload)
        generate_test_case \
            "Adaptation sur différentes tailles d'écran" \
            "Ouvrir le navigateur et redimensionner la fenêtre à différentes résolutions" \
            "Accéder à la section 'Share your product documentation' et tester l'upload d'un fichier" \
            "L'interface s'adapte correctement à chaque résolution et tous les éléments restent accessibles" \
            "Résolutions:
- Desktop: 1920x1080
- Tablet: 768x1024
- Mobile: 375x667
Fichier: readme_fr.pdf" \
            "- ✅ La zone d'upload est visible et fonctionnelle sur toutes les résolutions
- ✅ Le message informatif est lisible sur toutes les tailles d'écran
- ✅ L'icône de suppression est accessible et cliquable
- ✅ Aucune perte de fonctionnalité sur mobile/tablette"
    else
        # Scénario générique pour les autres fonctionnalités
        generate_test_case \
            "Fonctionnement sur différents navigateurs" \
            "Ouvrir un navigateur (Chrome 120+, Firefox 115+, Safari 17+, Edge)" \
            "Accéder à la fonctionnalité et tester son fonctionnement" \
            "Le fonctionnement est identique sur tous les navigateurs testés" \
            "Navigateur: Chrome 120+ / Firefox 115+ / Safari 17+ / Edge" \
            "- ✅ La fonctionnalité fonctionne sur tous les navigateurs
- ✅ L'affichage est identique
- ✅ Aucune régression visuelle"
        
        # Scénario 14: Adaptation sur différentes tailles d'écran (Générique)
        generate_test_case \
            "Adaptation sur différentes tailles d'écran" \
            "Ouvrir le navigateur et redimensionner la fenêtre à différentes résolutions" \
            "Accéder à la fonctionnalité et tester son fonctionnement" \
            "L'interface s'adapte correctement à chaque résolution et tous les éléments restent accessibles" \
            "Résolutions:
- Desktop: 1920x1080
- Tablet: 768x1024
- Mobile: 375x667" \
            "- ✅ La fonctionnalité est visible et fonctionnelle sur toutes les résolutions
- ✅ Tous les éléments sont accessibles et utilisables
- ✅ Le texte et les labels sont lisibles
- ✅ Aucune perte de fonctionnalité sur mobile/tablette"
    fi
    
    # ========== CAS DE SÉCURITÉ ==========
    echo ""
    echo "### 🔒 CAS DE SÉCURITÉ"
    echo ""
    
    if [ "$IS_BENEFITS_FEATURE" = true ]; then
        # Scénario: Protection contre l'injection XSS dans les labels de bénéfices
        generate_test_case \
            "Protection contre l'injection XSS dans les labels de bénéfices" \
            "Se connecter en tant qu'administrateur avec accès au back-office" \
            "Tenter d'injecter du code JavaScript dans un label de bénéfice (ex: '<script>alert(\"XSS\")</script>') et vérifier l'affichage côté vendeur" \
            "Le code JavaScript n'est pas exécuté et est correctement échappé/encodé dans l'interface" \
            "Label de test: <script>alert('XSS')</script>
Contexte: Back-office admin → Interface vendeur" \
            "- ✅ Le code JavaScript n'est pas exécuté dans le navigateur
- ✅ Les caractères spéciaux sont correctement échappés/encodés
- ✅ Le label s'affiche comme texte brut sans exécution de code
- ✅ Aucune alerte JavaScript n'apparaît
- ✅ La validation côté serveur rejette les entrées malveillantes"
        
        # Scénario: Test d'autorisation - Accès aux bénéfices d'autres produits
        generate_test_case \
            "Test d'autorisation - Accès aux bénéfices d'autres produits" \
            "Se connecter en tant que vendeur A avec un produit Module" \
            "Tenter d'accéder ou modifier les bénéfices d'un produit appartenant à un autre vendeur (vendeur B) via manipulation d'URL ou API" \
            "L'accès est refusé et aucune modification n'est possible sur les données d'un autre vendeur" \
            "Vendeur A: Produit Module ID 123
Vendeur B: Produit Module ID 456
Action: Tentative d'accès non autorisé" \
            "- ✅ L'accès aux données d'un autre vendeur est refusé (403 Forbidden)
- ✅ Aucune modification n'est possible sur les bénéfices d'un autre produit
- ✅ Les données retournées par l'API sont filtrées par propriétaire
- ✅ Les logs de sécurité enregistrent la tentative d'accès non autorisé"
    elif [ "$IS_UPLOAD_FEATURE" = true ]; then
        # Scénario: Validation côté serveur des fichiers uploadés
        generate_test_case \
            "Validation côté serveur des fichiers uploadés" \
            "Se connecter en tant que vendeur et accéder à la section 'Share your product documentation'" \
            "Tenter d'uploader un fichier malveillant (ex: fichier .pdf renommé contenant du code exécutable) en contournant la validation côté client" \
            "Le fichier est rejeté côté serveur même si la validation côté client est contournée" \
            "Fichier: script.exe renommé en readme_fr.pdf
Méthode: Contournement validation client (modification manuelle des headers HTTP)" \
            "- ✅ Le serveur valide le type MIME réel du fichier (pas seulement l'extension)
- ✅ Les fichiers malveillants sont rejetés même si l'extension est .pdf
- ✅ Un message d'erreur approprié est retourné
- ✅ Aucun fichier malveillant n'est stocké sur le serveur
- ✅ Les logs de sécurité enregistrent la tentative d'upload malveillant"
        
        # Scénario: Protection CSRF sur le formulaire d'upload
        generate_test_case \
            "Protection CSRF sur le formulaire d'upload" \
            "Se connecter en tant que vendeur et obtenir un token CSRF valide" \
            "Tenter de soumettre un formulaire d'upload depuis un site externe (sans token CSRF valide)" \
            "La requête est rejetée et aucun fichier n'est uploadé" \
            "Contexte: Site externe malveillant
Méthode: POST sans token CSRF valide" \
            "- ✅ La requête est rejetée avec une erreur 403 Forbidden
- ✅ Aucun fichier n'est uploadé sur le serveur
- ✅ Le token CSRF est requis et validé côté serveur
- ✅ Les tentatives CSRF sont enregistrées dans les logs de sécurité"
        
        # Scénario: Test d'autorisation - Accès aux fichiers d'autres vendeurs
        generate_test_case \
            "Test d'autorisation - Accès aux fichiers d'autres vendeurs" \
            "Se connecter en tant que vendeur A avec un fichier uploadé" \
            "Tenter d'accéder ou télécharger un fichier appartenant à un autre vendeur (vendeur B) via manipulation d'URL ou API" \
            "L'accès est refusé et le fichier n'est pas accessible" \
            "Vendeur A: Fichier readme_fr.pdf ID 123
Vendeur B: Fichier readme_fr.pdf ID 456
Action: Tentative d'accès non autorisé" \
            "- ✅ L'accès au fichier d'un autre vendeur est refusé (403 Forbidden)
- ✅ Le fichier n'est pas téléchargeable même avec l'URL directe
- ✅ Les données retournées par l'API sont filtrées par propriétaire
- ✅ Les logs de sécurité enregistrent la tentative d'accès non autorisé"
    else
        # Scénarios de sécurité génériques pour les autres fonctionnalités
        generate_test_case \
            "Protection CSRF sur les formulaires" \
            "Se connecter et obtenir un token CSRF valide" \
            "Tenter de soumettre un formulaire depuis un site externe (sans token CSRF valide)" \
            "La requête est rejetée et aucune action n'est effectuée" \
            "Contexte: Site externe malveillant
Méthode: POST sans token CSRF valide" \
            "- ✅ La requête est rejetée avec une erreur 403 Forbidden
- ✅ Aucune action n'est effectuée sur le serveur
- ✅ Le token CSRF est requis et validé côté serveur
- ✅ Les tentatives CSRF sont enregistrées dans les logs de sécurité"
        
        generate_test_case \
            "Test d'autorisation - Accès aux données d'autres utilisateurs" \
            "Se connecter en tant qu'utilisateur A" \
            "Tenter d'accéder ou modifier des données appartenant à un autre utilisateur (utilisateur B) via manipulation d'URL ou API" \
            "L'accès est refusé et aucune modification n'est possible" \
            "Utilisateur A: Données ID 123
Utilisateur B: Données ID 456
Action: Tentative d'accès non autorisé" \
            "- ✅ L'accès aux données d'un autre utilisateur est refusé (403 Forbidden)
- ✅ Les données ne sont pas accessibles même avec l'URL directe
- ✅ Les données retournées par l'API sont filtrées par propriétaire
- ✅ Les logs de sécurité enregistrent la tentative d'accès non autorisé"
    fi
    
    # ========== CAS D'ACCESSIBILITÉ ==========
    echo ""
    echo "### ♿ CAS D'ACCESSIBILITÉ"
    echo ""
    
    if [ "$IS_BENEFITS_FEATURE" = true ]; then
        # Scénario: Navigation complète au clavier (Benefits)
        generate_test_case \
            "Navigation complète au clavier" \
            "Accéder à la section 'What benefits can your clients gain from your module/pack?' sans utiliser la souris" \
            "Naviguer uniquement avec Tab/Enter/Espace pour accéder aux checkboxes de bénéfices et les sélectionner" \
            "Tous les éléments sont accessibles au clavier avec un ordre de tabulation logique et un focus visible" \
            "Touches: Tab, Enter, Espace, Flèches
Lecteur d'écran: [si applicable]" \
            "- ✅ Les checkboxes de bénéfices sont accessibles via Tab
- ✅ Les checkboxes peuvent être cochées/décochées avec Espace
- ✅ L'ordre de tabulation est logique
- ✅ Le focus est visible sur tous les éléments interactifs
- ✅ Les labels sont correctement associés aux checkboxes"
    elif [ "$IS_UPLOAD_FEATURE" = true ]; then
        # Scénario: Navigation complète au clavier (Upload)
        generate_test_case \
            "Navigation complète au clavier" \
            "Accéder à la section 'Share your product documentation' sans utiliser la souris" \
            "Naviguer uniquement avec Tab/Enter/Echap pour accéder à la zone d'upload et utiliser toutes les fonctionnalités" \
            "Tous les éléments sont accessibles au clavier avec un ordre de tabulation logique et un focus visible" \
            "Touches: Tab, Enter, Echap, Flèches
Lecteur d'écran: [si applicable]" \
            "- ✅ La zone d'upload est accessible via Tab
- ✅ Le sélecteur de fichier peut être déclenché avec Enter
- ✅ L'icône de suppression est accessible au clavier
- ✅ L'ordre de tabulation est logique
- ✅ Le focus est visible sur tous les éléments interactifs"
    else
        # Scénario: Navigation complète au clavier (Générique)
        generate_test_case \
            "Navigation complète au clavier" \
            "Accéder à la fonctionnalité sans utiliser la souris" \
            "Naviguer uniquement avec Tab/Enter/Espace pour accéder à tous les éléments interactifs et utiliser toutes les fonctionnalités" \
            "Tous les éléments sont accessibles au clavier avec un ordre de tabulation logique et un focus visible" \
            "Touches: Tab, Enter, Espace, Flèches
Lecteur d'écran: [si applicable]" \
            "- ✅ Tous les éléments interactifs sont accessibles via Tab
- ✅ Les actions peuvent être déclenchées avec Enter ou Espace
- ✅ L'ordre de tabulation est logique
- ✅ Le focus est visible sur tous les éléments interactifs
- ✅ Les labels sont correctement associés aux éléments"
    fi
    
    # Sections finales
    echo ""
    echo "## 🐛 Bugs identifiés"
    echo ""
    echo "### Bug #1"
    echo ""
    echo "- **Ticket** : [Lien Jira]"
    echo "- **Sévérité** : [Critique/Majeur/Mineur/Trivial]"
    echo "- **Description** : [Description du bug]"
    echo "- **Étapes de reproduction** : [Étapes]"
    echo "- **Statut** : [Ouvert/En cours/Résolu]"
    echo ""
    echo "---"
    echo ""
    echo "## 📊 Résumé des tests"
    echo ""
    SCENARIO_COUNT=$((SCENARIO_NUM - 1))
    echo "- **Total de scénarios** : $SCENARIO_COUNT"
    if [ "$IS_BENEFITS_FEATURE" = true ]; then
        echo "  - Cas nominaux : Variable (selon scénarios XML)"
        echo "  - Cas d'erreur : Variable (selon scénarios XML)"
        echo "  - Cas de performance : 2"
        echo "  - Cas d'intégration : 1"
        echo "  - Cas de sécurité : 2"
        echo "  - Cas de compatibilité : 2"
        echo "  - Cas d'accessibilité : 1"
    else
        echo "  - Cas nominaux : Variable (selon scénarios XML)"
        echo "  - Cas limites : Variable (selon scénarios XML)"
        echo "  - Cas d'erreur : Variable (selon scénarios XML)"
        echo "  - Cas de performance : Variable (selon scénarios XML)"
        echo "  - Cas d'intégration : 1"
        echo "  - Cas de sécurité : 3"
        echo "  - Cas de compatibilité : 2"
        echo "  - Cas d'accessibilité : 1"
    fi
    echo "- **Passés** : X (XX%)"
    echo "- **Échoués** : X (XX%)"
    echo "- **Bloqués** : X (XX%)"
    echo "- **Couverture estimée** : XX%"
    echo ""
    echo "---"
    echo ""
    echo "## 📝 Notes & Observations"
    echo ""
    echo "- [Note 1]"
    echo "- [Note 2]"
    echo "- [Recommandations]"
    echo ""
    echo "---"
    echo ""
    echo "## ✍️ Validation"
    echo ""
    echo "- **Testé par** : [Nom]"
    echo "- **Date de test** : $(date +"%Y-%m-%d")"
    echo "- **Validé par** : [Nom du responsable QA]"
    echo "- **Date de validation** : [AAAA-MM-JJ]"
    
} > "$OUTPUT_FILE"
set -e

echo "✅ Fichier de cas de test généré : $OUTPUT_FILE"
SCENARIO_COUNT=$((SCENARIO_NUM - 1))
echo "   - $SCENARIO_COUNT scénarios générés avec étapes, données de test et résultats attendus"
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
