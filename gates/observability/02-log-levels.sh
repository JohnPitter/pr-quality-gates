#!/usr/bin/env bash
# Observability 02: Log level discipline
# Coverage: HEURISTIC - detecta fmt.Println/log.Println em producao (sem nivel)
set -euo pipefail
PLUGIN_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
source "$PLUGIN_DIR/lib/common.sh"
GATE="log-levels"; CAT="observability"
gate_header "$CAT" "$GATE"

BAD="$(grep -rEn 'fmt\.(Println|Printf|Print)\(' --include='*.go' --exclude='*_test.go' --exclude='main.go' --exclude-dir=vendor . 2>/dev/null | head -15 || true)"
if [ -n "$BAD" ]; then
  COUNT="$(echo "$BAD" | wc -l | tr -d ' ')"
  gate_fail "$CAT" "$GATE" "$COUNT fmt.Print* em producao (usar logger estruturado com nivel):"
  echo "$BAD" | sed 's/^/  /' | head -10
  exit 1
fi
gate_ok "$CAT" "$GATE"
