#!/bin/bash

# =============================================================================
# metrics.sh — Dashboard de métriques du pipeline QA
#
# Génère un rapport sur l'état de la couverture QA :
#   - Nombre de tickets documentés par projet
#   - Complétude des documents générés
#   - Qualité des documents (via validate-docs.sh)
#   - Historique des traitements
#
# Usage :
#   bash scripts/metrics.sh                    # Rapport texte
#   bash scripts/metrics.sh --format json      # Sortie JSON
#   bash scripts/metrics.sh --format markdown  # Sortie Markdown
#
# =============================================================================

set -euo pipefail

# ── Configuration ────────────────────────────────────────────────────────────

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
if [ -f "$SCRIPT_DIR/lib/config.sh" ]; then
    source "$SCRIPT_DIR/lib/config.sh"
else
    BASE_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
    PROJETS_DIR="$BASE_DIR/projets"
fi

FORMAT="text"

while [ $# -gt 0 ]; do
    case "$1" in
        --format|-f) FORMAT="$2"; shift 2 ;;
        --help|-h)
            echo "Usage : $0 [--format text|json|markdown]"
            exit 0
            ;;
        *) shift ;;
    esac
done

# ── Collecte des métriques ───────────────────────────────────────────────────

declare -A PROJECT_US_COUNT
declare -A PROJECT_COMPLETE
declare -A PROJECT_INCOMPLETE
TOTAL_US=0
TOTAL_COMPLETE=0
TOTAL_INCOMPLETE=0

if [ -d "$PROJETS_DIR" ]; then
    for project_dir in "$PROJETS_DIR"/*/; do
        [ -d "$project_dir" ] || continue
        _proj=$(basename "$project_dir")
        _us_count=0
        _complete=0
        _incomplete=0

        for us_dir in "$project_dir"/us-*/; do
            [ -d "$us_dir" ] || continue
            _us_count=$((_us_count + 1))

            # Vérifier si les 5 fichiers attendus existent
            _has_all=true
            for f in README.md extraction-jira.md 01-questions.md 02-strategie.md 03-cas-test.md; do
                if [ ! -f "$us_dir/$f" ] || [ ! -s "$us_dir/$f" ]; then
                    _has_all=false
                    break
                fi
            done

            if [ "$_has_all" = true ]; then
                _complete=$((_complete + 1))
            else
                _incomplete=$((_incomplete + 1))
            fi
        done

        PROJECT_US_COUNT[$_proj]=$_us_count
        PROJECT_COMPLETE[$_proj]=$_complete
        PROJECT_INCOMPLETE[$_proj]=$_incomplete
        TOTAL_US=$((TOTAL_US + _us_count))
        TOTAL_COMPLETE=$((TOTAL_COMPLETE + _complete))
        TOTAL_INCOMPLETE=$((TOTAL_INCOMPLETE + _incomplete))
    done
fi

# Pourcentage de complétude
if [ "$TOTAL_US" -gt 0 ]; then
    COMPLETION_PCT=$((TOTAL_COMPLETE * 100 / TOTAL_US))
else
    COMPLETION_PCT=0
fi

# Date du rapport
REPORT_DATE=$(date -u +"%Y-%m-%d %H:%M UTC")

# ── Formatage du rapport ─────────────────────────────────────────────────────

case "$FORMAT" in

json)
    # ── JSON ─────────────────────────────────────────────────────────────
    projects_json="["
    first=true
    for proj in $(echo "${!PROJECT_US_COUNT[@]}" | tr ' ' '\n' | sort); do
        [ "$first" = false ] && projects_json+=","
        first=false
        _c=${PROJECT_US_COUNT[$proj]}
        _ok=${PROJECT_COMPLETE[$proj]}
        _ko=${PROJECT_INCOMPLETE[$proj]}
        _p=0
        [ "$_c" -gt 0 ] && _p=$((_ok * 100 / _c))
        projects_json+="{\"name\":\"$proj\",\"total\":$_c,\"complete\":$_ok,\"incomplete\":$_ko,\"completionPct\":$_p}"
    done
    projects_json+="]"

    cat <<EOF
{
  "reportDate": "$REPORT_DATE",
  "summary": {
    "totalUS": $TOTAL_US,
    "complete": $TOTAL_COMPLETE,
    "incomplete": $TOTAL_INCOMPLETE,
    "completionPct": $COMPLETION_PCT
  },
  "projects": $projects_json
}
EOF
    ;;

markdown)
    # ── Markdown ─────────────────────────────────────────────────────────
    cat <<EOF
# Dashboard QA — Métriques

> Rapport généré le $REPORT_DATE

## Résumé global

| Métrique | Valeur |
|----------|--------|
| Total US documentées | $TOTAL_US |
| Complètes (5 fichiers) | $TOTAL_COMPLETE |
| Incomplètes | $TOTAL_INCOMPLETE |
| **Taux de complétude** | **${COMPLETION_PCT}%** |

## Par projet

| Projet | Total | Complètes | Incomplètes | Complétude |
|--------|-------|-----------|-------------|------------|
EOF
    for proj in $(echo "${!PROJECT_US_COUNT[@]}" | tr ' ' '\n' | sort); do
        _c=${PROJECT_US_COUNT[$proj]}
        _ok=${PROJECT_COMPLETE[$proj]}
        _ko=${PROJECT_INCOMPLETE[$proj]}
        _p=0
        [ "$_c" -gt 0 ] && _p=$((_ok * 100 / _c))
        echo "| $proj | $_c | $_ok | $_ko | ${_p}% |"
    done

    echo ""
    echo "---"
    echo ""
    echo "*Généré par \`make metrics\`*"
    ;;

*)
    # ── Texte (défaut) ───────────────────────────────────────────────────
    echo ""
    echo "==========================================="
    echo "  Dashboard QA — Métriques"
    echo "  $REPORT_DATE"
    echo "==========================================="
    echo ""
    echo "  Résumé global :"
    echo "    Total US documentées .... $TOTAL_US"
    echo "    Complètes (5 fichiers) .. $TOTAL_COMPLETE"
    echo "    Incomplètes ............ $TOTAL_INCOMPLETE"
    echo "    Taux de complétude ..... ${COMPLETION_PCT}%"
    echo ""
    echo "  Par projet :"
    echo "    $(printf '%-12s %-8s %-12s %-12s %-10s' 'Projet' 'Total' 'Complètes' 'Incomplètes' '%')"
    echo "    $(printf '%-12s %-8s %-12s %-12s %-10s' '------' '-----' '---------' '-----------' '--')"
    for proj in $(echo "${!PROJECT_US_COUNT[@]}" | tr ' ' '\n' | sort); do
        _c=${PROJECT_US_COUNT[$proj]}
        _ok=${PROJECT_COMPLETE[$proj]}
        _ko=${PROJECT_INCOMPLETE[$proj]}
        _p=0
        [ "$_c" -gt 0 ] && _p=$((_ok * 100 / _c))
        printf '    %-12s %-8s %-12s %-12s %-10s\n' "$proj" "$_c" "$_ok" "$_ko" "${_p}%"
    done
    echo ""
    echo "==========================================="
    echo ""
    ;;
esac
