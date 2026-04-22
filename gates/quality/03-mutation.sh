#!/usr/bin/env bash
# Quality 03: Mutacao de testes
# Coverage: FULL (gremlins)
set -euo pipefail
PLUGIN_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
source "$PLUGIN_DIR/lib/common.sh"
GATE="mutation"; CAT="quality"
MIN="$(threshold_get mutation_min)"
MIN_PCT="$(awk -v m="$MIN" 'BEGIN{printf "%.2f", m*100}')"
gate_header "$CAT" "$GATE" "threshold=${MIN_PCT}%"
command -v gremlins >/dev/null 2>&1 || go install github.com/go-gremlins/gremlins/cmd/gremlins@latest
OUT="$(gremlins unleash --output json ./... 2>/dev/null || true)"
SCORE="$(echo "$OUT" | jq -r '.results.mutationScore // 0' 2>/dev/null || echo 0)"
SCORE_PCT="$(awk -v s="$SCORE" 'BEGIN{printf "%.2f", s*100}')"
if awk -v s="$SCORE_PCT" -v m="$MIN_PCT" 'BEGIN{exit !(s<m)}'; then
  gate_fail "$CAT" "$GATE" "score ${SCORE_PCT}% < ${MIN_PCT}%"; exit 1
fi
gate_ok "$CAT" "$GATE" "${SCORE_PCT}% >= ${MIN_PCT}%"
