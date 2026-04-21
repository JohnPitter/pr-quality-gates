#!/usr/bin/env bash
# Security 03: Secrets detection
# Coverage: FULL (gitleaks)
# Baseline: NEVER - secrets must never exist in repo
set -euo pipefail
PLUGIN_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
source "$PLUGIN_DIR/lib/common.sh"
GATE="secrets"; CAT="security"
gate_header "$CAT" "$GATE"
command -v gitleaks >/dev/null 2>&1 || go install github.com/zricethezav/gitleaks/v8@latest
REP="$(mktemp)"; trap 'rm -f "$REP"' EXIT
gitleaks detect --no-banner --redact --report-format json --report-path "$REP" --exit-code 0 >/dev/null 2>&1 || true
LEAKS="$(jq 'length' "$REP" 2>/dev/null || echo 0)"
if [ "$LEAKS" -gt 0 ]; then
  gate_fail "$CAT" "$GATE" "$LEAKS secret(s) detectado(s)"
  jq -r '.[] | "  [\(.RuleID)] \(.File):\(.StartLine) - \(.Description)"' "$REP"
  echo "  ACAO: rotacionar IMEDIATAMENTE e remover do historico git"
  exit 1
fi
gate_ok "$CAT" "$GATE"
