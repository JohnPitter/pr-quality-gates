#!/usr/bin/env bash
# Performance 08: sync.Pool opportunities
# Coverage: HEURISTIC - identifica hot paths que poderiam usar sync.Pool
set -euo pipefail
PLUGIN_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
source "$PLUGIN_DIR/lib/common.sh"
GATE="sync-pool"; CAT="performance"
gate_header "$CAT" "$GATE"

# Large struct creation in hot functions (funcoes com "handler" ou benchmark)
CAND="$(grep -rn -B 1 'make(\[\]byte' --include='*.go' --exclude='*_test.go' --exclude-dir=vendor . 2>/dev/null | \
  grep -E 'Handler|Process|Serve' -B 5 2>/dev/null | grep 'make(\[\]byte' | head -3 || true)"
[ -n "$CAND" ] && gate_info "$CAT" "$GATE" "buffers []byte em hot paths - considerar sync.Pool"

gate_ok "$CAT" "$GATE"
