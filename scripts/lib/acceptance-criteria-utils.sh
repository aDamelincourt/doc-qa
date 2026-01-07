#!/bin/bash

# Bibliothèque de fonctions pour extraire et traiter les critères d'acceptation
# Usage: source "$(dirname "${BASH_SOURCE[0]}")/lib/acceptance-criteria-utils.sh"

# Extraire les critères d'acceptation depuis le XML
# Usage: extract_acceptance_criteria "/path/to/file.xml"
# Retourne: Liste des AC avec format "AC.N|Titre|Given|When|Then"
extract_acceptance_criteria() {
    local xml_file="$1"
    
    if [ ! -f "$xml_file" ]; then
        return 1
    fi
    
    # Extraire la section description complète
    local description_section=$(awk '/<description>/,/<\/description>/' "$xml_file")
    
    # Décoder les entités HTML
    local decoded=$(echo "$description_section" | sed 's/&lt;/</g; s/&gt;/>/g; s/&amp;/\&/g; s/&quot;/"/g; s/&apos;/'"'"'/g; s/&#160;/ /g; s/&#233;/é/g; s/&#224;/à/g; s/&#232;/è/g; s/&#249;/ù/g; s/&#231;/ç/g; s/&#8211;/-/g; s/&#8212;/--/g; s/&#8217;/'"'"'/g')
    
    # Extraire la section "Acceptance Criteria" (jusqu'à la prochaine section h1/h2 ou fin)
    local ac_section=$(echo "$decoded" | awk '/Acceptance Criteria/ {found=1} found {print} /^<h[12]>/ && found && !/Acceptance/ {exit}' | head -500)
    
    # Extraire les AC individuels depuis la section décodée
    # Format dans XML: <p><b>AC.N - Titre</b><br/> Étant donné... Lorsque... Alors...</p>
    local temp_file=$(mktemp)
    
    # Extraire chaque paragraphe contenant un AC
    echo "$ac_section" | awk '
    /<p>.*AC\.[0-9]+/ {
        in_ac = 1
        ac_text = $0
        next
    }
    in_ac {
        ac_text = ac_text " " $0
        if (/<\/p>/) {
            print ac_text
            in_ac = 0
            ac_text = ""
        }
    }' > "$temp_file"
    
    # Traiter chaque AC trouvé
    while IFS= read -r ac_paragraph; do
        if [ -z "$ac_paragraph" ]; then
            continue
        fi
        
        # Extraire le numéro AC
        local ac_num=$(echo "$ac_paragraph" | sed -nE 's/.*AC\.([0-9]+).*/\1/p' | head -1)
        
        if [ -z "$ac_num" ]; then
            continue
        fi
        
        # Extraire le titre (format: <b>AC.N - Titre</b>)
        local title=$(echo "$ac_paragraph" | sed -E 's/.*<b>AC\.[0-9]+[[:space:]]*-[[:space:]]*([^<]*)<\/b>.*/\1/' | sed 's/<[^>]*>//g' | sed 's/&[^;]*;//g' | sed 's/^[[:space:]]*//; s/[[:space:]]*$//')
        
        if [ -z "$title" ] || [ ${#title} -lt 3 ]; then
            title="Critère d'acceptation $ac_num"
        fi
        
        # Extraire Given/When/Then depuis le paragraphe
        local given=$(echo "$ac_paragraph" | grep -oE "Étant donné[^<]*|Etant donné[^<]*" | head -1 | sed 's/Étant donné[[:space:]]*que[[:space:]]*//i' | sed 's/Etant donné[[:space:]]*que[[:space:]]*//i' | sed 's/<[^>]*>//g' | sed 's/&[^;]*;//g' | sed 's/^[[:space:]]*//; s/[[:space:]]*$//' | head -c 200)
        
        local when=$(echo "$ac_paragraph" | grep -oE "Lorsque[^<]*" | head -1 | sed 's/Lorsque[[:space:]]*//i' | sed 's/<[^>]*>//g' | sed 's/&[^;]*;//g' | sed 's/^[[:space:]]*//; s/[[:space:]]*$//' | head -c 200)
        
        local then_clause=$(echo "$ac_paragraph" | grep -oE "Alors[^<]*" | head -1 | sed 's/Alors[[:space:]]*//i' | sed 's/<[^>]*>//g' | sed 's/&[^;]*;//g' | sed 's/^[[:space:]]*//; s/[[:space:]]*$//' | head -c 200)
        
        if [ -n "$ac_num" ]; then
            echo "AC.$ac_num|$title|$given|$when|$then_clause"
        fi
    done < "$temp_file" | sort -t'|' -k1 -n
    
    rm -f "$temp_file"
}

# Convertir un AC en scénario de test
# Usage: ac_to_test_scenario "AC.1" "Titre" "Given" "When" "Then"
ac_to_test_scenario() {
    local ac_num="$1"
    local title="$2"
    local given="$3"
    local when="$4"
    local then_clause="$5"
    
    # Nettoyer les chaînes
    title=$(echo "$title" | sed 's/<[^>]*>//g' | sed 's/^[[:space:]]*//; s/[[:space:]]*$//')
    given=$(echo "$given" | sed 's/<[^>]*>//g' | sed 's/^[[:space:]]*//; s/[[:space:]]*$//')
    when=$(echo "$when" | sed 's/<[^>]*>//g' | sed 's/^[[:space:]]*//; s/[[:space:]]*$//')
    then_clause=$(echo "$then_clause" | sed 's/<[^>]*>//g' | sed 's/^[[:space:]]*//; s/[[:space:]]*$//')
    
    # Si le titre est vide, utiliser le numéro AC
    if [ -z "$title" ]; then
        title="Critère d'acceptation $ac_num"
    fi
    
    # Construire les données de test à partir du Given/When
    local test_data=""
    if [ -n "$given" ]; then
        test_data="$given"
    fi
    if [ -n "$when" ]; then
        if [ -n "$test_data" ]; then
            test_data="$test_data\nAction: $when"
        else
            test_data="Action: $when"
        fi
    fi
    
    # Construire le résultat attendu à partir du Then
    local expected_result=""
    if [ -n "$then_clause" ]; then
        expected_result="- ✅ $then_clause"
    else
        expected_result="- ✅ Le critère d'acceptation $ac_num est respecté"
    fi
    
    echo "$title|$given|$when|$then_clause|$test_data|$expected_result"
}

