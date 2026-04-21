#!/usr/bin/env bash
# Reliability 01: Error context wrap (fmt.Errorf com %w)
# Coverage: FULL (errorlint)
set -euo pipefail
PLUGIN_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
source "$PLUGIN_DIR/lib/common.sh"
GATE="error-wrap"; CAT="reliability"
gate_header "$CAT" "$GATE"

command -v errorlint >/dev/null 2>&1 || go install github.com/polyfloyd/go-errorlint@latest
ISSUES="$(errorlint -errorf ./... 2>&1 | grep -E '^\S+\.go:' | head -20 || true)"
if [ -n "$ISSUES" ]; then
  COUNT="$(echo "$ISSUES" | wc -l | tr -d ' ')"
  gate_fail "$CAT" "$GATE" "$COUNT violacao(oes) de error wrap (%w ausente):"
  echo "$ISSUES" | head -10 | sed 's/^/  /'
  exit 1
fi
gate_ok "$CAT" "$GATE"
