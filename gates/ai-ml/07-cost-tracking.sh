#!/usr/bin/env bash
# AI/ML 07: Cost/token tracking em LLM calls
# Coverage: HEURISTIC
set -euo pipefail
PLUGIN_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
source "$PLUGIN_DIR/lib/common.sh"
GATE="cost-tracking"; CAT="ai-ml"
gate_header "$CAT" "$GATE"

HAS_LLM="$(grep -rlE 'openai|anthropic|claude|gemini' --include='*.go' --exclude-dir=vendor -i . 2>/dev/null | head -1 || true)"
[ -z "$HAS_LLM" ] && { gate_ok "$CAT" "$GATE" "sem LLM"; exit 0; }

HAS_TOKENS="$(grep -rE 'usage\.TotalTokens|prompt_tokens|completion_tokens|tokenCount|InputTokens|OutputTokens' --include='*.go' --exclude-dir=vendor . 2>/dev/null | head -1 || true)"
if [ -z "$HAS_TOKENS" ]; then
  gate_info "$CAT" "$GATE" "LLM calls sem tracking de tokens (sem controle de custo)"
  echo "  sugestao: logar response.Usage por request"
fi
gate_ok "$CAT" "$GATE"
