#!/usr/bin/env bash
# Data 04: Foreign keys nas migrations
# Coverage: HEURISTIC
set -euo pipefail
PLUGIN_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
source "$PLUGIN_DIR/lib/common.sh"
GATE="foreign-keys"; CAT="data"
gate_header "$CAT" "$GATE"

MIGS=""
for dir in migrations db/migrations internal/migrations; do
  [ -d "$dir" ] && MIGS="$MIGS $dir"
done
[ -z "$MIGS" ] && { gate_ok "$CAT" "$GATE" "sem migrations"; exit 0; }

# Tables com _id columns sem FOREIGN KEY
WEAK=0
for d in $MIGS; do
  for f in "$d"/*.sql; do
    [ -f "$f" ] || continue
    if grep -qE '_id\s+(INT|BIGINT|UUID|INTEGER)' "$f" && ! grep -qiE 'FOREIGN KEY|REFERENCES' "$f"; then
      gate_info "$CAT" "$GATE" "$f: coluna *_id sem FOREIGN KEY constraint"
      WEAK=$((WEAK+1))
    fi
  done
done
gate_ok "$CAT" "$GATE"
