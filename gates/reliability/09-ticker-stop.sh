#!/usr/bin/env bash
# Reliability 09: time.Ticker/Timer sem Stop()
# Coverage: HEURISTIC
set -euo pipefail
PLUGIN_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
source "$PLUGIN_DIR/lib/common.sh"
GATE="ticker-stop"; CAT="reliability"
gate_header "$CAT" "$GATE"

TICKERS="$(grep -rEn ':= time\.NewTicker|:= time\.NewTimer' --include='*.go' --exclude='*_test.go' --exclude-dir=vendor . 2>/dev/null || true)"
ISSUES=0
while IFS= read -r line; do
  [ -z "$line" ] && continue
  file="$(echo "$line" | cut -d: -f1)"
  # Extract var from the code portion, not from the `file:line:` prefix.
  content="$(echo "$line" | cut -d: -f3- | sed 's/^[[:space:]]*//')"
  var="$(echo "$content" | grep -oE '^[a-z][A-Za-z0-9_]*' | head -1)"
  [ -z "$var" ] && continue
  if ! grep -qE "defer\s+$var\.Stop\(\)|$var\.Stop\(\)" "$file" 2>/dev/null; then
    [ "$ISSUES" = "0" ] && gate_fail "$CAT" "$GATE" "ticker/timer sem Stop():"
    echo "  $line"
    ISSUES=$((ISSUES+1))
  fi
done <<< "$TICKERS"
[ "$ISSUES" -gt 0 ] && exit 1
gate_ok "$CAT" "$GATE"
