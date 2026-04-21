#!/usr/bin/env bash
# Data 05: Schema backwards compat (no DROP without 2-phase)
# Coverage: HEURISTIC - detecta DROP COLUMN/TABLE em migrations
set -euo pipefail
PLUGIN_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
source "$PLUGIN_DIR/lib/common.sh"
GATE="schema-compat"; CAT="data"
gate_header "$CAT" "$GATE"

for dir in migrations db/migrations internal/migrations; do
  [ -d "$dir" ] || continue
  DROPS="$(grep -rEn -i 'DROP (COLUMN|TABLE)' "$dir" 2>/dev/null | head -10 || true)"
  if [ -n "$DROPS" ]; then
    gate_info "$CAT" "$GATE" "DROP em migration (requer 2-phase: deploy nao-leitor -> wait -> drop):"
    echo "$DROPS" | sed 's/^/  /' | head -5
  fi
done
gate_ok "$CAT" "$GATE"
