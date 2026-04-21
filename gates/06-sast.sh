#!/usr/bin/env bash
# Gate 6: SAST (Static Application Security Testing)
# Detecta vulnerabilidades: SQL injection, command injection, path traversal,
# crypto fraco, hardcoded secrets, unsafe deserialization, etc.
set -euo pipefail

PLUGIN_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
# shellcheck source=../lib/common.sh
source "$PLUGIN_DIR/lib/common.sh"
SEVERITY="$(jq -r '.sast_min_severity // "HIGH"' "$PLUGIN_DIR/config/thresholds.json")"

echo "[gate:sast] min_severity=$SEVERITY"

if ! command -v gosec >/dev/null 2>&1; then
  echo "[gate:sast] instalando gosec..."
  go install github.com/securego/gosec/v2/cmd/gosec@latest
fi

REPORT="$(mktemp -t gosec.XXXXXX.json)"
trap 'rm -f "$REPORT"' EXIT

# -severity: low|medium|high
# -confidence: low|medium|high
# -fmt json para parsing
SEVERITY_LOWER="$(echo "$SEVERITY" | tr '[:upper:]' '[:lower:]')"
gosec -severity "$SEVERITY_LOWER" -confidence medium -fmt json -out "$REPORT" -quiet ./... 2>/dev/null || true

ISSUES="$(jq -r '.Issues | length' "$REPORT" 2>/dev/null || echo 0)"

if [ "$ISSUES" -gt 0 ]; then
  echo "[gate:sast] FAIL - $ISSUES vulnerabilidade(s) encontrada(s):"
  jq -r '.Issues[] | "  [\(.severity)/\(.confidence)] \(.rule_id) \(.file):\(.line) - \(.details)"' "$REPORT"
  exit 1
fi

echo "[gate:sast] OK - zero vulnerabilidades $SEVERITY+"
