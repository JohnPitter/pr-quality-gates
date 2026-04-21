#!/usr/bin/env bash
# Observability 05: Trace context propagation
# Coverage: HEURISTIC
set -euo pipefail
PLUGIN_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
source "$PLUGIN_DIR/lib/common.sh"
GATE="trace-propagation"; CAT="observability"
gate_header "$CAT" "$GATE"

HAS_OTEL="$(grep -rE 'go\.opentelemetry\.io|otel\.' --include='*.go' . 2>/dev/null | head -1 || true)"
[ -z "$HAS_OTEL" ] && { gate_info "$CAT" "$GATE" "sem OpenTelemetry"; exit 0; }

# HTTP client sem trace propagation
HC="$(grep -rEn 'http\.(Get|Post|PostForm)\(' --include='*.go' --exclude='*_test.go' --exclude-dir=vendor . 2>/dev/null | head -5 || true)"
[ -n "$HC" ] && gate_info "$CAT" "$GATE" "http.Get/Post sem otelhttp.Transport (trace quebrado):" && echo "$HC" | sed 's/^/  /' | head -3

gate_ok "$CAT" "$GATE"
