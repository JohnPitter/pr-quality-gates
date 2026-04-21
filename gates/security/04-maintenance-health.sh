#!/usr/bin/env bash
# Security 04: Dependency maintenance health
# Coverage: HEURISTIC - detecta deps abandonadas via go list (sem commits recentes requer API)
set -euo pipefail
PLUGIN_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
source "$PLUGIN_DIR/lib/common.sh"
GATE="maintenance-health"; CAT="security"
gate_header "$CAT" "$GATE"
[ -f go.mod ] || { gate_info "$CAT" "$GATE" "sem go.mod, skip"; exit 0; }

# Detect retracted or deprecated modules via go list
RETRACTED="$(go list -m -u -json all 2>/dev/null | jq -r 'select(.Retracted != null) | .Path' 2>/dev/null | head -20 || true)"
DEPRECATED="$(go list -m -u -json all 2>/dev/null | jq -r 'select(.Deprecated != null) | .Path + " - " + .Deprecated' 2>/dev/null | head -20 || true)"

ISSUES=0
if [ -n "$RETRACTED" ]; then
  gate_fail "$CAT" "$GATE" "deps retracted (risco conhecido):"
  echo "$RETRACTED" | sed 's/^/  /'
  ISSUES=1
fi
if [ -n "$DEPRECATED" ]; then
  [ "$ISSUES" = "0" ] && gate_fail "$CAT" "$GATE" "deps deprecated:"
  echo "$DEPRECATED" | sed 's/^/  /'
  ISSUES=1
fi
[ "$ISSUES" = "1" ] && exit 1
gate_ok "$CAT" "$GATE" "zero deprecated/retracted"
