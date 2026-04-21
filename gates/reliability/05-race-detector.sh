#!/usr/bin/env bash
# Reliability 05: Race detector obrigatorio
# Coverage: FULL (go test -race)
set -euo pipefail
PLUGIN_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
source "$PLUGIN_DIR/lib/common.sh"
GATE="race-detector"; CAT="reliability"
gate_header "$CAT" "$GATE"

HAS_TESTS="$(find . -name "*_test.go" -not -path './vendor/*' 2>/dev/null | head -1)"
[ -z "$HAS_TESTS" ] && { gate_info "$CAT" "$GATE" "sem testes"; exit 0; }

OUT="$(go test -race -short ./... 2>&1 || true)"
if echo "$OUT" | grep -qE 'DATA RACE|WARNING: DATA RACE'; then
  gate_fail "$CAT" "$GATE" "data race detectada"
  echo "$OUT" | grep -A 3 'DATA RACE' | head -30
  exit 1
fi
gate_ok "$CAT" "$GATE"
