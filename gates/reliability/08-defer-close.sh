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
    # Extract var from code portion (after `file:line:` prefix); strip leading
    # whitespace then take first identifier. Without this, grep's column prefix
    # breaks the `^\s*[a-z]` regex and silently yields empty var.
    content="$(echo "$line" | cut -d: -f3- | sed 's/^[[:space:]]*//')"
    var="$(echo "$content" | grep -oE '^[a-z][A-Za-z0-9_]*' | head -1)"
    [ -z "$var" ] && continue
    # Allow "// no-close: ..." trailing comment to mark intentional process-
    # lifetime resources (e.g. log file reassigned to os.Stderr).
    echo "$content" | grep -qE '// *no-close' && continue
    # Check if "defer $var.Close()" appears within next 5 lines
    if ! sed -n "$((ln+1)),$((ln+5))p" "$file" 2>/dev/null | grep -qE "defer[[:space:]]+$var\.Close"; then
      [ "$ISSUES" = "0" ] && gate_fail "$CAT" "$GATE" "resource sem defer Close() proximo:"
      echo "  $line"
      ISSUES=$((ISSUES+1))
      [ "$ISSUES" -ge 10 ] && break
    fi
  done <<< "$OPENS"
fi
[ "$ISSUES" -gt 0 ] && exit 1
gate_ok "$CAT" "$GATE"
