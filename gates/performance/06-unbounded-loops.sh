#!/usr/bin/env bash
# Performance 06: Loops O(n^2) / N+1 patterns
# Coverage: HEURISTIC
set -euo pipefail
PLUGIN_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
source "$PLUGIN_DIR/lib/common.sh"
GATE="unbounded-loops"; CAT="performance"
gate_header "$CAT" "$GATE"

# DB queries in loops (N+1)
NQ="$(grep -rn -B 3 -E 'Query|QueryRow|Exec|Find|Scan' --include='*.go' --exclude='*_test.go' --exclude-dir=vendor . 2>/dev/null | \
  grep -B 2 -E 'for |range ' 2>/dev/null | grep -E 'Query|QueryRow|Exec' | head -5 || true)"
if [ -n "$NQ" ]; then
  gate_info "$CAT" "$GATE" "possivel N+1 (query em loop):"
  echo "$NQ" | sed 's/^/  /' | head -5
  echo "  sugestao: batch query ou JOIN"
fi

# HTTP calls in loops
NH="$(grep -rn -B 3 -E 'http\.(Get|Post|Do)' --include='*.go' --exclude='*_test.go' --exclude-dir=vendor . 2>/dev/null | \
  grep -B 2 -E 'for |range ' 2>/dev/null | grep 'http\.' | head -3 || true)"
[ -n "$NH" ] && gate_info "$CAT" "$GATE" "HTTP calls em loop - considerar concurrency ou batch"

gate_ok "$CAT" "$GATE"
