#!/usr/bin/env bash
# Operational 03: Retry idempotency
# Coverage: HEURISTIC
set -euo pipefail
PLUGIN_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
source "$PLUGIN_DIR/lib/common.sh"
GATE="retry-idempotency"; CAT="operational"
gate_header "$CAT" "$GATE"

# Retry loops sem idempotency key
RETRY="$(grep -rEn 'for.*retr(y|ies)|backoff' --include='*.go' --exclude='*_test.go' --exclude-dir=vendor . 2>/dev/null | head -10 || true)"
if [ -n "$RETRY" ]; then
  # Check if idempotency key pattern exists near retry
  IK="$(grep -rE 'Idempotency|idempotent|nonce' --include='*.go' --exclude-dir=vendor . 2>/dev/null | head -1 || true)"
  [ -z "$IK" ] && gate_info "$CAT" "$GATE" "retry detectado sem idempotency key - risco de duplicacao"
fi
gate_ok "$CAT" "$GATE"
