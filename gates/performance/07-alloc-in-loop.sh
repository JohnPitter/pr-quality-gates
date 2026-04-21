#!/usr/bin/env bash
# Performance 07: Alocacoes desnecessarias em loops
# Coverage: HEURISTIC
set -euo pipefail
PLUGIN_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
source "$PLUGIN_DIR/lib/common.sh"
GATE="alloc-in-loop"; CAT="performance"
gate_header "$CAT" "$GATE"

# append without cap = multiple reallocs
NOCAP="$(grep -rn -B 3 'append(' --include='*.go' --exclude='*_test.go' --exclude-dir=vendor . 2>/dev/null | \
  grep -B 2 -E 'for |range ' 2>/dev/null | grep 'append(' | head -5 || true)"
[ -n "$NOCAP" ] && gate_info "$CAT" "$GATE" "append em loop - pre-alocar com make([]T, 0, n)"

# fmt.Sprintf in loops
SPRINTF="$(grep -rn -B 3 'fmt\.Sprintf' --include='*.go' --exclude='*_test.go' --exclude-dir=vendor . 2>/dev/null | \
  grep -B 2 -E 'for |range ' 2>/dev/null | grep 'Sprintf' | head -3 || true)"
[ -n "$SPRINTF" ] && gate_info "$CAT" "$GATE" "fmt.Sprintf em loop - usar strings.Builder"

gate_ok "$CAT" "$GATE"
