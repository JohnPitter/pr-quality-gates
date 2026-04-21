#!/usr/bin/env bash
# Reliability 02: Context propagation (ctx como primeiro param)
# Coverage: FULL (contextcheck)
set -euo pipefail
PLUGIN_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
source "$PLUGIN_DIR/lib/common.sh"
GATE="context-propagation"; CAT="reliability"
gate_header "$CAT" "$GATE"

command -v contextcheck >/dev/null 2>&1 || go install github.com/kkHAIKE/contextcheck/cmd/contextcheck@latest
OUT="$(contextcheck ./... 2>&1 | grep -E '\.go:' | head -20 || true)"
if [ -n "$OUT" ]; then
  COUNT="$(echo "$OUT" | wc -l | tr -d ' ')"
  gate_fail "$CAT" "$GATE" "$COUNT violacao(oes) de ctx propagation:"
  echo "$OUT" | head -10 | sed 's/^/  /'
  exit 1
fi

# Also check: context.Background() outside main/init/test
BG="$(grep -rn 'context\.Background()' --include='*.go' --exclude='*_test.go' --exclude-dir=vendor . 2>/dev/null | \
  grep -v 'main\.go' | head -5 || true)"
if [ -n "$BG" ]; then
  gate_info "$CAT" "$GATE" "context.Background() fora de main (deve ser propagado):"
  echo "$BG" | sed 's/^/  /' | head -5
fi
gate_ok "$CAT" "$GATE"
