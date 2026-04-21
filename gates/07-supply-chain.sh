#!/usr/bin/env bash
# Gate 7: Supply Chain Security
# Detecta: vulnerabilidades conhecidas em dependencias (govulncheck, osv-scanner)
# e integridade de go.sum.
set -euo pipefail

PLUGIN_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
# shellcheck source=../lib/common.sh
source "$PLUGIN_DIR/lib/common.sh"
MAX_CVSS="$(jq -r '.supply_chain_max_cvss // 7.0' "$PLUGIN_DIR/config/thresholds.json")"

echo "[gate:supply-chain] max_cvss_without_patch=$MAX_CVSS"

# 1. govulncheck - analise de vulnerabilidades em codigo Go que realmente usa a dep
if ! command -v govulncheck >/dev/null 2>&1; then
  echo "[gate:supply-chain] instalando govulncheck..."
  go install golang.org/x/vuln/cmd/govulncheck@latest
fi

VULN_REPORT="$(mktemp -t vuln.XXXXXX.json)"
trap 'rm -f "$VULN_REPORT"' EXIT

if ! govulncheck -format json ./... > "$VULN_REPORT" 2>/dev/null; then
  VULNS="$(jq -r 'select(.finding) | .finding | select(.trace != null) | .osv' "$VULN_REPORT" 2>/dev/null | sort -u | wc -l | tr -d ' ')"
  if [ "$VULNS" -gt 0 ]; then
    echo "[gate:supply-chain] FAIL - $VULNS vulnerabilidade(s) ativa(s) em deps:"
    jq -r 'select(.finding) | .finding | select(.trace != null) | "  \(.osv) em \(.trace[0].module // "unknown")"' "$VULN_REPORT" | sort -u
    exit 1
  fi
fi

# 2. go.sum integridade
if [ -f go.sum ]; then
  if ! go mod verify >/dev/null 2>&1; then
    echo "[gate:supply-chain] FAIL - go.sum adulterado ou modulos invalidos"
    go mod verify
    exit 1
  fi
fi

# 3. osv-scanner (opcional - cross-ecosystem, mais amplo)
if command -v osv-scanner >/dev/null 2>&1; then
  OSV_REPORT="$(mktemp -t osv.XXXXXX.json)"
  trap 'rm -f "$VULN_REPORT" "$OSV_REPORT"' EXIT
  if ! osv-scanner --format json --lockfile go.mod > "$OSV_REPORT" 2>/dev/null; then
    HIGH_VULNS="$(jq -r '[.results[]?.packages[]?.vulnerabilities[]? | select(.database_specific.severity // "" | IN("HIGH","CRITICAL"))] | length' "$OSV_REPORT" 2>/dev/null || echo 0)"
    if [ "$HIGH_VULNS" -gt 0 ]; then
      echo "[gate:supply-chain] FAIL - $HIGH_VULNS CVE HIGH/CRITICAL no grafo de deps"
      jq -r '.results[]?.packages[]?.vulnerabilities[]? | select(.database_specific.severity // "" | IN("HIGH","CRITICAL")) | "  \(.id) [\(.database_specific.severity)] - \(.summary)"' "$OSV_REPORT"
      exit 1
    fi
  fi
fi

echo "[gate:supply-chain] OK - sem vulnerabilidades ativas"
