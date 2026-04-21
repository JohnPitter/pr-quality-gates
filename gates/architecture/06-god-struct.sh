#!/usr/bin/env bash
# Architecture 06: God struct detection
# Coverage: HEURISTIC - struct com >15 metodos
set -euo pipefail
PLUGIN_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
source "$PLUGIN_DIR/lib/common.sh"
GATE="god-struct"; CAT="architecture"
MAX="$(jq -r '.struct_max_methods // 15' "$PLUGIN_DIR/config/thresholds.json")"
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

VIOL=""
for t in "${!METHODS[@]}"; do
  [ "${METHODS[$t]}" -gt "$MAX" ] && VIOL+="  $t: ${METHODS[$t]} metodos (max $MAX)"$'\n'
done

if [ -n "$VIOL" ]; then
  gate_fail "$CAT" "$GATE" "god struct(s) detectada(s):"
  echo -n "$VIOL"
  echo "  sugestao: separar por domain (ver Single Responsibility)"
  exit 1
fi
gate_ok "$CAT" "$GATE"
