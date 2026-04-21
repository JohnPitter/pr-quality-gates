#!/usr/bin/env bash
# Infrastructure 06: GitHub Actions (actionlint + pinning)
# Coverage: FULL se actionlint
set -euo pipefail
PLUGIN_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
source "$PLUGIN_DIR/lib/common.sh"
GATE="github-actions"; CAT="infrastructure"
gate_header "$CAT" "$GATE"

WF="$(find .github/workflows -type f \( -name "*.yml" -o -name "*.yaml" \) 2>/dev/null | head -1 || true)"
[ -z "$WF" ] && { gate_ok "$CAT" "$GATE" "sem workflows"; exit 0; }

# Actions sem SHA pinning (uso de @v1 ou @main)
UNPINNED="$(grep -rEn 'uses:\s+[a-z].*@(v[0-9]+|main|master|latest)' .github/workflows/ 2>/dev/null | head -10 || true)"
if [ -n "$UNPINNED" ]; then
  COUNT="$(echo "$UNPINNED" | wc -l | tr -d ' ')"
  gate_info "$CAT" "$GATE" "$COUNT action(s) sem SHA pinning:"
  echo "$UNPINNED" | sed 's/^/  /' | head -5
  echo "  sugestao: pinned-action-bot ou Dependabot version updates"
fi

# actionlint se disponivel
if command -v actionlint >/dev/null 2>&1; then
  ERR="$(actionlint 2>&1 | head -10 || true)"
  [ -n "$ERR" ] && { gate_fail "$CAT" "$GATE" "actionlint errors:"; echo "$ERR" | sed 's/^/  /'; exit 1; }
fi
gate_ok "$CAT" "$GATE"
