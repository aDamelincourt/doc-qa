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
    # Support des formats : "Acceptance Criteria" et "ACCEPTANCE CRITERIA"
    # Ne pas s'arrêter aux autres sections h1 avant "Acceptance Criteria"
    local ac_section=$(echo "$decoded" | awk '
    BEGIN { in_ac_section = 0 }
    /Acceptance Criteria/i { 
        in_ac_section = 1
        print
        next
    }
    in_ac_section {
        print
        if (/^<h[12]>/ && !/Acceptance/i) {
            exit
        }
    }' | head -500)
    
    if [ -z "$ac_section" ]; then
        return 1
    fi
    
    # Extraire les AC individuels depuis la section décodée
    # Format dans XML: 
    #   <p><b><ins>AC 1 - Titre</ins></b></p>
    #   <p><b>Etant donné que</b> texte<br/> <b>Lorsque</b> texte<br/> <b>Alors</b> texte</p>
    local temp_file=$(mktemp)
    local ac_results_file=$(mktemp)
    
    # Extraire les numéros et titres des AC dans un fichier temporaire
    echo "$ac_section" | grep -E "AC[[:space:]]*[0-9]+|AC\.[0-9]+" > "$temp_file" || true
    
    # Pour chaque ligne avec un AC, extraire le numéro, le titre et le contenu
    while IFS= read -r line; do
        # Extraire le numéro AC (support "AC 1" et "AC.1")
        local ac_num=$(echo "$line" | sed -nE 's/.*AC[[:space:]]*([0-9]+).*/\1/p' | head -1)
        if [ -z "$ac_num" ]; then
            ac_num=$(echo "$line" | sed -nE 's/.*AC\.([0-9]+).*/\1/p' | head -1)
        fi
        
        if [ -z "$ac_num" ]; then
            continue
        fi
        
        # Extraire le titre (entre "AC N -" et "</")
        local title=$(echo "$line" | sed -nE 's/.*AC[[:space:]]*[0-9]+[[:space:]]*-[[:space:]]*([^<]+).*/\1/p' | sed 's/<[^>]*>//g' | sed 's/^[[:space:]]*//; s/[[:space:]]*$//')
        
        if [ -z "$title" ] || [ ${#title} -lt 3 ]; then
            title="Critère d'acceptation $ac_num"
        fi
        
        # Trouver le contenu de l'AC (paragraphe suivant qui contient Given/When/Then)
        # Utiliser awk pour trouver le paragraphe suivant "AC $ac_num"
        local content=$(echo "$ac_section" | awk -v ac_num="$ac_num" '
        BEGIN { 
            in_target_ac = 0
            content = ""
            in_paragraph = 0
        }
        /AC[[:space:]]*'$ac_num'[[:space:]]*-/ { 
            in_target_ac = 1
            next
        }
        in_target_ac && /<p>/ {
            in_paragraph = 1
            content = $0
            next
        }
        in_target_ac && in_paragraph {
            content = content " " $0
            if (/<\/p>/) {
                if (content ~ /Etant donné|Étant donné|Lorsque|Alors/) {
                    print content
                    exit
                }
                in_paragraph = 0
                content = ""
            }
        }
        in_target_ac && /AC[[:space:]]*[0-9]+/ && !/AC[[:space:]]*'$ac_num'[[:space:]]*-/ {
            exit
        }
        ' | head -1)
        
        if [ -n "$content" ]; then
            # Extraire Given/When/Then depuis le contenu
            local given=$(echo "$content" | sed -nE 's/.*<b>Etant donné que<\/b>[[:space:]]*([^<]*)(<br\/>)?.*/\1/p' | head -1)
            if [ -z "$given" ]; then
                given=$(echo "$content" | sed -nE 's/.*<b>Étant donné que<\/b>[[:space:]]*([^<]*)(<br\/>)?.*/\1/p' | head -1)
            fi
            if [ -z "$given" ]; then
                given=$(echo "$content" | grep -oE "Étant donné[^<]*|Etant donné[^<]*" | head -1 | sed 's/Étant donné[[:space:]]*que[[:space:]]*//i' | sed 's/Etant donné[[:space:]]*que[[:space:]]*//i')
            fi
            given=$(echo "$given" | sed 's/<[^>]*>//g' | sed 's/&[^;]*;//g' | sed 's/<br\/>//g' | sed 's/^[[:space:]]*//; s/[[:space:]]*$//' | head -c 200)
            
            local when=$(echo "$content" | sed -nE 's/.*<b>Lorsque<\/b>[[:space:]]*([^<]*)(<br\/>)?.*/\1/p' | head -1)
            if [ -z "$when" ]; then
                when=$(echo "$content" | grep -oE "Lorsque[^<]*" | head -1 | sed 's/Lorsque[[:space:]]*//i')
            fi
            when=$(echo "$when" | sed 's/<[^>]*>//g' | sed 's/&[^;]*;//g' | sed 's/<br\/>//g' | sed 's/^[[:space:]]*//; s/[[:space:]]*$//' | head -c 200)
            
            local then_clause=$(echo "$content" | sed -nE 's/.*<b>Alors<\/b>[[:space:]]*([^<]*)(<br\/>)?.*/\1/p' | head -1)
            if [ -z "$then_clause" ]; then
                then_clause=$(echo "$content" | grep -oE "Alors[^<]*" | head -1 | sed 's/Alors[[:space:]]*//i')
            fi
            then_clause=$(echo "$then_clause" | sed 's/<[^>]*>//g' | sed 's/&[^;]*;//g' | sed 's/<br\/>//g' | sed 's/^[[:space:]]*//; s/[[:space:]]*$//' | head -c 200)
            
            echo "AC.$ac_num|$title|$given|$when|$then_clause" >> "$ac_results_file"
        fi
    done < "$temp_file"
    
    # Afficher le résultat trié
    if [ -s "$ac_results_file" ]; then
        sort -t'|' -k1 -n < "$ac_results_file"
    fi
    
    rm -f "$temp_file" "$ac_results_file"
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
