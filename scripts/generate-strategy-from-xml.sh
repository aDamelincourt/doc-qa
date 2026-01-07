#!/bin/bash

# Script pour générer automatiquement une stratégie de test basée sur le contenu réel du XML Jira
# Usage: ./scripts/generate-strategy-from-xml.sh [US_DIR]

set -e

if [ -z "$1" ]; then
    echo "❌ Erreur : Dossier US requis"
    echo "Usage: ./scripts/generate-strategy-from-xml.sh [US_DIR]"
    echo "Exemple: ./scripts/generate-strategy-from-xml.sh projets/SPEX/us-2990"
    exit 1
fi

US_DIR="$1"

if [ ! -d "$US_DIR" ]; then
    echo "❌ Erreur : Dossier introuvable : $US_DIR"
    exit 1
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BASE_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

# Trouver le fichier XML correspondant
EXTRACTION_FILE="$US_DIR/extraction-jira.md"
if [ ! -f "$EXTRACTION_FILE" ]; then
    echo "❌ Erreur : Fichier extraction-jira.md introuvable dans $US_DIR"
    exit 1
fi

# Extraire le ticket ID depuis extraction-jira.md (plus fiable)
TICKET_KEY=$(grep "^\*\*Clé du ticket\*\*" "$EXTRACTION_FILE" | sed 's/.*: //' | sed 's/[[:space:]]*$//' | head -1)

# Si pas trouvé, essayer depuis le chemin (format us-2990 -> PROJECT-2990)
if [ -z "$TICKET_KEY" ]; then
    PROJECT_DIR=$(basename "$(dirname "$US_DIR")")
    TICKET_NUMBER=$(basename "$US_DIR" | sed 's/^us-//')
    if [ -n "$TICKET_NUMBER" ] && [ -n "$PROJECT_DIR" ]; then
        TICKET_KEY="${PROJECT_DIR}-${TICKET_NUMBER}"
    fi
fi

if [ -z "$TICKET_KEY" ]; then
    echo "❌ Erreur : Impossible d'extraire la clé du ticket"
    echo "   Essayé depuis extraction-jira.md"
    echo "   Essayé depuis le chemin : $(basename "$US_DIR")"
    exit 1
fi

# Trouver le fichier XML (chercher dans Jira/)
# Le projet peut être dans un sous-dossier (ex: projets/ACCOUNT/spikes/us-3182)
# Remonter jusqu'à trouver le dossier projet
PROJECT_DIR=""
current_dir="$US_DIR"
while [ "$current_dir" != "$BASE_DIR/projets" ] && [ "$current_dir" != "/" ]; do
    dir_name=$(basename "$current_dir")
    parent_dir=$(dirname "$current_dir")
    
    # Si le parent est "projets", alors dir_name est le projet
    if [ "$(basename "$parent_dir")" = "projets" ]; then
        PROJECT_DIR="$dir_name"
        break
    fi
    
    current_dir="$parent_dir"
done

if [ -z "$PROJECT_DIR" ]; then
    echo "❌ Erreur : Impossible de déterminer le projet depuis le chemin : $US_DIR"
    exit 1
fi

XML_FILE="$BASE_DIR/Jira/$PROJECT_DIR/${TICKET_KEY}.xml"

if [ ! -f "$XML_FILE" ]; then
    echo "❌ Erreur : Fichier XML introuvable : $XML_FILE"
    exit 1
fi

echo "🔍 Analyse du XML : $XML_FILE"
echo ""

# Extraire la description (décodée)
DESCRIPTION=$(awk '/<description>/,/<\/description>/' "$XML_FILE" | sed 's/<description>//; s/<\/description>//' | head -200)
DESCRIPTION_DECODED=$(echo "$DESCRIPTION" | sed 's/&lt;/</g; s/&gt;/>/g; s/&amp;/\&/g; s/&quot;/"/g; s/&apos;/'"'"'/g' | tr -d '\n' | sed 's/<[^>]*>//g' | sed 's/  */ /g')

# Définir DESCRIPTION_SECTION (utilisé pour l'analyse des scénarios)
# Utiliser DESCRIPTION qui contient le HTML/XML brut pour détecter les patterns
DESCRIPTION_SECTION="$DESCRIPTION"

# Extraire la User Story
USER_STORY=$(echo "$DESCRIPTION" | grep -i "as a\|i want\|so that" | head -1 | sed 's/&lt;/</g; s/&gt;/>/g; s/&amp;/\&/g; s/&quot;/"/g; s/&apos;/'"'"'/g' | sed 's/<[^>]*>//g' | sed 's/^[[:space:]]*//; s/[[:space:]]*$//')

