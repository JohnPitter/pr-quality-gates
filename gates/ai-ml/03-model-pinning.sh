#!/usr/bin/env bash
# AI/ML 03: Model version pinning
# Coverage: FULL
set -euo pipefail
PLUGIN_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
source "$PLUGIN_DIR/lib/common.sh"
GATE="model-pinning"; CAT="ai-ml"
gate_header "$CAT" "$GATE"

# Uso de "latest" em nomes de modelo = instavel
BAD="$(grep -rEn '(model|Model)\s*:\s*"[^"]*latest"|(model|Model).*=\s*"[^"]*latest"' --include='*.go' --exclude-dir=vendor . 2>/dev/null | head -10 || true)"
if [ -n "$BAD" ]; then
  gate_fail "$CAT" "$GATE" "model com tag 'latest' (output muda sem aviso):"
  echo "$BAD" | sed 's/^/  /'
  echo "  sugestao: pinar versao exata, ex: claude-opus-4-7, gpt-5"
  exit 1
fi

# Model hardcoded vs config
HARDCODED="$(grep -rEn 'gpt-|claude-|gemini-' --include='*.go' --exclude='*_test.go' --exclude-dir=vendor . 2>/dev/null | head -5 || true)"
[ -n "$HARDCODED" ] && gate_info "$CAT" "$GATE" "model hardcoded - considerar config env var"

gate_ok "$CAT" "$GATE"
