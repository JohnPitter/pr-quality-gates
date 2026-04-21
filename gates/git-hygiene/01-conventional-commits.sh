#!/usr/bin/env bash
# Git 01: Conventional commits format
# Coverage: FULL
set -euo pipefail
PLUGIN_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
source "$PLUGIN_DIR/lib/common.sh"
GATE="conventional-commits"; CAT="git-hygiene"
gate_header "$CAT" "$GATE"

[ -d .git ] || { gate_ok "$CAT" "$GATE" "sem git"; exit 0; }

BASE="${BASE_REF:-origin/main}"
if ! git rev-parse "$BASE" >/dev/null 2>&1; then
  BASE="HEAD~10"
fi

# Check last N commits follow conventional format
PATTERN='^(feat|fix|docs|style|refactor|perf|test|build|ci|chore|revert)(\([a-z0-9-]+\))?(!)?:\s+.+'
BAD="$(git log "$BASE"..HEAD --format='%h %s' 2>/dev/null | grep -vE "$PATTERN" | head -5 || true)"

if [ -n "$BAD" ]; then
  COUNT="$(echo "$BAD" | wc -l | tr -d ' ')"
  gate_info "$CAT" "$GATE" "$COUNT commit(s) sem Conventional Commits format:"
  echo "$BAD" | sed 's/^/  /'
  echo "  formato: <type>(<scope>): <subject> - ex: feat(auth): add OAuth2"
fi
gate_ok "$CAT" "$GATE"
