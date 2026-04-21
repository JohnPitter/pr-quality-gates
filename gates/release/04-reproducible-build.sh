#!/usr/bin/env bash
# Release 04: Reproducible build flags
# Coverage: HEURISTIC
set -euo pipefail
PLUGIN_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
source "$PLUGIN_DIR/lib/common.sh"
GATE="reproducible-build"; CAT="release"
gate_header "$CAT" "$GATE"

HAS_TRIMPATH="$(grep -rE 'trimpath|-buildvcs' Makefile* .github/ Dockerfile* 2>/dev/null | head -1 || true)"
[ -z "$HAS_TRIMPATH" ] && gate_info "$CAT" "$GATE" "build sem -trimpath (paths absolutos no binario quebram reproducibilidade)"
gate_ok "$CAT" "$GATE"
