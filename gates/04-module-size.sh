#!/usr/bin/env bash
# Gate 4: Tamanho de Modulos
# Falha se qualquer arquivo .go ultrapassar o limite de linhas.
set -euo pipefail

PLUGIN_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
# shellcheck source=../lib/common.sh
source "$PLUGIN_DIR/lib/common.sh"
MAX="$(jq -r '.file_lines_max' "$PLUGIN_DIR/config/thresholds.json")"
EXEMPT="$(jq -r '.exemptions.file_lines_max[]' "$PLUGIN_DIR/config/thresholds.json" 2>/dev/null || true)"

echo "[gate:size] threshold=${MAX} linhas/arquivo"

FAIL=0
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
    echo "[gate:size] FAIL - $file: $LINES linhas (max $MAX)"
    FAIL=1
  fi
done < <(find . -type f -name "*.go" -print0)

if [ "$FAIL" = "1" ]; then
  exit 1
fi

echo "[gate:size] OK"
