#!/usr/bin/env bash
# Infrastructure 07: Helm chart validation
# Coverage: FULL
set -euo pipefail
PLUGIN_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
source "$PLUGIN_DIR/lib/common.sh"
GATE="helm"; CAT="infrastructure"
gate_header "$CAT" "$GATE"

CHARTS="$(find . -type f -name "Chart.yaml" -not -path '*/vendor/*' 2>/dev/null | head -5 || true)"
[ -z "$CHARTS" ] && { gate_ok "$CAT" "$GATE" "sem Helm charts"; exit 0; }

if ! command -v helm >/dev/null 2>&1; then
  gate_info "$CAT" "$GATE" "helm CLI nao instalado - skip"
  exit 0
fi

FAIL=0
for c in $CHARTS; do
  CHART_DIR="$(dirname "$c")"
  if ! helm lint "$CHART_DIR" 2>&1 | tail -5 | grep -q "0 chart(s) failed"; then
    [ "$FAIL" = "0" ] && gate_fail "$CAT" "$GATE" "helm lint falhou:"
    echo "  $CHART_DIR"
    FAIL=1
  fi
done
[ "$FAIL" = "1" ] && exit 1
gate_ok "$CAT" "$GATE"
