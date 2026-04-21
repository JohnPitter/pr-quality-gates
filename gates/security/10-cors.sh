#!/usr/bin/env bash
# Security 10: CORS hardening
# Coverage: HEURISTIC
set -euo pipefail
PLUGIN_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
source "$PLUGIN_DIR/lib/common.sh"
GATE="cors"; CAT="security"
gate_header "$CAT" "$GATE"

# Wildcard CORS is dangerous
BAD="$(grep -rEn 'Access-Control-Allow-Origin.*\*|AllowOrigins.*\*|AllowedOrigins.*\*' --include='*.go' . 2>/dev/null || true)"
if [ -n "$BAD" ]; then
  gate_fail "$CAT" "$GATE" "CORS wildcard (*) detectado - permite qualquer origem"
  echo "$BAD" | sed 's/^/  /'
  echo "  sugestao: lista explicita de origens permitidas"
  exit 1
fi
gate_ok "$CAT" "$GATE"
