#!/usr/bin/env bash
# Quality 02: Cobertura de testes
# Coverage: FULL (go test -cover)
set -euo pipefail
PLUGIN_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
source "$PLUGIN_DIR/lib/common.sh"
GATE="coverage"; CAT="quality"
MIN="$(jq -r '.coverage_min' "$PLUGIN_DIR/config/thresholds.json")"
MIN_PCT="$(awk -v m="$MIN" 'BEGIN{printf "%.2f", m*100}')"
gate_header "$CAT" "$GATE" "threshold=${MIN_PCT}%"
TMP="$(mktemp)"; trap 'rm -f "$TMP"' EXIT
# -coverpkg=./... aggregates coverage across all packages. Without it,
# the coverprofile only retains the LAST tested package (Go quirk), which
# causes the total to report as the last package's cov instead of overall.
go test -coverpkg=./... -coverprofile="$TMP" ./... >/dev/null 2>&1 || true
[ -s "$TMP" ] || { gate_info "$CAT" "$GATE" "sem testes executaveis"; exit 0; }
COV="$(go tool cover -func="$TMP" 2>/dev/null | awk '/^total:/ {gsub(/%/,"",$3); print $3}')"
[ -z "$COV" ] && { gate_info "$CAT" "$GATE" "nao foi possivel calcular cobertura"; exit 0; }
if awk -v c="$COV" -v m="$MIN_PCT" 'BEGIN{exit !(c<m)}'; then
  gate_fail "$CAT" "$GATE" "cobertura ${COV}% < ${MIN_PCT}%"; exit 1
fi
gate_ok "$CAT" "$GATE" "${COV}% >= ${MIN_PCT}%"