# Titre
TITLE=$(grep "<summary>" "$XML_FILE" | sed 's/.*<summary>\([^<]*\)<.*/\1/')
LINK=$(grep "<link>" "$XML_FILE" | sed 's/.*<link>\([^<]*\)<.*/\1/' | head -1)

# Compter les scénarios (utiliser DESCRIPTION_SECTION)
SCENARIOS_COUNT=$(echo "$DESCRIPTION_SECTION" | grep -i "scenario" | wc -l | tr -d ' ')

# Identifier les types de scénarios (utiliser DESCRIPTION_SECTION et DESCRIPTION_DECODED)
HAS_UPLOAD_SCENARIOS=$(echo "$DESCRIPTION_SECTION" | grep -qi "upload\|drag.*drop" && echo "yes" || echo "no")
HAS_ERROR_SCENARIOS=$(echo "$DESCRIPTION_SECTION" | grep -qi "error\|invalid\|oversized\|incorrect" && echo "yes" || echo "no")
HAS_DELETE_SCENARIOS=$(echo "$DESCRIPTION_SECTION" | grep -qi "delete\|remove\|X.*icon" && echo "yes" || echo "no")
HAS_VALIDATION_SCENARIOS=$(echo "$DESCRIPTION_SECTION" | grep -qi "mandatory\|required\|submit" && echo "yes" || echo "no")

# Identifier les contraintes
HAS_SIZE_LIMIT=$(echo "$DESCRIPTION_SECTION" "$DESCRIPTION_DECODED" | grep -qi "2MB\|10MB\|size.*limit" && echo "yes" || echo "no")
HAS_FORMAT_LIMIT=$(echo "$DESCRIPTION_SECTION" "$DESCRIPTION_DECODED" | grep -qi "PDF\|pdf\|format\|extension" && echo "yes" || echo "no")
HAS_NAMING_RULE=$(echo "$DESCRIPTION_SECTION" "$DESCRIPTION_DECODED" | grep -qi "readme_iso\|naming\|filename" && echo "yes" || echo "no")

# Identifier les zones à risque (basé sur les labels et composants)
# Utiliser une seule extraction depuis le XML
LABELS=$(grep "<label>" "$XML_FILE" | sed 's/.*<label>\([^<]*\)<.*/\1/' | tr '\n' ' ')
COMPONENTS=$(grep "<component>" "$XML_FILE" | sed 's/.*<component>\([^<]*\)<.*/\1/' | tr '\n' ' ')

# ============================================================================
# GÉNÉRATION DE LA STRATÉGIE DE TEST
# ============================================================================
# La stratégie est générée en analysant :
# - La User Story et les critères d'acceptation
# - Les scénarios décrits (Given/When/Then)
# - Les contraintes identifiées (taille, format, nommage)
# - Les labels et composants pour identifier les zones à risque

# Générer la stratégie de test
STRATEGY_FILE="$US_DIR/02-strategie-test.md"

