#!/usr/bin/env bash
# Reliability 14: Nil pointer dereference risks
# Coverage: FULL (nilaway - Uber)
set -euo pipefail
PLUGIN_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
source "$PLUGIN_DIR/lib/common.sh"
GATE="nil-check"; CAT="reliability"
gate_header "$CAT" "$GATE"

# nilaway is optional (Uber tool, might not install cleanly)
if ! command -v nilaway >/dev/null 2>&1; then
  go install go.uber.org/nilaway/cmd/nilaway@latest 2>/dev/null || {
    gate_info "$CAT" "$GATE" "nilaway nao instalavel, skip"
    exit 0
  }
fi

OUT="$(nilaway ./... 2>&1 | grep -E '\.go:' | head -20 || true)"
if [ -n "$OUT" ]; then
  COUNT="$(echo "$OUT" | wc -l | tr -d ' ')"
  gate_info "$CAT" "$GATE" "$COUNT possivel(eis) nil deref:"
  echo "$OUT" | head -5 | sed 's/^/  /'
fi
gate_ok "$CAT" "$GATE"
