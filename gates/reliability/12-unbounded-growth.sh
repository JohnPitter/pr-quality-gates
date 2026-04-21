#!/usr/bin/env bash
# Reliability 12: Unbounded slice/map growth
# Coverage: HEURISTIC
set -euo pipefail
PLUGIN_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
source "$PLUGIN_DIR/lib/common.sh"
GATE="unbounded-growth"; CAT="reliability"
gate_header "$CAT" "$GATE"

# package-level mutable slices/maps that only get appended
APPEND="$(grep -rEn 'append\([A-Za-z_][A-Za-z0-9_]*,' --include='*.go' --exclude='*_test.go' --exclude-dir=vendor . 2>/dev/null | head -20 || true)"
# Detect package-level vars being appended to
GLOBALS="$(grep -rEl '^var\s+[a-z][A-Za-z]*\s+\[\]' --include='*.go' --exclude='*_test.go' --exclude-dir=vendor . 2>/dev/null || true)"
for f in $GLOBALS; do
  VNAME="$(grep -E '^var\s+[a-z][A-Za-z]*\s+\[\]' "$f" | head -1 | awk '{print $2}')"
  [ -z "$VNAME" ] && continue
  if grep -qE "append\($VNAME" "$f" && ! grep -qE "$VNAME\s*=\s*nil|$VNAME\[:0\]" "$f"; then
    gate_info "$CAT" "$GATE" "slice global \`$VNAME\` em $f so cresce - verificar se precisa limpar"
  fi
done
gate_ok "$CAT" "$GATE"
