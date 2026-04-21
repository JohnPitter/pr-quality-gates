#!/usr/bin/env bash
# Git 05: No large binaries in git history
# Coverage: FULL
set -euo pipefail
PLUGIN_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
source "$PLUGIN_DIR/lib/common.sh"
GATE="large-files"; CAT="git-hygiene"
MAX_MB="$(jq -r '.git_max_file_mb // 1' "$PLUGIN_DIR/config/thresholds.json")"
MAX=$((MAX_MB * 1024 * 1024))
gate_header "$CAT" "$GATE" "max=${MAX_MB}MB por arquivo"

[ -d .git ] || { gate_ok "$CAT" "$GATE" "sem git"; exit 0; }

# Files in HEAD tree > MAX
BIG="$(git ls-tree -r HEAD --long 2>/dev/null | awk -v m="$MAX" '$4+0 > m {printf "  %s (%.1f MB)\n", $5, $4/1024/1024}' | head -10 || true)"
if [ -n "$BIG" ]; then
  gate_fail "$CAT" "$GATE" "arquivos grandes no git:"
  echo "$BIG"
  echo "  considerar: git-lfs ou .gitignore"
  exit 1
fi
gate_ok "$CAT" "$GATE"
