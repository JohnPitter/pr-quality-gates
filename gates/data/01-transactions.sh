#!/usr/bin/env bash
# Data 01: Transaction boundaries
# Coverage: HEURISTIC
set -euo pipefail
PLUGIN_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
source "$PLUGIN_DIR/lib/common.sh"
GATE="transactions"; CAT="data"
gate_header "$CAT" "$GATE"

HAS_SQL="$(grep -rEl 'database/sql|sqlx|gorm' --include='*.go' --exclude-dir=vendor . 2>/dev/null | head -1 || true)"
[ -z "$HAS_SQL" ] && { gate_ok "$CAT" "$GATE" "sem SQL"; exit 0; }

# BeginTx sem defer Rollback
BEGINTX="$(grep -rEn 'BeginTx|Begin\(\)' --include='*.go' --exclude='*_test.go' --exclude-dir=vendor . 2>/dev/null || true)"
while IFS= read -r line; do
  [ -z "$line" ] && continue
  file="$(echo "$line" | cut -d: -f1)"
  if ! grep -qE 'defer.*Rollback|tx\.Rollback' "$file" 2>/dev/null; then
    gate_info "$CAT" "$GATE" "$file: BeginTx sem defer Rollback visivel"
  fi
done <<< "$BEGINTX"
gate_ok "$CAT" "$GATE"
