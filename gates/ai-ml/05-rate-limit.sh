#!/usr/bin/env bash
# AI/ML 05: Rate limiting para LLM APIs (custo + abuso)
# Coverage: HEURISTIC
set -euo pipefail
PLUGIN_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
source "$PLUGIN_DIR/lib/common.sh"
GATE="llm-rate-limit"; CAT="ai-ml"
gate_header "$CAT" "$GATE"

HAS_LLM="$(grep -rlE 'openai|anthropic|claude|gemini' --include='*.go' --exclude-dir=vendor -i . 2>/dev/null | head -1 || true)"
[ -z "$HAS_LLM" ] && { gate_ok "$CAT" "$GATE" "sem LLM"; exit 0; }

HAS_RL="$(grep -rE 'rate\.Limiter|ratelimit|token.?bucket|semaphore' --include='*.go' --exclude-dir=vendor . 2>/dev/null | head -1 || true)"
if [ -z "$HAS_RL" ]; then
  gate_info "$CAT" "$GATE" "LLM sem rate limiter local (risco de custo descontrolado)"
  echo "  sugestao: golang.org/x/time/rate pra limitar requests/segundo"
fi
gate_ok "$CAT" "$GATE"
