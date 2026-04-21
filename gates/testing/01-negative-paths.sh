#!/usr/bin/env bash
# Testing 01: Negative path coverage
# Coverage: HEURISTIC - razao testes com "error"/"fail" vs testes totais
set -euo pipefail
PLUGIN_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
source "$PLUGIN_DIR/lib/common.sh"
GATE="negative-paths"; CAT="testing"
gate_header "$CAT" "$GATE"

TOTAL="$(grep -rEc '^func Test[A-Z]' --include='*_test.go' --exclude-dir=vendor . 2>/dev/null | awk -F: '{s+=$2} END{print s+0}')"
[ "$TOTAL" = "0" ] && { gate_info "$CAT" "$GATE" "sem testes"; exit 0; }

NEG="$(grep -rEc '^func Test[A-Z].*(Error|Fail|Invalid|Nil|Empty|Missing|Timeout|Cancel)' --include='*_test.go' --exclude-dir=vendor . 2>/dev/null | awk -F: '{s+=$2} END{print s+0}')"
RATIO=$(awk -v n="$NEG" -v t="$TOTAL" 'BEGIN{if(t>0) printf "%.0f", n*100/t; else print 0}')

if [ "$RATIO" -lt 20 ]; then
  gate_info "$CAT" "$GATE" "so $RATIO% dos testes sao negative path (ideal: >=30%): $NEG/$TOTAL"
fi
gate_ok "$CAT" "$GATE"
