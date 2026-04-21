#!/usr/bin/env bash
# Reliability 07: Ineffective assignments (errors ignorados)
# Coverage: FULL (errcheck + ineffassign)
set -euo pipefail
PLUGIN_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
source "$PLUGIN_DIR/lib/common.sh"
GATE="error-check"; CAT="reliability"
gate_header "$CAT" "$GATE"

command -v errcheck >/dev/null 2>&1 || go install github.com/kisielk/errcheck@latest
command -v ineffassign >/dev/null 2>&1 || go install github.com/gordonklaus/ineffassign@latest

EC="$(errcheck ./... 2>&1 | grep -E '\.go:' | head -20 || true)"
IA="$(ineffassign ./... 2>&1 | grep -E '\.go:' | head -10 || true)"

FAIL=0
if [ -n "$EC" ]; then
  COUNT="$(echo "$EC" | wc -l | tr -d ' ')"
  gate_fail "$CAT" "$GATE" "$COUNT error(s) nao checado(s):"
  echo "$EC" | head -10 | sed 's/^/  /'
  FAIL=1
fi
if [ -n "$IA" ]; then
  echo "  ineffassign adicionais:"
  echo "$IA" | sed 's/^/    /'
  FAIL=1
fi
[ "$FAIL" = "1" ] && exit 1
gate_ok "$CAT" "$GATE"
