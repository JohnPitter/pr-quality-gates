#!/usr/bin/env bash
# Data 03: SQL injection patterns (string concat em queries)
# Coverage: HEURISTIC (complementa gate SAST)
set -euo pipefail
PLUGIN_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
source "$PLUGIN_DIR/lib/common.sh"
GATE="sql-injection"; CAT="data"
gate_header "$CAT" "$GATE"

# String concat em Query/Exec
BAD="$(grep -rEn '(Query|Exec)\(.*\+' --include='*.go' --exclude='*_test.go' --exclude-dir=vendor . 2>/dev/null | head -10 || true)"
SPRINTF="$(grep -rEn '(Query|Exec)\(fmt\.Sprintf' --include='*.go' --exclude='*_test.go' --exclude-dir=vendor . 2>/dev/null | head -10 || true)"

FAIL=0
if [ -n "$BAD" ]; then
  gate_fail "$CAT" "$GATE" "SQL com concat de string:"
  echo "$BAD" | sed 's/^/  /' | head -5
  FAIL=1
fi
if [ -n "$SPRINTF" ]; then
  [ "$FAIL" = "0" ] && gate_fail "$CAT" "$GATE" "SQL com Sprintf:"
  echo "$SPRINTF" | sed 's/^/  /' | head -5
  FAIL=1
fi
[ "$FAIL" = "1" ] && { echo "  usar prepared statements com $1, $2..."; exit 1; }
gate_ok "$CAT" "$GATE"
