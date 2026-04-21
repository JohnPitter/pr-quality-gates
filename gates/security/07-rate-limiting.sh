#!/usr/bin/env bash
# Security 07: Rate limiting em rotas HTTP
# Coverage: HEURISTIC - grep por padroes de middleware de rate limit
set -euo pipefail
PLUGIN_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
source "$PLUGIN_DIR/lib/common.sh"
GATE="rate-limiting"; CAT="security"
gate_header "$CAT" "$GATE"

# Look for HTTP handlers
HAS_HTTP="$(grep -rEl 'http\.(Handle|ListenAndServe)|gin\.|echo\.|chi\.|mux\.' --include='*.go' . 2>/dev/null | head -5 || true)"
[ -z "$HAS_HTTP" ] && { gate_ok "$CAT" "$GATE" "sem HTTP server detectado"; exit 0; }

# Look for rate-limit patterns
HAS_RL="$(grep -rE 'rate\.Limiter|ratelimit|throttle|rate_limit|RateLimiter' --include='*.go' . 2>/dev/null | head -3 || true)"
if [ -z "$HAS_RL" ]; then
  gate_fail "$CAT" "$GATE" "HTTP server detectado mas nenhum rate limiter (rate.Limiter, middleware throttle)"
  echo "  arquivos com HTTP server:"
  echo "$HAS_HTTP" | sed 's/^/    /'
  echo "  sugestao: golang.org/x/time/rate ou github.com/ulule/limiter"
  exit 1
fi
gate_ok "$CAT" "$GATE"