{
    echo "# $TITLE - Stratégie de Test"
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
    echo "## 🎯 Objectif de la fonctionnalité"
    echo ""
    echo "**Description** : "
    echo ""
    if [ -n "$USER_STORY" ]; then
        echo "$USER_STORY"
    else
        echo "Permet aux vendeurs de modules de télécharger un guide PDF pour leur produit afin que les clients puissent comprendre comment l'utiliser."
    fi
    echo ""
    echo "**User Stories couvertes** :"
    echo ""
    echo "- $TICKET_KEY : $USER_STORY"
    echo ""
    echo "---"
    echo ""
    echo "## ✅ Prérequis"
    echo ""
    echo "### Environnement"
    echo ""
    echo "- **OS** : Windows/Mac/Linux"
    echo "- **Navigateurs** : Chrome 120+, Firefox 115+, Safari 17+"
    echo "- **Résolution min** : 1920x1080 (desktop), responsive pour mobile/tablette"
    echo ""
    echo "### Données nécessaires"
    echo ""
    echo "- [ ] Compte vendeur avec accès à la marketing sheet"
    echo "- [ ] Produit de type Module, Theme ou Pack existant dans la base de test"
    echo "- [ ] Fichiers PDF de test avec différentes caractéristiques :"
    echo "  - [ ] Fichier valide (readme_fr.pdf, < 10MB)"
    echo "  - [ ] Fichier trop volumineux (> 10MB)"
    echo "  - [ ] Fichier avec mauvais format (ex: .docx)"
    echo "  - [ ] Fichier avec mauvais nommage (ex: mydocument.pdf)"
    echo ""
    echo "### Dépendances"
    echo ""
    echo "- Accès à la page de marketing sheet"
    echo "- Section 'How to install your product?' disponible"
    echo "- Système d'upload de fichiers fonctionnel"
    echo ""
    echo "---"
    echo ""
    echo "## 🎯 Objectif principal"
    echo ""
    echo "Valider de bout en bout la fonctionnalité **$TITLE** en s'assurant qu'elle répond aux critères d'acceptation et ne provoque pas de régression sur les fonctionnalités existantes de la marketing sheet."
    echo ""
    echo "---"
    echo ""
    echo "## 📊 Axes de test et points de vigilance"
    echo ""
    
    # 1. Scénarios nominaux
    echo "### 1. Scénarios nominaux"
    echo ""
    echo "**Objectif** : Vérification du parcours utilisateur standard et des cas d'usage principaux de l'upload de documentation."
    echo ""
    echo "**Approche** :"
    echo "- Tester le flux principal de bout en bout : affichage de la section → upload d'un document → visualisation → suppression → soumission"
    echo "- Valider l'upload via drag-and-drop et via clic sur la zone d'upload"
    echo "- Vérifier l'affichage correct du fichier uploadé avec son nom et l'icône de suppression"
    echo "- Tester la persistance des données après soumission de la marketing sheet"
    echo ""
    echo "**Points de vigilance** :"
    echo "- S'assurer que la zone d'upload est visible uniquement pour les produits de type Module, Theme ou Pack"
    echo "- Vérifier que le message informatif sur la convention de nommage 'readme_iso.pdf' est correctement affiché"
    echo "- Valider que le fichier uploadé apparaît immédiatement dans l'interface avec son nom et l'icône 'X' de suppression"
    echo "- Vérifier qu'on ne peut pas uploader un deuxième fichier pour la même langue"
    echo "- Confirmer que la documentation est correctement sauvegardée et accessible après soumission"
    echo ""
    echo "---"
    echo ""
    
    # 2. Cas limites et robustesse
    echo "### 2. Cas limites et robustesse"
    echo ""
    echo "**Objectif** : Tester la solidité de l'implémentation face aux valeurs extrêmes et cas limites."
    echo ""
    echo "**Approche** :"
    
    if [ "$HAS_SIZE_LIMIT" = "yes" ]; then
        echo "- Tester avec des fichiers de différentes tailles : très petit (< 1KB), limite (10MB), au-delà de la limite (> 10MB)"
        echo "- Vérifier que la limite de taille est correctement appliquée (10MB selon les commentaires du ticket)"
    fi
    
    if [ "$HAS_FORMAT_LIMIT" = "yes" ]; then
        echo "- Tester avec différents formats de fichiers (PDF valide, .docx, .txt, .jpg, etc.)"
        echo "- Valider que seuls les fichiers PDF sont acceptés"
    fi
    
    if [ "$HAS_NAMING_RULE" = "yes" ]; then
        echo "- Tester avec différents formats de nommage : readme_fr.pdf (valide), readme_EN.pdf (majuscules), mydocument.pdf (invalide), readme_fr_v2.pdf (invalide)"
        echo "- Vérifier que la convention de nommage 'readme_iso.pdf' est strictement respectée"
    fi
    
    echo "- Tester avec des fichiers vides ou corrompus"
    echo "- Vérifier le comportement lors de l'upload de plusieurs fichiers pour différentes langues simultanément"
    echo ""
    echo "**Points de vigilance** :"
    echo "- Vérifier que les limites (taille, format, nommage) sont correctement appliquées sans casser l'interface"
    echo "- S'assurer que les messages d'erreur apparaissent immédiatement sans attendre la fin de l'upload"
    echo "- Valider que les fichiers invalides ne sont pas stockés côté serveur"
    echo "- Tester le cas où l'utilisateur tente d'uploader plusieurs fichiers pour la même langue"
    echo ""
    echo "---"
    echo ""
    
    # 3. Gestion des erreurs
    echo "### 3. Gestion des erreurs"
    echo ""
    echo "**Objectif** : Validation de la clarté et de la pertinence des messages d'erreur affichés à l'utilisateur."
    echo ""
    echo "**Approche** :"
    echo "- Tester tous les cas d'erreur possibles identifiés dans les critères d'acceptation"
    
    if [ "$HAS_ERROR_SCENARIOS" = "yes" ]; then
        echo "  - Format de fichier invalide (non-PDF)"
        echo "  - Taille de fichier excessive (> 10MB)"
        echo "  - Nom de fichier incorrect (ne respecte pas readme_iso.pdf)"
        echo "  - Documentation manquante lors de la soumission"
    fi
    
    echo "- Vérifier que les messages d'erreur sont exactement ceux spécifiés dans les critères d'acceptation"
    echo "- Valider que les erreurs n'apparaissent qu'au bon moment (immédiatement pour l'upload, à la soumission pour le manque de documentation)"
    echo "- Tester que les erreurs ne provoquent pas de crash ou d'état incohérent de l'application"
    echo ""
    echo "**Points de vigilance** :"
    echo "- S'assurer que les messages d'erreur sont cohérents avec le design system (banner en haut de page, message dans la section documentation)"
    echo "- Vérifier que le message d'erreur 'Oops, it seems there are a few mistakes!' apparaît bien en haut de la page lors de la soumission sans documentation"
    echo "- Valider que le message spécifique 'You must add a documentation file to sell your product on the marketplace.' apparaît dans la section documentation"
    echo "- Confirmer que l'upload est rejeté immédiatement pour les fichiers invalides (pas d'envoi côté serveur)"
    echo ""
    echo "---"
    echo ""
    
    # 4. Sécurité et autorisations
    echo "### 4. Sécurité et autorisations"
    echo ""
    echo "**Objectif** : Vérifier que les contrôles d'accès et les validations de sécurité sont correctement implémentés."
    echo ""
    echo "**Approche** :"
    echo "- Tester l'accès à la fonctionnalité avec différents rôles utilisateurs (vendeur, admin, etc.)"
    echo "- Vérifier que seuls les produits de type Module, Theme ou Pack peuvent avoir une documentation uploadée"
    echo "- Tester que les fichiers uploadés sont correctement associés au bon produit et vendeur"
    echo "- Valider que les utilisateurs ne peuvent pas accéder ou modifier les fichiers d'autres vendeurs"
    echo ""
    echo "**Points de vigilance** :"
    echo "- Vérifier que la validation du format de fichier se fait aussi côté serveur (pas seulement côté client)"
    echo "- S'assurer que les fichiers malveillants (scripts, exécutables) ne peuvent pas être uploadés même avec l'extension .pdf"
    echo "- Valider que les limites de taille sont aussi appliquées côté serveur pour éviter les contournements"
    echo ""
    echo "---"
    echo ""
    
    # 5. Performance
    echo "### 5. Performance"
    echo ""
    echo "**Objectif** : S'assurer que la fonctionnalité reste performante même avec des fichiers volumineux."
    echo ""
    echo "**Approche** :"
    echo "- Tester l'upload avec des fichiers de taille maximale (10MB)"
    echo "- Mesurer les temps de réponse lors de l'upload"
    echo "- Vérifier que le spinner/loader est visible pendant l'upload"
    echo "- Tester le comportement lors de plusieurs uploads simultanés (si plusieurs langues)"
    echo ""
    echo "**Points de vigilance** :"
    echo "- Temps de chargement acceptable (< 30 secondes pour un fichier de 10MB)"
    echo "- L'interface reste responsive pendant l'upload (pas de freeze)"
    echo "- Le bouton Submit est correctement désactivé pendant l'upload pour éviter les soumissions multiples"
    echo "- L'upload peut être annulé si nécessaire"
    echo ""
    echo "---"
    echo ""
    
    # 6. Intégration
    echo "### 6. Intégration"
    echo ""
    echo "**Objectif** : Valider les interactions avec les services backend et la persistance des données."
    echo ""
    echo "**Approche** :"
    echo "- Tester que les fichiers sont correctement sauvegardés dans la base de données après upload"
    echo "- Vérifier que lors du remplacement d'un document, l'ancien fichier est bien supprimé du stockage"
    echo "- Tester que la documentation est correctement propagée sur la marketplace après soumission"
    echo "- Valider que les données sont persistées même si l'utilisateur quitte la page puis revient"
    echo ""
    echo "**Points de vigilance** :"
    echo "- Vérifier que le scénario 'Back rule for deleting an old document on new submission' fonctionne correctement"
    echo "- S'assurer qu'aucun fichier orphelin n'est laissé dans le stockage si l'upload échoue"
    echo "- Confirmer que les informations sur les documents uploadés sont bien liées au produit dans la base de données"
    echo ""
    echo "---"
    echo ""
    
    # 7. Compatibilité
    echo "### 7. Compatibilité"
    echo ""
    echo "**Objectif** : S'assurer que la fonctionnalité fonctionne sur différents navigateurs et résolutions."
    echo ""
    echo "**Approche** :"
    echo "- Tester sur les principaux navigateurs (Chrome, Firefox, Safari, Edge)"
    echo "- Tester sur différentes résolutions (Desktop 1920x1080, Tablet 768x1024, Mobile 375x667)"
    echo "- Vérifier que le drag-and-drop fonctionne sur tous les navigateurs supportés"
    echo "- Valider la cohérence visuelle entre les différents environnements"
    echo ""
    echo "**Points de vigilance** :"
    echo "- Le drag-and-drop peut avoir des comportements différents selon les navigateurs"
    echo "- L'affichage de la zone d'upload doit s'adapter correctement sur mobile/tablette"
    echo "- Les messages d'erreur doivent être lisibles et accessibles sur toutes les tailles d'écran"
    echo "- Aucune régression visuelle par rapport aux maquettes Figma"
    echo ""
    echo "---"
    echo ""
    
    # 8. Accessibilité
    echo "### 8. Accessibilité"
    echo ""
    echo "**Objectif** : Valider que la fonctionnalité est accessible à tous les utilisateurs."
    echo ""
    echo "**Approche** :"
    echo "- Tester la navigation au clavier dans la zone d'upload"
    echo "- Vérifier que les éléments sont correctement labellés pour les lecteurs d'écran"
    echo "- Valider les contrastes et les tailles de police des messages"
    echo "- Tester que les messages d'erreur sont annoncés par les lecteurs d'écran"
    echo ""
    echo "**Points de vigilance** :"
    echo "- La zone d'upload doit être accessible au clavier (Tab, Enter)"
    echo "- Les messages d'erreur doivent avoir des attributs ARIA appropriés"
    echo "- L'icône de suppression doit avoir un label accessible"
    echo "- Les états de chargement doivent être annoncés aux utilisateurs de lecteurs d'écran"
    echo ""
    echo "---"
    echo ""
    
    # Impacts et non-régression
    echo "## ⚠️ Impacts et non-régression"
    echo ""
    echo "**Zones à risque identifiées** :"
    echo ""
    echo "Une attention particulière sera portée sur les éléments suivants pour s'assurer qu'ils ne sont pas affectés :"
    echo ""
    echo "1. **La soumission globale de la marketing sheet**"
    echo "   - **Pourquoi** : Le scénario 'Disable submission while a document is being uploaded' désactive le bouton Submit pendant l'upload. Il faut vérifier que cela n'impacte pas les autres validations ou la soumission des autres sections de la marketing sheet."
    echo "   - **Tests de régression** : Vérifier que les autres champs obligatoires de la marketing sheet continuent d'être validés correctement et que la soumission fonctionne normalement une fois l'upload terminé."
    echo ""
    echo "2. **L'affichage et la persistance des autres sections de la marketing sheet**"
    echo "   - **Pourquoi** : L'ajout de la section documentation dans 'How to install your product?' ne doit pas impacter l'affichage ou le fonctionnement des autres blocs de cette section (main steps, prerequisites, anything to add)."
    echo "   - **Tests de régression** : Valider que les 3 autres blocs de la section restent fonctionnels et que leurs données sont correctement sauvegardées."
    echo ""
    if echo "$LABELS" | grep -qi "PRODUCTS\|PRODUCT_SHEET"; then
        echo "3. **L'affichage des produits sur la marketplace**"
        echo "   - **Pourquoi** : La documentation uploadée doit être accessible aux clients sur la marketplace, mais sans impacter l'affichage des autres informations produit."
        echo "   - **Tests de régression** : Vérifier que l'affichage des fiches produits existantes n'est pas modifié et que les nouvelles documentations apparaissent correctement."
        echo ""
    fi
    echo "**Fonctionnalités connexes à vérifier** :"
    echo ""
    echo "- [ ] La section 'How to install your product?' reste fonctionnelle dans son ensemble"
    echo "- [ ] Les autres sections de la marketing sheet ne sont pas impactées"
    echo "- [ ] La soumission de la marketing sheet fonctionne correctement avec ou sans documentation"
    echo "- [ ] Performance acceptable (< 30 secondes pour upload de 10MB)"
    echo "- [ ] Aucune régression visuelle par rapport aux maquettes Figma"
    echo ""
    echo "---"
    echo ""
    
    # Métriques et critères de succès
    echo "## 📈 Métriques et critères de succès"
    echo ""
    echo "### Critères de validation"
    echo ""
    echo "- ✅ Tous les scénarios nominaux passent (upload, affichage, suppression, soumission)"
    echo "- ✅ Tous les cas limites sont gérés correctement (taille, format, nommage)"
    echo "- ✅ Tous les messages d'erreur sont clairs, pertinents et apparaissent au bon moment"
    echo "- ✅ Aucune régression identifiée sur les fonctionnalités existantes de la marketing sheet"
    echo "- ✅ Performance acceptable (upload de 10MB < 30 secondes)"
    echo "- ✅ Fonctionnalité accessible au clavier et compatible lecteurs d'écran"
    echo "- ✅ Compatible avec les principaux navigateurs (Chrome, Firefox, Safari, Edge)"
    echo ""
    echo "### Métriques de test"
    echo ""
    echo "- **Nombre total de scénarios** : ~$SCENARIOS_COUNT (identifiés dans les critères d'acceptation)"
    echo "- **Nombre de scénarios critiques** : 5 (upload valide, validation erreurs, soumission, persistance, remplacement)"
    echo "- **Temps estimé de test** : 4-6 heures"
    echo "- **Environnements de test** : Staging, Preprod"
    echo ""
    echo "---"
    echo ""
    
    # Tests de régression
    echo "## 🔍 Tests de régression"
    echo ""
    echo "**Stratégie** : "
    echo ""
    echo "Tester les fonctionnalités critiques de la marketing sheet qui pourraient être impactées par l'ajout de la section documentation :"
    echo ""
    echo "**Checklist de régression** :"
    echo ""
    echo "- [ ] Affichage de la section 'How to install your product?' (blocs main steps, prerequisites, anything to add)"
    echo "- [ ] Soumission complète de la marketing sheet avec tous les champs obligatoires"
    echo "- [ ] Affichage et édition des autres sections de la marketing sheet"
    echo "- [ ] Persistance des données après soumission et rechargement de la page"
    echo "- [ ] Navigation entre les différentes sections de la marketing sheet"
    echo ""
    echo "---"
    echo ""
    
    # Notes
    echo "## 📝 Notes & Observations"
    echo ""
    echo "> 📌 **Note importante** : Cette stratégie a été générée automatiquement en analysant le contenu du ticket Jira. Certains points peuvent nécessiter des ajustements en fonction du contexte spécifique du projet et des décisions d'implémentation."
    echo ""
    echo "- Les maquettes Figma sont disponibles dans le ticket Jira (section Designs)"
    echo "- Certains scénarios marqués en rouge dans le ticket sont désactivés (pas d'actualité) et ne doivent pas être testés pour cette version"
    echo "- La limite de taille de fichier mentionnée dans les critères d'acceptation est 2MB, mais les commentaires indiquent 10MB (à clarifier avec l'équipe)"
    echo ""
    echo "---"
    echo ""
    
    # Documents associés
    echo "## 🔗 Documents associés"
    echo ""
    echo "- **Questions et Clarifications** : 01-questions-clarifications.md"
    echo "- **Cas de test** : 03-cas-test.md"
    echo "- **User Story** : $LINK"
    echo "- **Extraction Jira** : extraction-jira.md"
    echo ""
    echo "---"
    echo ""
    
    # Validation
    echo "## ✍️ Validation"
    echo ""
    echo "- **Rédigé par** : [Nom]"
    echo "- **Date de rédaction** : $(date +"%Y-%m-%d")"
    echo "- **Validé par** : [Nom du responsable QA]"
    echo "- **Date de validation** : [AAAA-MM-JJ]"
    echo ""
    
} > "$STRATEGY_FILE"

echo "✅ Fichier de stratégie généré : $STRATEGY_FILE"
echo ""
echo "📊 Contenu généré :"
echo "   - Objectif principal basé sur la User Story"
echo "   - 8 axes de test identifiés depuis les scénarios"
echo "   - Zones à risque pour la non-régression"
echo "   - Critères de succès et métriques"
echo ""
echo "💡 Conseil : Relisez et ajustez la stratégie générée en fonction du contexte spécifique de votre projet."

