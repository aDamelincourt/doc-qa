#!/bin/bash

# Script pour mettre à jour le README d'une US avec les informations extraites du XML et des fichiers générés
# Usage: ./scripts/update-readme-from-xml.sh [US_DIR]

set -euo pipefail

# Charger les bibliothèques communes
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LIB_DIR="$SCRIPT_DIR/lib"
source "$LIB_DIR/config.sh"
source "$LIB_DIR/common-functions.sh"
source "$LIB_DIR/xml-utils.sh"
source "$LIB_DIR/ticket-utils.sh"

# Gestion des erreurs avec trap
cleanup_on_error() {
    log_error "Erreur lors de la mise à jour du README. Nettoyage..."
    log_error "Dernière commande: $BASH_COMMAND"
    log_error "Ligne: $LINENO"
    exit 1
}
trap cleanup_on_error ERR

if [ -z "${1:-}" ]; then
    log_error "Dossier US requis"
    echo "Usage: ./scripts/update-readme-from-xml.sh [US_DIR]"
    echo "Exemple: ./scripts/update-readme-from-xml.sh projets/SPEX/us-2990"
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
    exit 1
fi

# Trouver le fichier XML
XML_FILE=$(get_xml_file_from_key "$TICKET_KEY")

if ! validate_xml "$XML_FILE"; then
    exit 1
fi

# Parser le XML une fois
if ! parse_xml_file "$XML_FILE"; then
    exit 1
fi

# Extraire la description complète
DESCRIPTION_SECTION=$(extract_description "$XML_FILE" 200)
DESCRIPTION_DECODED=$(decode_html "$DESCRIPTION_SECTION")

# ============================================================================
# EXTRACTION DES INFORMATIONS
# ============================================================================

# Extraire la User Story (As a... I want... So that... ou En tant que... Je veux...)
# Utiliser DESCRIPTION_DECODED qui est déjà décodé
# Extraire la section USER STORY complète entre "USER STORY" et la prochaine section
USER_STORY_SECTION=$(echo "$DESCRIPTION_DECODED" | sed -n '/USER STORY/I,/SPECS TECHNIQUES\|ACCEPTANCE CRITERIA/Ip' | head -20)
if [ -z "$USER_STORY_SECTION" ]; then
    # Si pas trouvé, essayer avec DESCRIPTION_SECTION (encodé) puis décoder
    USER_STORY_SECTION=$(echo "$DESCRIPTION_SECTION" | sed -n '/USER STORY/I,/SPECS TECHNIQUES\|ACCEPTANCE CRITERIA/Ip' | head -20)
    if [ -n "$USER_STORY_SECTION" ]; then
        USER_STORY_SECTION=$(decode_html "$USER_STORY_SECTION")
    fi
fi

# Extraire la phrase complète de la User Story en concaténant les lignes pertinentes
if echo "$USER_STORY_SECTION" | grep -qi "en tant que"; then
    # Format français : concaténer les lignes contenant "Afin de", "En tant que", "Je veux"
    USER_STORY_FULL=$(echo "$USER_STORY_SECTION" | grep -iE "afin de|en tant que|je veux" | tr '\n' ' ' | sed 's/<[^>]*>//g' | sed 's/&#160;/ /g' | sed 's/^[[:space:]]*//; s/[[:space:]]*$//' | sed 's/[[:space:]]\{2,\}/ /g' | head -c 500 || true)
else
    # Format anglais : concaténer les lignes contenant "As a", "I want", "So that"
    USER_STORY_FULL=$(echo "$USER_STORY_SECTION" | grep -iE "as a|i want|so that" | tr '\n' ' ' | sed 's/<[^>]*>//g' | sed 's/&#160;/ /g' | sed 's/^[[:space:]]*//; s/[[:space:]]*$//' | sed 's/[[:space:]]\{2,\}/ /g' | head -c 500 || true)
fi

# Si toujours vide, utiliser une valeur par défaut pour éviter les erreurs
if [ -z "$USER_STORY_FULL" ]; then
    USER_STORY_FULL="User Story non trouvée dans la description"
fi
# Nettoyer les doublons potentiels (prendre seulement la première occurrence si doublon)
USER_STORY_FULL=$(echo "$USER_STORY_FULL" | awk '{
    line = $0
    len = length(line)
    half = int(len/2)
    first_half = substr(line, 1, half)
    second_half = substr(line, half+1, half)
    if (first_half == second_half) {
        print first_half
    } else {
        print line
    }
}' | head -c 500)

