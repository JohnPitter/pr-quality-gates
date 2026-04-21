#!/usr/bin/env bash
# AI/ML 01: Prompt injection defense
# Coverage: HEURISTIC - detecta user input concatenado em prompt sem escape
set -euo pipefail
PLUGIN_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
source "$PLUGIN_DIR/lib/common.sh"
GATE="prompt-injection"; CAT="ai-ml"
gate_header "$CAT" "$GATE"

HAS_LLM="$(grep -rE 'openai|anthropic|claude|gemini|llm\.|chatgpt' --include='*.go' --exclude-dir=vendor -i . 2>/dev/null | head -1 || true)"
[ -z "$HAS_LLM" ] && { gate_ok "$CAT" "$GATE" "sem integracao LLM"; exit 0; }

# User input concatenado em prompt
BAD="$(grep -rEn 'Sprintf.*(prompt|Prompt|SystemMessage).*%s|prompt.*\+.*req\.|prompt.*\+.*input' --include='*.go' --exclude-dir=vendor . 2>/dev/null | head -10 || true)"
if [ -n "$BAD" ]; then
  gate_fail "$CAT" "$GATE" "user input concatenado em prompt (injection risk):"
  echo "$BAD" | sed 's/^/  /' | head -5
  echo "  sugestao: usar role-based messages + delimitadores, validar input"
  exit 1
fi
gate_ok "$CAT" "$GATE"
