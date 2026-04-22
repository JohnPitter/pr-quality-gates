#!/usr/bin/env bash
# Security 01: SAST (Static Application Security Testing)
# Coverage: FULL (gosec)
set -euo pipefail
PLUGIN_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
source "$PLUGIN_DIR/lib/common.sh"
GATE="sast"; CAT="security"
SEV="$(threshold_get sast_min_severity)"
[ -z "$SEV" ] && SEV="HIGH"
gate_header "$CAT" "$GATE" "min_severity=$SEV"
command -v gosec >/dev/null 2>&1 || go install github.com/securego/gosec/v2/cmd/gosec@latest
REP="$(mktemp)"; trap 'rm -f "$REP"' EXIT
gosec -severity "$(echo "$SEV" | tr '[:upper:]' '[:lower:]')" -confidence medium -fmt json -out "$REP" -quiet ./... 2>/dev/null || true
N="$(jq -r '.Issues | length' "$REP" 2>/dev/null | head -1 | tr -d '\n ' || echo 0)"
N="${N:-0}"
if [ "$N" -gt 0 ] 2>/dev/null; then
  gate_fail "$CAT" "$GATE" "$N vulnerabilidade(s)"
  jq -r '.Issues[] | "  [\(.severity)/\(.confidence)] \(.rule_id) \(.file):\(.line) - \(.details)"' "$REP"
  exit 1
fi
gate_ok "$CAT" "$GATE" "zero vulnerabilidades $SEV+"
