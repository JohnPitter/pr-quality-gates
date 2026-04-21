#!/usr/bin/env bash
# Git 03: Signed commits
# Coverage: FULL
set -euo pipefail
PLUGIN_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
source "$PLUGIN_DIR/lib/common.sh"
GATE="signed-commits"; CAT="git-hygiene"
gate_header "$CAT" "$GATE"

[ -d .git ] || { gate_ok "$CAT" "$GATE" "sem git"; exit 0; }
BASE="${BASE_REF:-origin/main}"
git rev-parse "$BASE" >/dev/null 2>&1 || BASE="HEAD~5"

UNSIGNED="$(git log "$BASE"..HEAD --format='%h %G? %s' 2>/dev/null | grep -E '^\S+ [N?] ' | head -5 || true)"
if [ -n "$UNSIGNED" ]; then
  COUNT="$(echo "$UNSIGNED" | wc -l | tr -d ' ')"
  gate_info "$CAT" "$GATE" "$COUNT commit(s) nao assinado(s):"
  echo "$UNSIGNED" | sed 's/^/  /'
  echo "  git config commit.gpgsign true; git config user.signingkey <KEY>"
fi
gate_ok "$CAT" "$GATE"
