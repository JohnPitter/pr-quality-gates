#!/usr/bin/env bash
# Gate 4: Tamanho de Modulos
# Falha se qualquer arquivo .go ultrapassar o limite de linhas.
# Suporta baseline: PR_QUALITY_BASELINE=1 congela o estado atual.
set -euo pipefail

PLUGIN_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
# shellcheck source=../lib/common.sh
source "$PLUGIN_DIR/lib/common.sh"

GATE="module-size"
MAX="$(jq -r '.file_lines_max' "$PLUGIN_DIR/config/thresholds.json")"
EXEMPT="$(jq -r '.exemptions.file_lines_max[]' "$PLUGIN_DIR/config/thresholds.json" 2>/dev/null || true)"

echo "[gate:$GATE] threshold=${MAX} linhas/arquivo"

# Collect oversized files as "signature\tviolation"
# Signature: "<file>" (line count stripped) so refactors that trim
# the file don't re-flag it.
RAW=""
while IFS= read -r -d '' file; do
  [[ "$file" == *"_test.go" ]] && continue
  [[ "$file" == *"/vendor/"* ]] && continue

  skip=0
  while IFS= read -r ex; do
    [ -z "$ex" ] && continue
    if [[ "$file" == *"$ex" ]]; then skip=1; break; fi
  done <<< "$EXEMPT"
  [ "$skip" = "1" ] && continue

  LINES="$(wc -l < "$file" | tr -d ' ')"
  if [ "$LINES" -gt "$MAX" ]; then
    RAW+="$file"$'\t'"$file: $LINES linhas (max $MAX)"$'\n'
  fi
done < <(find . -type f -name "*.go" -print0)

if [ -z "$RAW" ]; then
  echo "[gate:$GATE] OK"
  exit 0
fi

if baseline_mode_active; then
  echo -n "$RAW" | cut -f1 | baseline_capture "$GATE"
  echo "[gate:$GATE] baseline mode - all violations accepted"
  exit 0
fi

NEW_VIOLATIONS="$(echo -n "$RAW" | baseline_filter "$GATE")"

TOTAL_COUNT="$(printf '%s' "$RAW" | grep -c . || true)"

if [ -n "$NEW_VIOLATIONS" ]; then
  NEW_COUNT="$(echo "$NEW_VIOLATIONS" | wc -l | tr -d ' ')"
  BASELINED_COUNT="$((TOTAL_COUNT - NEW_COUNT))"
  echo "[gate:$GATE] FAIL - $NEW_COUNT novo(s) arquivo(s) acima de $MAX linhas (ignorados $BASELINED_COUNT do baseline):"
  echo "$NEW_VIOLATIONS" | sed 's/^/  /'
  exit 1
fi

if baseline_exists "$GATE"; then
  echo "[gate:$GATE] OK - $TOTAL_COUNT violacao(oes) pre-existentes (baseline), zero novas"
else
  echo "[gate:$GATE] OK"
fi
