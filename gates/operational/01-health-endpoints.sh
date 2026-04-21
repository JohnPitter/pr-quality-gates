#!/usr/bin/env bash
# Operational 01: Health endpoints (/healthz, /readyz)
# Coverage: HEURISTIC
set -euo pipefail
PLUGIN_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
source "$PLUGIN_DIR/lib/common.sh"
GATE="health-endpoints"; CAT="operational"
gate_header "$CAT" "$GATE"

HAS_HTTP="$(grep -rEl 'http\.Handle|HandleFunc|http\.ListenAndServe' --include='*.go' --exclude-dir=vendor . 2>/dev/null | head -1 || true)"
[ -z "$HAS_HTTP" ] && { gate_ok "$CAT" "$GATE" "sem HTTP server"; exit 0; }

HAS_HC="$(grep -rE '/(health|ready|liveness|readiness|healthz|readyz|live)"' --include='*.go' --exclude-dir=vendor . 2>/dev/null | head -1 || true)"
if [ -z "$HAS_HC" ]; then
  gate_fail "$CAT" "$GATE" "HTTP server sem health/readiness endpoint"
  echo "  adicionar: /healthz (liveness) e /readyz (readiness separados)"
  exit 1
fi
gate_ok "$CAT" "$GATE"
