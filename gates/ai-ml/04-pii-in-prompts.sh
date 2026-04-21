#!/usr/bin/env bash
# AI/ML 04: PII em prompts
# Coverage: HEURISTIC
set -euo pipefail
PLUGIN_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
source "$PLUGIN_DIR/lib/common.sh"
GATE="pii-in-prompts"; CAT="ai-ml"
gate_header "$CAT" "$GATE"

HAS_LLM="$(grep -rlE 'openai|anthropic|claude|gemini' --include='*.go' --exclude-dir=vendor -i . 2>/dev/null | head -1 || true)"
[ -z "$HAS_LLM" ] && { gate_ok "$CAT" "$GATE" "sem LLM"; exit 0; }

# Prompts com campos sensiveis (email, cpf, password, ssn)
BAD="$(grep -rEn '(prompt|Prompt|Content|Message).*(email|password|cpf|cnpj|ssn|credit.?card)' --include='*.go' --exclude='*_test.go' --exclude-dir=vendor -i . 2>/dev/null | head -5 || true)"
if [ -n "$BAD" ]; then
  gate_fail "$CAT" "$GATE" "provavel PII em prompt (LLM providers podem logar):"
  echo "$BAD" | sed 's/^/  /'
  echo "  sugestao: mask/redact antes de enviar"
  exit 1
fi
gate_ok "$CAT" "$GATE"
