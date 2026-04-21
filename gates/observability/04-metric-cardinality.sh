#!/usr/bin/env bash
# Observability 04: Metric cardinality bounds
# Coverage: HEURISTIC - Prometheus labels com valores ilimitados
set -euo pipefail
PLUGIN_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
source "$PLUGIN_DIR/lib/common.sh"
GATE="metric-cardinality"; CAT="observability"
gate_header "$CAT" "$GATE"

# Labels com user_id, request_id, path dinamico = cardinalidade infinita
BAD="$(grep -rEn 'prometheus\.(Counter|Gauge|Histogram).*(user.?id|request.?id|session.?id|trace.?id)' --include='*.go' --exclude-dir=vendor -i . 2>/dev/null | head -5 || true)"
if [ -n "$BAD" ]; then
  gate_fail "$CAT" "$GATE" "labels com cardinalidade ilimitada:"
  echo "$BAD" | sed 's/^/  /'
  echo "  custo: cada valor unico = serie nova no TSDB"
  exit 1
fi
gate_ok "$CAT" "$GATE"
