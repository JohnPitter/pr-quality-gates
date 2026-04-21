#!/usr/bin/env bash
# Operational 02: Graceful shutdown
# Coverage: HEURISTIC - server.Shutdown + signal handling
set -euo pipefail
PLUGIN_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
source "$PLUGIN_DIR/lib/common.sh"
GATE="graceful-shutdown"; CAT="operational"
gate_header "$CAT" "$GATE"

HAS_SERV="$(grep -rEl 'http\.Server|grpc\.NewServer' --include='*.go' --exclude-dir=vendor . 2>/dev/null || true)"
[ -z "$HAS_SERV" ] && { gate_ok "$CAT" "$GATE" "sem server"; exit 0; }

HAS_SHUTDOWN="$(grep -rE 'Shutdown|GracefulStop' --include='*.go' --exclude-dir=vendor . 2>/dev/null | head -1 || true)"
HAS_SIG="$(grep -rE 'signal\.Notify|os\.Interrupt|syscall\.SIGTERM' --include='*.go' --exclude-dir=vendor . 2>/dev/null | head -1 || true)"

if [ -z "$HAS_SHUTDOWN" ] || [ -z "$HAS_SIG" ]; then
  gate_fail "$CAT" "$GATE" "shutdown incompleto: Shutdown=$([ -n "$HAS_SHUTDOWN" ] && echo yes || echo NO), signal=$([ -n "$HAS_SIG" ] && echo yes || echo NO)"
  echo "  adicionar: signal.Notify + server.Shutdown(ctx) com timeout"
  exit 1
fi
gate_ok "$CAT" "$GATE"
