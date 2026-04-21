#!/usr/bin/env bash
# AI/ML 02: LLM API timeout
# Coverage: HEURISTIC
set -euo pipefail
PLUGIN_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
source "$PLUGIN_DIR/lib/common.sh"
GATE="llm-timeout"; CAT="ai-ml"
gate_header "$CAT" "$GATE"

HAS_LLM="$(grep -rE 'openai|anthropic|claude|gemini' --include='*.go' --exclude-dir=vendor -i . 2>/dev/null | head -1 || true)"
[ -z "$HAS_LLM" ] && { gate_ok "$CAT" "$GATE" "sem LLM"; exit 0; }

# Files com LLM call mas sem WithTimeout/context.WithDeadline
FILES="$(grep -rlE 'openai|anthropic|claude|gemini' --include='*.go' --exclude-dir=vendor -i . 2>/dev/null || true)"
BAD=0
for f in $FILES; do
  if ! grep -qE 'WithTimeout|WithDeadline|Timeout:' "$f" 2>/dev/null; then
    [ "$BAD" = "0" ] && gate_fail "$CAT" "$GATE" "LLM calls sem timeout visivel:"
    echo "  $f"
    BAD=$((BAD+1))
  fi
done
[ "$BAD" -gt 0 ] && exit 1
gate_ok "$CAT" "$GATE"
