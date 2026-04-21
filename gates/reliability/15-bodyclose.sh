#!/usr/bin/env bash
# Reliability 15: http.Response.Body.Close()
# Coverage: FULL (bodyclose)
set -euo pipefail
PLUGIN_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
source "$PLUGIN_DIR/lib/common.sh"
GATE="body-close"; CAT="reliability"
gate_header "$CAT" "$GATE"

command -v bodyclose >/dev/null 2>&1 || go install github.com/timakin/bodyclose@latest
# Exclude test files — test HTTP bodies are often intentionally short-lived
# and closing every one adds noise without real FD leak risk.
OUT="$(bodyclose ./... 2>&1 | grep -E '\.go:' | grep -v '_test\.go' | head -20 || true)"
if [ -n "$OUT" ]; then
  COUNT="$(echo "$OUT" | wc -l | tr -d ' ')"
  gate_fail "$CAT" "$GATE" "$COUNT http.Response.Body nao fechado (FD leak):"
  echo "$OUT" | sed 's/^/  /' | head -10
  exit 1
fi
gate_ok "$CAT" "$GATE"