# Extraire les parties de la User Story avec une méthode plus robuste
# Gérer les formats français et anglais
if echo "$USER_STORY_FULL" | grep -qi "en tant que"; then
    # Format français : "Afin de Z, En tant que X, Je veux Y"
    # Extraire "En tant que X"
    AS_A=$(echo "$USER_STORY_FULL" | sed -E 's/.*[Ee]n tant que ([^,]*),.*/\1/' | sed 's/^[[:space:]]*//; s/[[:space:]]*$//')
    # Extraire "Je veux Y" (peut être sur plusieurs lignes)
    I_WANT=$(echo "$USER_STORY_FULL" | sed -E 's/.*[Jj]e veux ([^.]*).*/\1/' | sed 's/^[[:space:]]*//; s/[[:space:]]*$//')
    # Extraire "Afin de Z" (peut être au début)
    SO_THAT=$(echo "$USER_STORY_FULL" | sed -E 's/.*[Aa]fin de ([^,]*),.*/\1/' | sed 's/^[[:space:]]*//; s/[[:space:]]*$//')
    if [ -z "$SO_THAT" ]; then
        SO_THAT=$(echo "$USER_STORY_FULL" | sed -E 's/^([^,]*),.*[Ee]n tant que.*/\1/' | sed 's/^[[:space:]]*//; s/[[:space:]]*$//')
    fi
else
    # Format anglais : "As a X, I want Y, So that Z"
    AS_A=$(echo "$USER_STORY_FULL" | sed -E 's/.*[Aa]s a ([^,]*),.*/\1/' | sed 's/^[[:space:]]*//; s/[[:space:]]*$//')
    if [ -z "$AS_A" ] || [ "$AS_A" = "$USER_STORY_FULL" ]; then
        AS_A=$(echo "$USER_STORY_FULL" | sed -E 's/.*[Aa]s a ([^,]*),.*/\1/' | head -1 | sed 's/^[[:space:]]*//; s/[[:space:]]*$//')
    fi
    
    I_WANT=$(echo "$USER_STORY_FULL" | sed -E 's/.*[Ii] want ([^,]*),.*/\1/' | sed 's/^[[:space:]]*//; s/[[:space:]]*$//')
    if [ -z "$I_WANT" ] || [ "$I_WANT" = "$USER_STORY_FULL" ]; then
        # Essayer d'extraire entre "I want" et "so that"
        I_WANT=$(echo "$USER_STORY_FULL" | sed -E 's/.*[Ii] want ([^.]*) so that.*/\1/' | sed 's/^[[:space:]]*//; s/[[:space:]]*$//')
    fi
    
    SO_THAT=$(echo "$USER_STORY_FULL" | sed -E 's/.*[Ss]o that ([^.]*).*/\1/' | sed 's/^[[:space:]]*//; s/[[:space:]]*$//')
    if [ -z "$SO_THAT" ] || [ "$SO_THAT" = "$USER_STORY_FULL" ]; then
        SO_THAT=$(echo "$USER_STORY_FULL" | sed -E 's/.*[Ss]o that ([^.]*).*/\1/' | head -1 | sed 's/^[[:space:]]*//; s/[[:space:]]*$//')
    fi
fi

# Extraire les critères d'acceptation (scénarios)
ACCEPTANCE_CRITERIA=$(echo "$DESCRIPTION_SECTION" | grep -A 50 -i "acceptance criteria\|scenario" | head -100 | sed 's/&lt;/</g; s/&gt;/>/g; s/&amp;/\&/g; s/&quot;/"/g; s/&apos;/'"'"'/g' | sed 's/<[^>]*>//g' | grep -i "scenario\|given\|when\|then" | head -10 || true)

# Compter les scénarios dans les fichiers de test
TEST_CASES_FILE="$US_DIR/03-cas-test.md"
TOTAL_SCENARIOS=0
if [ -f "$TEST_CASES_FILE" ]; then
    TOTAL_COUNT=$(grep -c "^### Scénario" "$TEST_CASES_FILE" 2>/dev/null || true)
    if [ -n "$TOTAL_COUNT" ] && [ "$TOTAL_COUNT" -gt 0 ] 2>/dev/null; then
        TOTAL_SCENARIOS=$TOTAL_COUNT
    fi
fi

