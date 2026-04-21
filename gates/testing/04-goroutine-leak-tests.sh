#!/usr/bin/env bash
# Testing 04: Goroutine leak detection em testes
# Coverage: HEURISTIC
set -euo pipefail
PLUGIN_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
source "$PLUGIN_DIR/lib/common.sh"
GATE="goroutine-leak-tests"; CAT="testing"
gate_header "$CAT" "$GATE"

HAS_GL="$(grep -rE 'goleak\.|go.uber.org/goleak' --include='*_test.go' --exclude-dir=vendor . 2>/dev/null | head -1 || true)"
HAS_GR="$(grep -rE '^\s*go (func|[a-zA-Z])' --include='*.go' --exclude='*_test.go' --exclude-dir=vendor . 2>/dev/null | head -1 || true)"
if [ -n "$HAS_GR" ] && [ -z "$HAS_GL" ]; then
  gate_info "$CAT" "$GATE" "goroutines no codigo mas sem goleak.VerifyNone em testes"
fi
gate_ok "$CAT" "$GATE"
