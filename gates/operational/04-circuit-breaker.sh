#!/usr/bin/env bash
# Operational 04: Circuit breaker em deps externas
# Coverage: HEURISTIC
set -euo pipefail
PLUGIN_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
source "$PLUGIN_DIR/lib/common.sh"
GATE="circuit-breaker"; CAT="operational"
gate_header "$CAT" "$GATE"

HAS_HTTP_CLIENT="$(grep -rEl 'http\.Client|http\.Get|http\.Post' --include='*.go' --exclude='*_test.go' --exclude-dir=vendor . 2>/dev/null | head -1 || true)"
[ -z "$HAS_HTTP_CLIENT" ] && { gate_ok "$CAT" "$GATE" "sem HTTP client"; exit 0; }

HAS_CB="$(grep -rE 'gobreaker|hystrix|sony/gobreaker|circuit' --include='*.go' --exclude-dir=vendor -i . 2>/dev/null | head -1 || true)"
[ -z "$HAS_CB" ] && gate_info "$CAT" "$GATE" "HTTP client sem circuit breaker (sony/gobreaker, afex/hystrix)"
gate_ok "$CAT" "$GATE"
