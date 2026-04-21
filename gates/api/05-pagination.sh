#!/usr/bin/env bash
# API 05: Paginacao em endpoints que retornam listas
# Coverage: HEURISTIC
set -euo pipefail
PLUGIN_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
source "$PLUGIN_DIR/lib/common.sh"
GATE="pagination"; CAT="api"
gate_header "$CAT" "$GATE"

# Funcoes Handler que retornam []Something sem limit/offset/cursor
LIST_HANDLERS="$(grep -rEn 'func.*Handler.*\(.*\[\]' --include='*.go' --exclude='*_test.go' --exclude-dir=vendor . 2>/dev/null | head -10 || true)"
HAS_PAG="$(grep -rE 'limit|offset|cursor|page_size|PageSize' --include='*.go' --exclude-dir=vendor . 2>/dev/null | head -1 || true)"

if [ -n "$LIST_HANDLERS" ] && [ -z "$HAS_PAG" ]; then
  gate_info "$CAT" "$GATE" "handlers retornando listas sem paginacao visivel"
  echo "$LIST_HANDLERS" | head -3 | sed 's/^/  /'
fi
gate_ok "$CAT" "$GATE"
