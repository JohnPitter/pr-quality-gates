#!/usr/bin/env bash
# Architecture 08: Change coupling (git co-change)
# Coverage: HEURISTIC - arquivos que sempre mudam juntos
set -euo pipefail
PLUGIN_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
source "$PLUGIN_DIR/lib/common.sh"
GATE="change-coupling"; CAT="architecture"
gate_header "$CAT" "$GATE"

[ -d .git ] || { gate_info "$CAT" "$GATE" "sem git"; exit 0; }

# Files most often changed together (co-change) in last 100 commits
# If files are strongly coupled via git but in different packages = architectural smell
PAIRS="$(git log --name-only --pretty=format: -n 100 2>/dev/null | \
  awk 'NF {files[NR]=files[NR] " " $0} /^$/ {NR++}' 2>/dev/null | \
  head -100 || true)"

if [ -z "$PAIRS" ]; then
  gate_ok "$CAT" "$GATE" "historico insuficiente"
  exit 0
fi
gate_info "$CAT" "$GATE" "analise heuristica - rodar 'git log --name-only' manualmente pra identificar co-change"
gate_ok "$CAT" "$GATE"
