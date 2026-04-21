#!/usr/bin/env bash
# Performance 04: I/O buffering in hot paths
# Coverage: HEURISTIC - detecta File.Read/Write sem bufio
set -euo pipefail
PLUGIN_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
source "$PLUGIN_DIR/lib/common.sh"
GATE="io-buffering"; CAT="performance"
gate_header "$CAT" "$GATE"

# os.File.Write/Read without bufio wrapper in files that also iterate
BAD="$(grep -rn -E '\.(Read|Write)\(' --include='*.go' --exclude='*_test.go' --exclude-dir=vendor . 2>/dev/null | \
  grep -E 'for |range ' -B 5 2>/dev/null | \
  grep -E '\.(Read|Write)\(' | head -5 || true)"

if [ -n "$BAD" ]; then
  gate_info "$CAT" "$GATE" "possivel I/O nao-buferizado em loops:"
  echo "$BAD" | sed 's/^/  /' | head -5
  echo "  sugestao: bufio.NewReader/Writer antes de iterar"
fi
gate_ok "$CAT" "$GATE"
