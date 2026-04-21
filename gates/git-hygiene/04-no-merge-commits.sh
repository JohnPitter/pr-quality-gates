#!/usr/bin/env bash
# Git 04: No merge commits on main (rebase-only)
# Coverage: FULL
set -euo pipefail
PLUGIN_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
source "$PLUGIN_DIR/lib/common.sh"
GATE="no-merge-commits"; CAT="git-hygiene"
gate_header "$CAT" "$GATE"

[ -d .git ] || { gate_ok "$CAT" "$GATE" "sem git"; exit 0; }
BASE="${BASE_REF:-origin/main}"
git rev-parse "$BASE" >/dev/null 2>&1 || { gate_ok "$CAT" "$GATE" "sem ref"; exit 0; }

MERGES="$(git log "$BASE"..HEAD --merges --format='%h %s' 2>/dev/null | head -3 || true)"
if [ -n "$MERGES" ]; then
  COUNT="$(echo "$MERGES" | wc -l | tr -d ' ')"
  gate_fail "$CAT" "$GATE" "$COUNT merge commit(s) (preferir rebase):"
  echo "$MERGES" | sed 's/^/  /'
  exit 1
fi
gate_ok "$CAT" "$GATE"
