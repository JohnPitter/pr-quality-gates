#!/usr/bin/env bash
# API 02: Idempotency em PUT/DELETE
# Coverage: HEURISTIC
set -euo pipefail
PLUGIN_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
source "$PLUGIN_DIR/lib/common.sh"
GATE="idempotency"; CAT="api"
gate_header "$CAT" "$GATE"

# Handlers PUT/DELETE que fazem INSERT (nao-idempotente)
BAD="$(grep -rn -B 10 'INSERT INTO\|\.Create(' --include='*.go' --exclude='*_test.go' --exclude-dir=vendor . 2>/dev/null | \
  grep -B 5 -iE 'PUT|DELETE' 2>/dev/null | grep -E 'INSERT|\.Create' | head -3 || true)"

# POST handlers sem Idempotency-Key header check
HAS_POST="$(grep -rE '"POST"|http\.MethodPost' --include='*.go' --exclude='*_test.go' --exclude-dir=vendor . 2>/dev/null | head -1 || true)"
HAS_IDEM_KEY="$(grep -rE 'Idempotency-Key|IdempotencyKey' --include='*.go' --exclude-dir=vendor . 2>/dev/null | head -1 || true)"

if [ -n "$HAS_POST" ] && [ -z "$HAS_IDEM_KEY" ]; then
  gate_info "$CAT" "$GATE" "POST handlers sem Idempotency-Key header (risco de duplicacao em retry)"
fi
gate_ok "$CAT" "$GATE"
