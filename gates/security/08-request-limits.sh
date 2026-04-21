#!/usr/bin/env bash
# Security 08: Request body size limits
# Coverage: HEURISTIC - detecta handlers sem http.MaxBytesReader
set -euo pipefail
PLUGIN_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
source "$PLUGIN_DIR/lib/common.sh"
GATE="request-limits"; CAT="security"
gate_header "$CAT" "$GATE"

HAS_DECODE="$(grep -rEl 'json\.NewDecoder.*\.Decode|ioutil\.ReadAll.*\.Body|io\.ReadAll.*\.Body' --include='*.go' . 2>/dev/null || true)"
[ -z "$HAS_DECODE" ] && { gate_ok "$CAT" "$GATE" "sem request body parsing"; exit 0; }

HAS_LIMIT="$(grep -rE 'MaxBytesReader|http\.MaxBytesHandler' --include='*.go' . 2>/dev/null || true)"
if [ -z "$HAS_LIMIT" ]; then
  gate_fail "$CAT" "$GATE" "request body sem limite (risco DoS via payload gigante)"
  echo "  arquivos afetados:"
  echo "$HAS_DECODE" | head -5 | sed 's/^/    /'
  echo "  sugestao: http.MaxBytesReader(w, r.Body, 1<<20) antes de decode"
  exit 1
fi
gate_ok "$CAT" "$GATE"
