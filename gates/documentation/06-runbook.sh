#!/usr/bin/env bash
# Documentation 06: Runbooks para erros
# Coverage: HEURISTIC
set -euo pipefail
PLUGIN_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
source "$PLUGIN_DIR/lib/common.sh"
GATE="runbook"; CAT="documentation"
gate_header "$CAT" "$GATE"

HAS_RB=0
for dir in docs/runbook docs/runbooks runbook runbooks .runbook; do
  [ -d "$dir" ] && HAS_RB=1 && break
done
[ -f RUNBOOK.md ] && HAS_RB=1

GO_FILES="$(find . -name "*.go" -not -path '*/vendor/*' 2>/dev/null | wc -l | tr -d ' ')"
[ "$GO_FILES" -lt 30 ] && { gate_ok "$CAT" "$GATE" "projeto pequeno"; exit 0; }

if [ "$HAS_RB" = "0" ]; then
  gate_info "$CAT" "$GATE" "sem runbooks - considerar docs/runbook/ para incidentes comuns"
fi
gate_ok "$CAT" "$GATE"
