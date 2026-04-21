#!/usr/bin/env bash
# Documentation 05: Markdown link health
# Coverage: HEURISTIC - links obviamente quebrados
set -euo pipefail
PLUGIN_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
source "$PLUGIN_DIR/lib/common.sh"
GATE="link-health"; CAT="documentation"
gate_header "$CAT" "$GATE"

# Links locais (relativos) que apontam para arquivos nao-existentes
BROKEN=0
for md in $(find . -name "*.md" -not -path '*/vendor/*' -not -path '*/node_modules/*' 2>/dev/null | head -20); do
  dir="$(dirname "$md")"
  while IFS= read -r link; do
    [ -z "$link" ] && continue
    # Ignore http(s) and anchors
    [[ "$link" =~ ^https?:// ]] && continue
    [[ "$link" =~ ^# ]] && continue
    target="$dir/$(echo "$link" | sed 's/#.*//')"
    if [ ! -e "$target" ]; then
      [ "$BROKEN" = "0" ] && gate_info "$CAT" "$GATE" "links quebrados (relativos):"
      echo "  $md -> $link"
      BROKEN=$((BROKEN+1))
      [ "$BROKEN" -ge 10 ] && break 2
    fi
  done < <(grep -oE '\]\([^)]+\)' "$md" 2>/dev/null | sed 's/](//;s/)$//' || true)
done
gate_ok "$CAT" "$GATE"