# Compter les scénarios passés/échoués/bloqués (si le fichier existe)
PASSED_SCENARIOS=0
FAILED_SCENARIOS=0
BLOCKED_SCENARIOS=0
if [ -f "$TEST_CASES_FILE" ]; then
    PASSED_COUNT=$(grep -c "\[x\] Passé\|\[X\] Passé" "$TEST_CASES_FILE" 2>/dev/null || true)
    FAILED_COUNT=$(grep -c "\[x\] Échoué\|\[X\] Échoué" "$TEST_CASES_FILE" 2>/dev/null || true)
    BLOCKED_COUNT=$(grep -c "\[x\] Bloqué\|\[X\] Bloqué" "$TEST_CASES_FILE" 2>/dev/null || true)
    if [ -n "$PASSED_COUNT" ] && [ "$PASSED_COUNT" -gt 0 ] 2>/dev/null; then
        PASSED_SCENARIOS=$PASSED_COUNT
    fi
    if [ -n "$FAILED_COUNT" ] && [ "$FAILED_COUNT" -gt 0 ] 2>/dev/null; then
        FAILED_SCENARIOS=$FAILED_COUNT
    fi
    if [ -n "$BLOCKED_COUNT" ] && [ "$BLOCKED_COUNT" -gt 0 ] 2>/dev/null; then
        BLOCKED_SCENARIOS=$BLOCKED_COUNT
    fi
fi

# Calculer les valeurs restantes
TO_EXECUTE=$((TOTAL_SCENARIOS - PASSED_SCENARIOS - FAILED_SCENARIOS - BLOCKED_SCENARIOS))
if [ "$TO_EXECUTE" -lt 0 ]; then
    TO_EXECUTE=0
fi

# Calculer les pourcentages
if [ "$TOTAL_SCENARIOS" -gt 0 ]; then
    PASSED_PERCENT=$((PASSED_SCENARIOS * 100 / TOTAL_SCENARIOS))
    FAILED_PERCENT=$((FAILED_SCENARIOS * 100 / TOTAL_SCENARIOS))
    BLOCKED_PERCENT=$((BLOCKED_SCENARIOS * 100 / TOTAL_SCENARIOS))
    TO_EXECUTE_PERCENT=$((TO_EXECUTE * 100 / TOTAL_SCENARIOS))
else
    PASSED_PERCENT=0
    FAILED_PERCENT=0
    BLOCKED_PERCENT=0
    TO_EXECUTE_PERCENT=0
fi

# Vérifier les dates de création des fichiers
QUESTIONS_FILE="$US_DIR/01-questions-clarifications.md"
STRATEGY_FILE="$US_DIR/02-strategie-test.md"

QUESTIONS_DATE=""
STRATEGY_DATE=""
TEST_CASES_DATE=""

if [ -f "$QUESTIONS_FILE" ]; then
    QUESTIONS_DATE=$(grep "Date de création" "$QUESTIONS_FILE" | head -1 | sed 's/.*: //' | sed 's/[[:space:]]*$//')
fi
if [ -f "$STRATEGY_FILE" ]; then
    STRATEGY_DATE=$(grep "Date de création" "$STRATEGY_FILE" | head -1 | sed 's/.*: //' | sed 's/[[:space:]]*$//')
fi
if [ -f "$TEST_CASES_FILE" ]; then
    TEST_CASES_DATE=$(grep "Date de création" "$TEST_CASES_FILE" | head -1 | sed 's/.*: //' | sed 's/[[:space:]]*$//')
fi

# PROJECT_NAME est déjà extrait par parse_xml_file
if [ -z "$PROJECT_NAME" ]; then
    PROJECT_NAME=$(basename "$(dirname "$US_DIR")")
fi

# Mettre à jour le README
README_FILE="$US_DIR/README.md"

if [ ! -f "$README_FILE" ]; then
    log_warning "README.md n'existe pas, création depuis le template..."
    if ! validate_file "$TEMPLATES_DIR/us-readme-template.md"; then
        exit 1
    fi
    cp "$TEMPLATES_DIR/us-readme-template.md" "$README_FILE"
fi

# Remplacer les sections du README
CURRENT_DATE=$(date +"%Y-%m-%d")

# Mettre à jour les informations générales
sed -i '' "s|- \*\*User Story\*\* : .*|- **User Story** : $KEY|g" "$README_FILE"
sed -i '' "s|- \*\*Titre\*\* : .*|- **Titre** : $TITLE|g" "$README_FILE"
sed -i '' "s|- \*\*Projet\*\* : .*|- **Projet** : $PROJECT_NAME|g" "$README_FILE"
sed -i '' "s|- \*\*Lien Jira/Ticket\*\* : .*|- **Lien Jira/Ticket** : $LINK|g" "$README_FILE"

# Mettre à jour la description User Story
if [ -n "$AS_A" ]; then
    sed -i '' "s|\*\*En tant que\*\* : .*|**En tant que** : $AS_A|g" "$README_FILE"
