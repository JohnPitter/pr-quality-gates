#!/usr/bin/env bash
# API 04: API versioning estrategia consistente
# Coverage: HEURISTIC
set -euo pipefail
PLUGIN_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
source "$PLUGIN_DIR/lib/common.sh"
GATE="versioning"; CAT="api"
gate_header "$CAT" "$GATE"

HAS_HTTP="$(grep -rEl 'http\.(Handle|HandlerFunc)' --include='*.go' --exclude-dir=vendor . 2>/dev/null | head -1 || true)"
[ -z "$HAS_HTTP" ] && { gate_ok "$CAT" "$GATE" "sem HTTP"; exit 0; }

URL_V="$(grep -rnE '"/v[0-9]+/"|/v[0-9]+/' --include='*.go' --exclude='*_test.go' --exclude-dir=vendor . 2>/dev/null | head -5 || true)"
HDR_V="$(grep -rE 'API-Version|Accept-Version|X-API-Version' --include='*.go' --exclude-dir=vendor . 2>/dev/null | head -1 || true)"

if [ -n "$URL_V" ] && [ -n "$HDR_V" ]; then
  gate_info "$CAT" "$GATE" "versioning misto (URL + header) - escolher uma estrategia"
fi
if [ -z "$URL_V" ] && [ -z "$HDR_V" ]; then
  gate_info "$CAT" "$GATE" "nenhum versioning detectado - /v1/ ou X-API-Version recomendado"
fi
gate_ok "$CAT" "$GATE"
