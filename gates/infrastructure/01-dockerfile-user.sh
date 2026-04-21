#!/usr/bin/env bash
# Infrastructure 01: Dockerfile USER non-root
# Coverage: FULL
set -euo pipefail
PLUGIN_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
source "$PLUGIN_DIR/lib/common.sh"
GATE="dockerfile-user"; CAT="infrastructure"
gate_header "$CAT" "$GATE"

DFS="$(find . -maxdepth 3 -type f \( -name "Dockerfile" -o -name "Dockerfile.*" -o -name "*.Dockerfile" \) -not -path '*/vendor/*' 2>/dev/null || true)"
[ -z "$DFS" ] && { gate_ok "$CAT" "$GATE" "sem Dockerfile"; exit 0; }

FAIL=0
for df in $DFS; do
  if ! grep -qE '^USER\s+[^0r]' "$df" && ! grep -qE '^USER\s+nonroot' "$df" && ! grep -qE '^USER\s+[1-9][0-9]+' "$df"; then
    [ "$FAIL" = "0" ] && gate_fail "$CAT" "$GATE" "Dockerfile rodando como root:"
    echo "  $df"
    FAIL=1
  fi
done
[ "$FAIL" = "1" ] && { echo "  adicionar: USER nonroot ou USER 65532"; exit 1; }
gate_ok "$CAT" "$GATE"
