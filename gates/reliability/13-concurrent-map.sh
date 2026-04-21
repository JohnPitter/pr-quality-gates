#!/usr/bin/env bash
# Reliability 13: Concurrent map access sem mutex
# Coverage: HEURISTIC - maps globais acessados de goroutines diferentes
set -euo pipefail
PLUGIN_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
source "$PLUGIN_DIR/lib/common.sh"
GATE="concurrent-map"; CAT="reliability"
gate_header "$CAT" "$GATE"

# Detecta: package-level map + go func em algum lugar do pacote
for f in $(find . -name "*.go" -not -name "*_test.go" -not -path './vendor/*' 2>/dev/null); do
  if grep -qE '^var\s+[a-z][A-Za-z]*\s+map\[' "$f" 2>/dev/null && \
     grep -q 'go func' "$f" 2>/dev/null && \
     ! grep -qE 'sync\.(Mutex|RWMutex|Map)' "$f" 2>/dev/null; then
    gate_info "$CAT" "$GATE" "$f: map global + goroutines sem sync primitive"
  fi
done
gate_ok "$CAT" "$GATE"
