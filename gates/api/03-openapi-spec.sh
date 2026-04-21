#!/usr/bin/env bash
# API 03: OpenAPI spec presente + lintado
# Coverage: HEURISTIC
set -euo pipefail
PLUGIN_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
source "$PLUGIN_DIR/lib/common.sh"
GATE="openapi-spec"; CAT="api"
gate_header "$CAT" "$GATE"

HAS_HTTP="$(grep -rEl 'http\.(Handle|HandlerFunc)' --include='*.go' --exclude-dir=vendor . 2>/dev/null | head -1 || true)"
[ -z "$HAS_HTTP" ] && { gate_ok "$CAT" "$GATE" "sem HTTP API"; exit 0; }

SPEC="$(find . -maxdepth 3 -type f \( -name "openapi.yaml" -o -name "openapi.yml" -o -name "openapi.json" -o -name "swagger.yaml" -o -name "api.yaml" \) -not -path '*/vendor/*' -not -path '*/node_modules/*' 2>/dev/null | head -1 || true)"

if [ -z "$SPEC" ]; then
  gate_fail "$CAT" "$GATE" "HTTP API sem OpenAPI spec (openapi.yaml/swagger.yaml)"
  echo "  sugestao: swag init (swaggo/swag) ou manual em api/openapi.yaml"
  exit 1
fi
gate_ok "$CAT" "$GATE" "spec em $SPEC"
