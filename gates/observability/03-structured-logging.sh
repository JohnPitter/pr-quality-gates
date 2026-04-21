#!/usr/bin/env bash
# Observability 03: Structured logging enforced
# Coverage: HEURISTIC
set -euo pipefail
PLUGIN_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
source "$PLUGIN_DIR/lib/common.sh"
GATE="structured-logging"; CAT="observability"
gate_header "$CAT" "$GATE"

# Detecta uso de log standard (nao estruturado)
STDLOG="$(grep -rEn '^\s*log\.(Print|Fatal|Panic)' --include='*.go' --exclude='*_test.go' --exclude-dir=vendor . 2>/dev/null | head -10 || true)"
if [ -n "$STDLOG" ]; then
  COUNT="$(echo "$STDLOG" | wc -l | tr -d ' ')"
  gate_info "$CAT" "$GATE" "$COUNT uso(s) de 'log' stdlib - preferir slog/zap/zerolog (JSON structured)"
  echo "$STDLOG" | sed 's/^/  /' | head -5
fi

# Bonus: detecta se tem algum logger estruturado no projeto
HAS_STRUCT="$(grep -rE 'slog\.|zap\.|zerolog\.|logrus\.' --include='*.go' . 2>/dev/null | head -1 || true)"
[ -z "$HAS_STRUCT" ] && gate_info "$CAT" "$GATE" "nenhum logger estruturado detectado"
gate_ok "$CAT" "$GATE"
