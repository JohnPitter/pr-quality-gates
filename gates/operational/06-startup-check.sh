#!/usr/bin/env bash
# Operational 06: Startup self-check
# Coverage: HEURISTIC
set -euo pipefail
PLUGIN_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
source "$PLUGIN_DIR/lib/common.sh"
GATE="startup-check"; CAT="operational"
gate_header "$CAT" "$GATE"
gate_info "$CAT" "$GATE" "verificar manualmente: main() valida conexoes com deps antes de aceitar trafego"
gate_ok "$CAT" "$GATE"
