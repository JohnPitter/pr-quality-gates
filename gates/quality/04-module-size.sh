#!/usr/bin/env bash
# Quality 04: Tamanho de modulos
# Coverage: FULL
set -euo pipefail
PLUGIN_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
source "$PLUGIN_DIR/lib/common.sh"
GATE="module-size"; CAT="quality"
MAX="$(jq -r '.file_lines_max' "$PLUGIN_DIR/config/thresholds.json")"
EXEMPT="$(jq -r '.exemptions.file_lines_max[]' "$PLUGIN_DIR/config/thresholds.json" 2>/dev/null || true)"
gate_header "$CAT" "$GATE" "threshold=${MAX} linhas/arquivo"
RAW=""
while IFS= read -r -d '' file; do
  [[ "$file" == *"_test.go" ]] && continue
  [[ "$file" == *"/vendor/"* ]] && continue
  skip=0
  while IFS= read -r ex; do [ -z "$ex" ] && continue; [[ "$file" == *"$ex" ]] && { skip=1; break; }; done <<< "$EXEMPT"
  [ "$skip" = "1" ] && continue
  LINES="$(wc -l < "$file" | tr -d ' ')"
  [ "$LINES" -gt "$MAX" ] && RAW+="$file"$'\t'"$file: $LINES linhas (max $MAX)"$'\n'
done < <(find . -type f -name "*.go" -print0)
[ -z "$RAW" ] && { gate_ok "$CAT" "$GATE"; exit 0; }
if baseline_mode_active; then echo -n "$RAW" | cut -f1 | baseline_capture "$GATE"; exit 0; fi
NEW_V="$(echo -n "$RAW" | baseline_filter "$GATE")"
TC="$(printf '%s' "$RAW" | grep -c . || true)"
if [ -n "$NEW_V" ]; then
  NC="$(echo "$NEW_V" | wc -l | tr -d ' ')"
  if baseline_ignored; then gate_fail "$CAT" "$GATE" "$NC arquivo(s) > $MAX linhas (full audit)"
  else gate_fail "$CAT" "$GATE" "$NC novo(s) arquivo(s) > $MAX linhas"; fi
  echo "$NEW_V" | sed 's/^/  /'
  exit 1
fi
baseline_exists "$GATE" && gate_ok "$CAT" "$GATE" "OK - $TC pre-existentes (baseline)" || gate_ok "$CAT" "$GATE"
