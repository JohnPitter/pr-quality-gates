#!/usr/bin/env bash
# AI/ML 06: LLM response schema validation
# Coverage: HEURISTIC
set -euo pipefail
PLUGIN_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
source "$PLUGIN_DIR/lib/common.sh"
GATE="response-validation"; CAT="ai-ml"
gate_header "$CAT" "$GATE"

HAS_LLM="$(grep -rlE 'openai|anthropic|claude|gemini' --include='*.go' --exclude-dir=vendor -i . 2>/dev/null | head -1 || true)"
[ -z "$HAS_LLM" ] && { gate_ok "$CAT" "$GATE" "sem LLM"; exit 0; }

# Uso de JSON unmarshal em response sem schema validation
HAS_VAL="$(grep -rE 'jsonschema|validate|go-playground/validator' --include='*.go' --exclude-dir=vendor . 2>/dev/null | head -1 || true)"
if [ -z "$HAS_VAL" ]; then
  gate_info "$CAT" "$GATE" "LLM response sem validacao de schema - risco de valores inesperados"
fi
gate_ok "$CAT" "$GATE"
