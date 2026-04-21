#!/usr/bin/env bash
# Reliability 08: defer Close() ausente
# Coverage: HEURISTIC - detecta Open/Create/Dial/NewReader sem defer Close
set -euo pipefail
PLUGIN_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
source "$PLUGIN_DIR/lib/common.sh"
GATE="defer-close"; CAT="reliability"
gate_header "$CAT" "$GATE"

# File handles opened without visible defer
OPENS="$(grep -rEn ':= (os\.Open|os\.Create|os\.OpenFile|net\.Dial|sql\.Open)' --include='*.go' --exclude='*_test.go' --exclude-dir=vendor . 2>/dev/null | head -20 || true)"
ISSUES=0
if [ -n "$OPENS" ]; then
  while IFS= read -r line; do
    file="$(echo "$line" | cut -d: -f1)"
    ln="$(echo "$line" | cut -d: -f2)"
    var="$(echo "$line" | grep -oE '^\s*[a-z][A-Za-z0-9_]+' | head -1 | tr -d ' ')"
    # Check if "defer $var.Close()" appears within next 5 lines
    if ! sed -n "$((ln+1)),$((ln+5))p" "$file" 2>/dev/null | grep -qE "defer\s+$var\.Close"; then
      [ "$ISSUES" = "0" ] && gate_fail "$CAT" "$GATE" "resource sem defer Close() proximo:"
      echo "  $line"
      ISSUES=$((ISSUES+1))
      [ "$ISSUES" -ge 10 ] && break
    fi
  done <<< "$OPENS"
fi
[ "$ISSUES" -gt 0 ] && exit 1
gate_ok "$CAT" "$GATE"
