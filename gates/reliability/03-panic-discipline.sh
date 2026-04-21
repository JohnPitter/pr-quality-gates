#!/usr/bin/env bash
# Reliability 03: Panic discipline
# Coverage: FULL - panic fora de main/init = error
set -euo pipefail
PLUGIN_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
source "$PLUGIN_DIR/lib/common.sh"
GATE="panic-discipline"; CAT="reliability"
gate_header "$CAT" "$GATE"

# panic() em codigo nao-test, nao-main
BAD="$(grep -rn '\bpanic(' --include='*.go' --exclude='*_test.go' --exclude-dir=vendor . 2>/dev/null | \
  grep -v -E '/main\.go:|must[A-Z]|MustCompile|init\(\)' | head -10 || true)"
if [ -n "$BAD" ]; then
  COUNT="$(echo "$BAD" | wc -l | tr -d ' ')"
  gate_fail "$CAT" "$GATE" "$COUNT panic() em producao (retornar error):"
  echo "$BAD" | head -10 | sed 's/^/  /'
  exit 1
fi
gate_ok "$CAT" "$GATE"
