#!/usr/bin/env bash
# Git 06: Branch naming convention
# Coverage: HEURISTIC
set -euo pipefail
PLUGIN_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
source "$PLUGIN_DIR/lib/common.sh"
GATE="branch-naming"; CAT="git-hygiene"
gate_header "$CAT" "$GATE"

[ -d .git ] || { gate_ok "$CAT" "$GATE" "sem git"; exit 0; }
BRANCH="$(git branch --show-current 2>/dev/null || true)"
[ -z "$BRANCH" ] && { gate_ok "$CAT" "$GATE" "detached"; exit 0; }
[ "$BRANCH" = "main" ] || [ "$BRANCH" = "master" ] || [ "$BRANCH" = "develop" ] && { gate_ok "$CAT" "$GATE"; exit 0; }

# Convencao: tipo/descricao-kebab (feat/add-login, fix/null-check, chore/deps)
PATTERN='^(feat|fix|chore|docs|refactor|test|ci|perf|style)/[a-z0-9-]+$'
if ! echo "$BRANCH" | grep -qE "$PATTERN"; then
  gate_info "$CAT" "$GATE" "branch '$BRANCH' fora do padrao <tipo>/<kebab-desc>"
fi
gate_ok "$CAT" "$GATE"
