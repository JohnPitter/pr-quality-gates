#!/usr/bin/env bash
# Documentation 02: godoc coverage em simbolos exportados
# Coverage: FULL (revive)
set -euo pipefail
PLUGIN_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
source "$PLUGIN_DIR/lib/common.sh"
GATE="godoc-coverage"; CAT="documentation"
gate_header "$CAT" "$GATE"

command -v revive >/dev/null 2>&1 || go install github.com/mgechev/revive@latest
OUT="$(revive -config /dev/null -formatter default -exclude 'vendor/...' -rules exported ./... 2>&1 | grep -E '\.go:' | head -20 || true)"
if [ -n "$OUT" ]; then
  COUNT="$(echo "$OUT" | wc -l | tr -d ' ')"
  gate_info "$CAT" "$GATE" "$COUNT simbolo(s) exportado(s) sem godoc"
  echo "$OUT" | head -5 | sed 's/^/  /'
fi
gate_ok "$CAT" "$GATE"
