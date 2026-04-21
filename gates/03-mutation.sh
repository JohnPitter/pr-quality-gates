#!/usr/bin/env bash
# Gate 3: Mutacao de Testes (gremlins)
# Falha se o mutation score estiver abaixo do threshold.
# ATENCAO: gate lento - rodar apenas em CI/PR.
set -euo pipefail

PLUGIN_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
MIN="$(jq -r '.mutation_min' "$PLUGIN_DIR/config/thresholds.json")"
MIN_PCT="$(awk -v m="$MIN" 'BEGIN { printf "%.2f", m * 100 }')"

echo "[gate:mutation] threshold=${MIN_PCT}%"

if ! command -v gremlins >/dev/null 2>&1; then
  echo "[gate:mutation] instalando gremlins..."
  go install github.com/go-gremlins/gremlins/cmd/gremlins@latest
fi

OUTPUT="$(gremlins unleash --output json ./... 2>/dev/null || true)"
SCORE="$(echo "$OUTPUT" | jq -r '.results.mutationScore // 0')"
SCORE_PCT="$(awk -v s="$SCORE" 'BEGIN { printf "%.2f", s * 100 }')"

echo "[gate:mutation] atual=${SCORE_PCT}%"

if awk -v s="$SCORE_PCT" -v m="$MIN_PCT" 'BEGIN { exit !(s < m) }'; then
  echo "[gate:mutation] FAIL - mutation score ${SCORE_PCT}% abaixo do minimo ${MIN_PCT}%"
  exit 1
fi

echo "[gate:mutation] OK"
