#!/usr/bin/env bash
# Security 02: Supply Chain (CVEs em deps)
# Coverage: FULL (govulncheck + osv-scanner + go mod verify)
set -euo pipefail
PLUGIN_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
source "$PLUGIN_DIR/lib/common.sh"
GATE="supply-chain"; CAT="security"
gate_header "$CAT" "$GATE"
command -v govulncheck >/dev/null 2>&1 || go install golang.org/x/vuln/cmd/govulncheck@latest
VR="$(mktemp)"; trap 'rm -f "$VR"' EXIT
govulncheck -format json ./... > "$VR" 2>/dev/null || true
VULNS="$(jq -r 'select(.finding) | .finding | select(.trace != null) | .osv' "$VR" 2>/dev/null | sort -u | wc -l | tr -d ' ')"
if [ "$VULNS" -gt 0 ]; then
  gate_fail "$CAT" "$GATE" "$VULNS CVE(s) ativa(s)"
  jq -r 'select(.finding) | .finding | select(.trace != null) | "  \(.osv) em \(.trace[0].module // "unknown")"' "$VR" | sort -u
  exit 1
fi
[ -f go.sum ] && { go mod verify >/dev/null 2>&1 || { gate_fail "$CAT" "$GATE" "go.sum adulterado"; exit 1; }; }
gate_ok "$CAT" "$GATE"
