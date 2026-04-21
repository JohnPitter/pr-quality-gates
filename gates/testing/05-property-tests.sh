#!/usr/bin/env bash
# Testing 05: Property-based tests
# Coverage: HEURISTIC
set -euo pipefail
PLUGIN_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
source "$PLUGIN_DIR/lib/common.sh"
GATE="property-tests"; CAT="testing"
gate_header "$CAT" "$GATE"

HAS_PROP="$(grep -rE 'gopter|testing/quick|rapid\.Check' --include='*_test.go' --exclude-dir=vendor . 2>/dev/null | head -1 || true)"
[ -z "$HAS_PROP" ] && gate_info "$CAT" "$GATE" "nenhum property-based test (gopter, rapid, testing/quick)"
gate_ok "$CAT" "$GATE"
