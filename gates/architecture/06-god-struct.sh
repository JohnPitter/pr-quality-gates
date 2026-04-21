#!/usr/bin/env bash
# Architecture 06: God struct detection
# Coverage: HEURISTIC - struct com >15 metodos
# Exemptions: list struct names in thresholds.json -> exemptions.god_structs
# (plugin default) or in $(pwd)/.pr-quality-gates.json (project override).
# Useful for framework-mandated facades like Wails DesktopApp.
set -euo pipefail
PLUGIN_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
source "$PLUGIN_DIR/lib/common.sh"
GATE="god-struct"; CAT="architecture"
MAX="$(jq -r '.struct_max_methods // 15' "$PLUGIN_DIR/config/thresholds.json")"
EXEMPT="$(exemption_list god_structs)"
gate_header "$CAT" "$GATE" "max metodos/struct=$MAX"

# Count receivers per type across all files
declare -A METHODS
while IFS= read -r -d '' f; do
  [[ "$f" == *"/vendor/"* ]] && continue
  while IFS= read -r recv; do
    [ -z "$recv" ] && continue
    METHODS[$recv]=$((${METHODS[$recv]:-0}+1))
  done < <(grep -oE '^func \([a-z]+ \*?([A-Z][A-Za-z0-9]+)\)' "$f" 2>/dev/null | awk '{print $NF}' | tr -d '*)')
done < <(find . -name "*.go" -not -name "*_test.go" -print0 2>/dev/null)

# Build exemption set for O(1) lookup
declare -A EXEMPT_SET
while IFS= read -r ex; do
  [ -z "$ex" ] && continue
  EXEMPT_SET[$ex]=1
done <<< "$EXEMPT"

VIOL=""
EXEMPTED=""
for t in "${!METHODS[@]}"; do
  if [ "${METHODS[$t]}" -gt "$MAX" ]; then
    if [ -n "${EXEMPT_SET[$t]:-}" ]; then
      EXEMPTED+="  $t: ${METHODS[$t]} metodos (exempted)"$'\n'
    else
      VIOL+="  $t: ${METHODS[$t]} metodos (max $MAX)"$'\n'
    fi
  fi
done

if [ -n "$EXEMPTED" ]; then
  echo "[$CAT:$GATE] INFO - exempted god structs:"
  echo -n "$EXEMPTED"
fi

if [ -n "$VIOL" ]; then
  gate_fail "$CAT" "$GATE" "god struct(s) detectada(s):"
  echo -n "$VIOL"
  echo "  sugestao: separar por domain (ver Single Responsibility)"
  echo "  ou adicionar em .pr-quality-gates.json -> exemptions.god_structs (se framework-mandated)"
  exit 1
fi
gate_ok "$CAT" "$GATE"
