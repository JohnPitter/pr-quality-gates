#!/usr/bin/env bash
# Git 02: PR size limit
# Coverage: FULL
set -euo pipefail
PLUGIN_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
source "$PLUGIN_DIR/lib/common.sh"
GATE="pr-size"; CAT="git-hygiene"
MAX="$(threshold_get pr_max_lines)"
[ -z "$MAX" ] && MAX=1000
gate_header "$CAT" "$GATE" "max LoC/PR=$MAX"

[ -d .git ] || { gate_ok "$CAT" "$GATE" "sem git"; exit 0; }

BASE="${BASE_REF:-origin/main}"
git rev-parse "$BASE" >/dev/null 2>&1 || { gate_ok "$CAT" "$GATE" "sem ref $BASE"; exit 0; }

STATS="$(git diff --shortstat "$BASE"...HEAD -- ':!*.lock' ':!vendor/' ':!go.sum' ':!package-lock.json' 2>/dev/null || true)"
[ -z "$STATS" ] && { gate_ok "$CAT" "$GATE" "sem diff"; exit 0; }

ADDED="$(echo "$STATS" | grep -oE '[0-9]+ insertions' | grep -oE '[0-9]+' | head -1)"
DELETED="$(echo "$STATS" | grep -oE '[0-9]+ deletions' | grep -oE '[0-9]+' | head -1)"
ADDED="${ADDED:-0}"; DELETED="${DELETED:-0}"
TOTAL=$((ADDED + DELETED))

if [ "$TOTAL" -gt "$MAX" ]; then
  gate_fail "$CAT" "$GATE" "PR muito grande: $TOTAL LoC (+$ADDED -$DELETED), max $MAX"
  echo "  sugestao: dividir em PRs menores <$MAX LoC cada"
  exit 1
fi
gate_ok "$CAT" "$GATE" "$TOTAL LoC (+$ADDED -$DELETED)"
