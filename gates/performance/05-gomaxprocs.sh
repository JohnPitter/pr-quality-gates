#!/usr/bin/env bash
# Performance 05: GOMAXPROCS / NumCPU awareness
# Coverage: HEURISTIC
set -euo pipefail
PLUGIN_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
source "$PLUGIN_DIR/lib/common.sh"
GATE="gomaxprocs"; CAT="performance"
gate_header "$CAT" "$GATE"

# Hardcoded GOMAXPROCS = anti-pattern em 99% dos casos
BAD="$(grep -rn 'runtime\.GOMAXPROCS(' --include='*.go' --exclude='*_test.go' --exclude-dir=vendor . 2>/dev/null || true)"
if [ -n "$BAD" ]; then
  gate_info "$CAT" "$GATE" "GOMAXPROCS alterado (raro ser correto):"
  echo "$BAD" | sed 's/^/  /' | head -5
  echo "  em container: usar uber-go/automaxprocs"
fi

# Hardcoded worker pool sizes (anti-pattern vs runtime.NumCPU())
HARDCODED="$(grep -rn -E 'make\(chan .*,\s*[0-9]{2,}\)' --include='*.go' --exclude='*_test.go' --exclude-dir=vendor . 2>/dev/null | head -3 || true)"
[ -n "$HARDCODED" ] && gate_info "$CAT" "$GATE" "channels com buffer size hardcoded - considerar NumCPU()"

gate_ok "$CAT" "$GATE"
