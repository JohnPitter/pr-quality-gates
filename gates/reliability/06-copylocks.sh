#!/usr/bin/env bash
# Reliability 06: Mutex copy detection
# Coverage: FULL (go vet -copylocks)
set -euo pipefail
PLUGIN_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
source "$PLUGIN_DIR/lib/common.sh"
GATE="copylocks"; CAT="reliability"
gate_header "$CAT" "$GATE"

OUT="$(go vet -copylocks ./... 2>&1 | grep -E '\.go:' || true)"
if [ -n "$OUT" ]; then
  COUNT="$(echo "$OUT" | wc -l | tr -d ' ')"
  gate_fail "$CAT" "$GATE" "$COUNT copia de sync type (Mutex/RWMutex/WaitGroup):"
  echo "$OUT" | sed 's/^/  /' | head -10
  exit 1
fi
gate_ok "$CAT" "$GATE"
