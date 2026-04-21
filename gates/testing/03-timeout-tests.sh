#!/usr/bin/env bash
# Testing 03: Timeout scenario tests
# Coverage: HEURISTIC
set -euo pipefail
PLUGIN_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
source "$PLUGIN_DIR/lib/common.sh"
GATE="timeout-tests"; CAT="testing"
gate_header "$CAT" "$GATE"

HAS_TIMEOUT="$(grep -rE '^func Test[A-Z].*(Timeout|Deadline|Cancel)' --include='*_test.go' --exclude-dir=vendor . 2>/dev/null | head -1 || true)"
HAS_IO="$(grep -rEl 'http\.Client|sql\.|net\.Dial' --include='*.go' --exclude='*_test.go' --exclude-dir=vendor . 2>/dev/null | head -1 || true)"
if [ -n "$HAS_IO" ] && [ -z "$HAS_TIMEOUT" ]; then
  gate_info "$CAT" "$GATE" "codigo com I/O mas sem teste de timeout/cancellation"
fi
gate_ok "$CAT" "$GATE"
