#!/usr/bin/env bash
# Release 01: CHANGELOG.md updated in PR
# Coverage: FULL (git diff)
set -euo pipefail
PLUGIN_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
source "$PLUGIN_DIR/lib/common.sh"
GATE="changelog"; CAT="release"
gate_header "$CAT" "$GATE"

[ -d .git ] || { gate_info "$CAT" "$GATE" "sem git"; exit 0; }
[ -f CHANGELOG.md ] || { gate_info "$CAT" "$GATE" "sem CHANGELOG.md"; exit 0; }

BASE="${BASE_REF:-origin/main}"
git rev-parse "$BASE" >/dev/null 2>&1 || { gate_info "$CAT" "$GATE" "ref $BASE inexistente"; exit 0; }

CHANGED="$(git diff --name-only "$BASE"...HEAD 2>/dev/null | grep -vE '^(CHANGELOG\.md|\.github/|docs/)' | head -5 || true)"
[ -z "$CHANGED" ] && { gate_ok "$CAT" "$GATE" "sem mudancas de codigo"; exit 0; }

CL_DIFF="$(git diff --name-only "$BASE"...HEAD 2>/dev/null | grep -x 'CHANGELOG.md' || true)"
if [ -z "$CL_DIFF" ]; then
  gate_fail "$CAT" "$GATE" "codigo mudou mas CHANGELOG.md nao foi atualizado"
  exit 1
fi
gate_ok "$CAT" "$GATE"
