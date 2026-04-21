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
go test -coverprofile="$TMP" ./... >/dev/null 2>&1 || true
[ -s "$TMP" ] || { gate_info "$CAT" "$GATE" "sem testes executaveis"; exit 0; }
COV="$(go tool cover -func="$TMP" | awk '/^total:/ {gsub(/%/,"",$3); print $3}')"
if awk -v c="$COV" -v m="$MIN_PCT" 'BEGIN{exit !(c<m)}'; then
  gate_fail "$CAT" "$GATE" "cobertura ${COV}% < ${MIN_PCT}%"; exit 1
fi
gate_ok "$CAT" "$GATE" "${COV}% >= ${MIN_PCT}%"
