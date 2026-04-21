#!/usr/bin/env bash
# Gate 1: Complexidade Ciclomatica (CCN)
# Falha se qualquer funcao ultrapassar o threshold configurado.
set -euo pipefail

PLUGIN_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
THRESHOLD="$(jq -r '.ccn_max' "$PLUGIN_DIR/config/thresholds.json")"

echo "[gate:ccn] threshold=$THRESHOLD"

if ! command -v gocyclo >/dev/null 2>&1; then
  echo "[gate:ccn] instalando gocyclo..."
  go install github.com/fzipp/gocyclo/cmd/gocyclo@latest
fi

VIOLATIONS="$(gocyclo -over "$THRESHOLD" . || true)"

if [ -n "$VIOLATIONS" ]; then
  echo "[gate:ccn] FAIL - funcoes acima de CCN $THRESHOLD:"
  echo "$VIOLATIONS"
  exit 1
fi

echo "[gate:ccn] OK"
