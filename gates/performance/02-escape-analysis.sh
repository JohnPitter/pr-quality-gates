#!/usr/bin/env bash
# Performance 02: Escape analysis
# Coverage: FULL (go build -gcflags='-m')
set -euo pipefail
PLUGIN_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
source "$PLUGIN_DIR/lib/common.sh"
GATE="escape-analysis"; CAT="performance"
MAX="$(jq -r '.escapes_max // 100' "$PLUGIN_DIR/config/thresholds.json")"
gate_header "$CAT" "$GATE" "max escapes=$MAX"

ESC="$(go build -gcflags='-m' ./... 2>&1 | grep -c 'escapes to heap' || echo 0)"
if [ "$ESC" -gt "$MAX" ]; then
  gate_fail "$CAT" "$GATE" "$ESC allocations escapam pra heap (max $MAX)"
  go build -gcflags='-m' ./... 2>&1 | grep 'escapes to heap' | head -10 | sed 's/^/  /'
  echo "  sugestao: retornar por valor em hot paths, evitar interface{} desnecessario"
  exit 1
fi
gate_ok "$CAT" "$GATE" "$ESC escapes (dentro do limite $MAX)"
