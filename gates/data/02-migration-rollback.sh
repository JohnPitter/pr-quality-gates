#!/usr/bin/env bash
# Data 02: Migration rollback exists
# Coverage: HEURISTIC
set -euo pipefail
PLUGIN_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
source "$PLUGIN_DIR/lib/common.sh"
GATE="migration-rollback"; CAT="data"
gate_header "$CAT" "$GATE"

for dir in migrations db/migrations internal/migrations; do
  [ -d "$dir" ] || continue
  UP_FILES="$(find "$dir" -name "*.up.sql" -o -name "*_up.sql" 2>/dev/null || true)"
  DN_FILES="$(find "$dir" -name "*.down.sql" -o -name "*_down.sql" 2>/dev/null || true)"
  UN="$(echo "$UP_FILES" | grep -c . || echo 0)"
  DN="$(echo "$DN_FILES" | grep -c . || echo 0)"
  if [ "$UN" -gt 0 ] && [ "$DN" -lt "$UN" ]; then
    gate_fail "$CAT" "$GATE" "$dir: $UN ups mas apenas $DN downs"
    exit 1
  fi
done
gate_ok "$CAT" "$GATE"