fi
if [ -n "$I_WANT" ]; then
    sed -i '' "s|\*\*Je veux\*\* : .*|**Je veux** : $I_WANT|g" "$README_FILE"
fi
if [ -n "$SO_THAT" ]; then
    sed -i '' "s|\*\*Afin de\*\* : .*|**Afin de** : $SO_THAT|g" "$README_FILE"
fi

# Mettre à jour la description complète
if [ -n "$USER_STORY_FULL" ] && [ "$USER_STORY_FULL" != "User Story non trouvée dans la description" ]; then
    # Remplacer la ligne de description avec sed (plus simple et robuste)
    sed -i '' "s|\[Description de la User Story et du besoin utilisateur\]|$USER_STORY_FULL|g" "$README_FILE" || true
fi

# Extraire et formater les critères d'acceptation (scénarios)
# Utiliser le script dédié si disponible, sinon extraction inline
ACCEPTANCE_CRITERIA_LIST=""
if [ -n "$XML_FILE" ] && [ -f "$XML_FILE" ]; then
    # Essayer d'utiliser le script extract-acceptance-criteria.sh s'il existe
    if [ -f "$SCRIPT_DIR/extract-acceptance-criteria.sh" ]; then
        ACCEPTANCE_CRITERIA_LIST=$("$SCRIPT_DIR/extract-acceptance-criteria.sh" "$XML_FILE" 2>/dev/null || echo "")
    fi
    
    # Si le script n'a pas fonctionné ou n'existe pas, utiliser l'extraction inline
    if [ -z "$ACCEPTANCE_CRITERIA_LIST" ]; then
        # Extraire directement depuis le XML la section "Acceptance Criteria"
        ACCEPTANCE_SECTION=$(awk '/Acceptance Criteria/ {found=1} found {print} /^&lt;h1&gt;.*designs|^&lt;h1&gt;.*Tech|^&lt;h1&gt;.*Designs/ {exit}' "$XML_FILE" | head -200)
        
        # Décoder les entités HTML d'abord
        DECODED_SECTION=$(echo "$ACCEPTANCE_SECTION" | sed 's/&lt;/</g; s/&gt;/>/g; s/&amp;/\&/g; s/&quot;/"/g; s/&apos;/'"'"'/g; s/&#160;/ /g; s/&#8232;//g; s/&#8220;/"/g; s/&#8221;/"/g')
        
        # Extraire les titres des scénarios (format: <b>Scenario: ...</b> ou <b>Scenario - ...</b>)
        SCENARIO_LINES=$(echo "$DECODED_SECTION" | grep -i "<b>Scenario" || true)
        
        # Créer un fichier temporaire pour stocker les critères directement
        TEMP_CRITERIA_FILE=$(mktemp)
        COUNTER=1
        
        # Extraire les titres avec différentes méthodes selon le format
        if [ -n "$SCENARIO_LINES" ]; then
            while IFS= read -r LINE; do
                if [ -n "$LINE" ]; then
                    # Essayer d'extraire avec format "Scenario: ..."
                    TITLE=$(echo "$LINE" | sed -E 's/.*<b>Scenario[^:]*: *([^<]*)<\/b>.*/\1/')
                    # Si ça n'a pas fonctionné, essayer avec format "Scenario - ..."
                    if [ "$TITLE" = "$LINE" ] || [ -z "$TITLE" ]; then
                        TITLE=$(echo "$LINE" | sed -E 's/.*<b>Scenario[^<]*- *([^<]*)<\/b>.*/\1/')
                    fi
                    # Nettoyer le titre (enlever les balises HTML et les entités HTML restantes)
                    TITLE=$(echo "$TITLE" | sed 's/<[^>]*>//g' | sed 's/&#8211;/-/g; s/&#160;/ /g; s/&#8232;//g; s/  */ /g' | sed 's/^[[:space:]]*//; s/[[:space:]]*$//')
                    if [ -n "$TITLE" ] && [ "$TITLE" != "$LINE" ] && [ ${#TITLE} -gt 3 ]; then
                        echo "$COUNTER. $TITLE" >> "$TEMP_CRITERIA_FILE"
                        COUNTER=$((COUNTER + 1))
                    fi
                fi
            done <<< "$SCENARIO_LINES"
        fi
        
        # Lire les critères depuis le fichier temporaire
        if [ -f "$TEMP_CRITERIA_FILE" ] && [ -s "$TEMP_CRITERIA_FILE" ]; then
            ACCEPTANCE_CRITERIA_LIST=$(cat "$TEMP_CRITERIA_FILE")
            rm -f "$TEMP_CRITERIA_FILE"
        fi
    fi
fi

# Mettre à jour les critères d'acceptation dans le README
if [ -n "$ACCEPTANCE_CRITERIA_LIST" ]; then
    # Créer un fichier temporaire avec les nouveaux critères
    TEMP_CRITERIA=$(mktemp)
    echo "$ACCEPTANCE_CRITERIA_LIST" > "$TEMP_CRITERIA"
    
    # Créer un script awk temporaire
    TEMP_AWK=$(mktemp)
    cat > "$TEMP_AWK" <<'AWK_SCRIPT'
BEGIN {
    # Lire les critères depuis le fichier
    while ((getline line < criteria_file) > 0) {
        criteria[++n] = line
    }
    close(criteria_file)
}
/^## ✅ Critères d'acceptation/ {
    print
    getline  # Lire la ligne vide après le titre
    print ""
    # Afficher les critères
    for (i = 1; i <= n; i++) {
        print criteria[i]
    }
    # Ignorer les anciens critères jusqu'à la prochaine section
    while ((getline line) > 0) {
        if (line ~ /^---$/) {
            print ""
            print line
            break
        }
        if (line ~ /^[0-9]+\. \[Critère/) {
            # Ignorer les anciens placeholders
            continue
        }
        # Si on rencontre autre chose que les critères, on l'affiche
        if (line !~ /^[0-9]+\. /) {
            print line
        }
    }
    next
}
{ print }
AWK_SCRIPT
    
    # Remplacer la section des critères d'acceptation
    TEMP_README=$(mktemp)
    awk -v criteria_file="$TEMP_CRITERIA" -f "$TEMP_AWK" "$README_FILE" > "$TEMP_README"
    mv "$TEMP_README" "$README_FILE"
    rm -f "$TEMP_CRITERIA" "$TEMP_AWK"
fi

# Mettre à jour les dates des documents
if [ -n "$QUESTIONS_DATE" ]; then
    sed -i '' "s|Date de création : .*|Date de création : $QUESTIONS_DATE|g" "$README_FILE"
fi

# Mettre à jour la progression des tests
sed -i '' "s|- \*\*Total de scénarios\*\* : .*|- **Total de scénarios** : $TOTAL_SCENARIOS|g" "$README_FILE"
sed -i '' "s|- \*\*Passés\*\* : .*|- **Passés** : $PASSED_SCENARIOS ($PASSED_PERCENT%)|g" "$README_FILE"
sed -i '' "s|- \*\*Échoués\*\* : .*|- **Échoués** : $FAILED_SCENARIOS ($FAILED_PERCENT%)|g" "$README_FILE"
sed -i '' "s|- \*\*Bloqués\*\* : .*|- **Bloqués** : $BLOCKED_SCENARIOS ($BLOCKED_PERCENT%)|g" "$README_FILE"
sed -i '' "s|- \*\*À exécuter\*\* : .*|- **À exécuter** : $TO_EXECUTE ($TO_EXECUTE_PERCENT%)|g" "$README_FILE"

# Mettre à jour les dates dans la section Documents de test
if [ -n "$QUESTIONS_DATE" ]; then
    sed -i '' "s|Date de création : .*|Date de création : $QUESTIONS_DATE|g" "$README_FILE"
fi
if [ -n "$STRATEGY_DATE" ]; then
    sed -i '' "/Stratégie de Test/,/Date de création/ s|Date de création : .*|Date de création : $STRATEGY_DATE|g" "$README_FILE"
fi
if [ -n "$TEST_CASES_DATE" ]; then
    sed -i '' "/Cas de Test/,/Date de création/ s|Date de création : .*|Date de création : $TEST_CASES_DATE|g" "$README_FILE"
    # Mettre à jour les résultats
    sed -i '' "s|Résultats : .*|Résultats : $PASSED_SCENARIOS/$TOTAL_SCENARIOS scénarios passés|g" "$README_FILE"
fi

# Mettre à jour la date de dernière mise à jour
sed -i '' "s|- \*\*Dernière mise à jour\*\* : .*|- **Dernière mise à jour** : $CURRENT_DATE|g" "$README_FILE"

log_success "README.md mis à jour avec les informations extraites"
log_info "   - User Story : $AS_A / $I_WANT / $SO_THAT"
log_info "   - Total scénarios : $TOTAL_SCENARIOS"
log_info "   - Progression : $PASSED_SCENARIOS passés, $FAILED_SCENARIOS échoués, $BLOCKED_SCENARIOS bloqués"

