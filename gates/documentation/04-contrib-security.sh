#!/usr/bin/env bash
# Documentation 04: CONTRIBUTING.md + SECURITY.md
# Coverage: FULL
set -euo pipefail
PLUGIN_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
source "$PLUGIN_DIR/lib/common.sh"
GATE="contrib-security"; CAT="documentation"
gate_header "$CAT" "$GATE"

[ -d .git ] || { gate_ok "$CAT" "$GATE" "sem git"; exit 0; }

MISSING=()
[ -f CONTRIBUTING.md ] || [ -f .github/CONTRIBUTING.md ] || MISSING+=("CONTRIBUTING.md")
[ -f SECURITY.md ] || [ -f .github/SECURITY.md ] || MISSING+=("SECURITY.md")

if [ "${#MISSING[@]}" -gt 0 ]; then
  gate_info "$CAT" "$GATE" "ausente: ${MISSING[*]}"
fi
gate_ok "$CAT" "$GATE"
