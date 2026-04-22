#!/usr/bin/env bash
# Performance 03: Struct layout / field alignment
# Coverage: FULL (fieldalignment tool)
set -euo pipefail
PLUGIN_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
source "$PLUGIN_DIR/lib/common.sh"
GATE="struct-layout"; CAT="performance"
gate_header "$CAT" "$GATE"

command -v fieldalignment >/dev/null 2>&1 || go install golang.org/x/tools/go/analysis/passes/fieldalignment/cmd/fieldalignment@latest
OUT="$(fieldalignment ./... 2>&1 || true)"
# Desktop apps with many JSON-serialized DTOs can't always reorder fields for
# alignment (frontend expects stable shape). Override via
# .pr-quality-gates.json -> struct_layout_max (default 0).
LIMIT="$(threshold_get struct_layout_max)"
[ -z "$LIMIT" ] && LIMIT=0
if [ -n "$OUT" ] && echo "$OUT" | grep -qE 'could be|pointer bytes could be'; then
  COUNT="$(echo "$OUT" | grep -cE 'could be|pointer bytes could be' || echo 0)"
  if [ "$COUNT" -gt "$LIMIT" ]; then
    gate_fail "$CAT" "$GATE" "$COUNT struct(s) com alignment subotimo (max=$LIMIT)"
    echo "$OUT" | head -10 | sed 's/^/  /'
    echo "  autofix: fieldalignment -fix ./..."
    exit 1
  fi
fi
gate_ok "$CAT" "$GATE"
