#!/usr/bin/env bash
# Security 06: SBOM generation
# Coverage: FULL (cyclonedx-gomod)
set -euo pipefail
PLUGIN_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
source "$PLUGIN_DIR/lib/common.sh"
GATE="sbom"; CAT="security"
gate_header "$CAT" "$GATE"
[ -f go.mod ] || { gate_info "$CAT" "$GATE" "sem go.mod"; exit 0; }
command -v cyclonedx-gomod >/dev/null 2>&1 || go install github.com/CycloneDX/cyclonedx-gomod/cmd/cyclonedx-gomod@latest

OUT="${SBOM_OUTPUT:-sbom.xml}"
if cyclonedx-gomod mod -output "$OUT" >/dev/null 2>&1; then
  COMPONENTS="$(grep -c '<component ' "$OUT" 2>/dev/null || echo 0)"
  gate_ok "$CAT" "$GATE" "SBOM gerado ($OUT, $COMPONENTS componentes)"
else
  gate_fail "$CAT" "$GATE" "falha ao gerar SBOM"
  exit 1
fi
