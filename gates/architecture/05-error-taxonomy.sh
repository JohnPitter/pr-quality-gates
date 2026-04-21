#!/usr/bin/env bash
# Architecture 05: Error taxonomy
# Coverage: HEURISTIC - detecta errors.New com string literal em codigo producao
set -euo pipefail
PLUGIN_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
source "$PLUGIN_DIR/lib/common.sh"
GATE="error-taxonomy"; CAT="architecture"
gate_header "$CAT" "$GATE"

# errors.New("string") in non-test code = anti-pattern
BAD="$(grep -rn 'errors\.New("' --include='*.go' --exclude='*_test.go' --exclude-dir=vendor . 2>/dev/null | head -10 || true)"
if [ -n "$BAD" ]; then
  COUNT="$(echo "$BAD" | wc -l | tr -d ' ')"
  gate_info "$CAT" "$GATE" "$COUNT uso(s) de errors.New() - considere tipos sentinela:"
  echo "$BAD" | sed 's/^/  /' | head -5
  # Info-level: not blocking, just advisory
fi

# fmt.Errorf without %w = losing error chain
NOWRAP="$(grep -rn 'fmt\.Errorf(' --include='*.go' --exclude='*_test.go' --exclude-dir=vendor . 2>/dev/null | grep -v '%w' | head -10 || true)"
if [ -n "$NOWRAP" ]; then
  COUNT="$(echo "$NOWRAP" | wc -l | tr -d ' ')"
  if [ "$COUNT" -gt 5 ]; then
    gate_fail "$CAT" "$GATE" "$COUNT fmt.Errorf sem %w (perde chain de erro)"
    echo "$NOWRAP" | sed 's/^/  /' | head -10
    exit 1
  fi
fi
gate_ok "$CAT" "$GATE"
