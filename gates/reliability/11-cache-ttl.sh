#!/usr/bin/env bash
# Reliability 11: Cache sem TTL = memory leak garantido
# Coverage: HEURISTIC - detecta sync.Map/map usado como cache sem evicao
set -euo pipefail
PLUGIN_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
source "$PLUGIN_DIR/lib/common.sh"
GATE="cache-ttl"; CAT="reliability"
gate_header "$CAT" "$GATE"

# sync.Map / map global = cache sem TTL
CACHE="$(grep -rEn '^var\s+[a-z][A-Za-z]*[Cc]ache\s+(=|sync\.Map|map\[)' --include='*.go' --exclude='*_test.go' --exclude-dir=vendor . 2>/dev/null || true)"
if [ -n "$CACHE" ]; then
  gate_info "$CAT" "$GATE" "caches detectadas - verificar se tem TTL/max size:"
  echo "$CACHE" | sed 's/^/  /' | head -5
  echo "  sugestao: github.com/hashicorp/golang-lru ou ristretto"
fi
gate_ok "$CAT" "$GATE"
