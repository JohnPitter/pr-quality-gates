#!/usr/bin/env bash
# API 08: Content-Type / Accept headers
# Coverage: HEURISTIC
set -euo pipefail
PLUGIN_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
source "$PLUGIN_DIR/lib/common.sh"
GATE="content-negotiation"; CAT="api"
gate_header "$CAT" "$GATE"

HAS_JSON="$(grep -rE 'json\.NewEncoder|json\.Marshal' --include='*.go' --exclude='*_test.go' --exclude-dir=vendor . 2>/dev/null | head -1 || true)"
[ -z "$HAS_JSON" ] && { gate_ok "$CAT" "$GATE" "sem JSON response"; exit 0; }

HAS_CT="$(grep -rE 'Content-Type.*application/json|Set\("Content-Type"' --include='*.go' --exclude-dir=vendor . 2>/dev/null | head -1 || true)"
[ -z "$HAS_CT" ] && gate_info "$CAT" "$GATE" "JSON response sem Content-Type explicito"
gate_ok "$CAT" "$GATE"
