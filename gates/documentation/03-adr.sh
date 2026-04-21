#!/usr/bin/env bash
# Documentation 03: Architecture Decision Records
# Coverage: HEURISTIC
set -euo pipefail
PLUGIN_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
source "$PLUGIN_DIR/lib/common.sh"
GATE="adr"; CAT="documentation"
gate_header "$CAT" "$GATE"

GO_FILES="$(find . -name "*.go" -not -path '*/vendor/*' 2>/dev/null | wc -l | tr -d ' ')"
[ "$GO_FILES" -lt 50 ] && { gate_ok "$CAT" "$GATE" "projeto pequeno ($GO_FILES arquivos)"; exit 0; }

HAS_ADR=0
for dir in docs/adr docs/architecture adr .adr; do
  [ -d "$dir" ] && HAS_ADR=1 && break
done

if [ "$HAS_ADR" = "0" ]; then
  gate_info "$CAT" "$GATE" "projeto com $GO_FILES arquivos sem docs/adr/ - considerar ADRs"
fi
gate_ok "$CAT" "$GATE"
