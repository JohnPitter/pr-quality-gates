#!/usr/bin/env bash
# Gate 2: Cobertura de Testes
# Falha se a cobertura global estiver abaixo do threshold.
set -euo pipefail

PLUGIN_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
MIN="$(jq -r '.coverage_min' "$PLUGIN_DIR/config/thresholds.json")"
MIN_PCT="$(awk -v m="$MIN" 'BEGIN { printf "%.2f", m * 100 }')"

echo "[gate:coverage] threshold=${MIN_PCT}%"

TMP="$(mktemp -t cover.XXXXXX.out)"
trap 'rm -f "$TMP"' EXIT

go test -coverprofile="$TMP" ./... >/dev/null
COVERAGE="$(go tool cover -func="$TMP" | awk '/^total:/ { gsub(/%/, "", $3); print $3 }')"

echo "[gate:coverage] atual=${COVERAGE}%"

if awk -v c="$COVERAGE" -v m="$MIN_PCT" 'BEGIN { exit !(c < m) }'; then
  echo "[gate:coverage] FAIL - cobertura ${COVERAGE}% abaixo do minimo ${MIN_PCT}%"
  exit 1
fi

echo "[gate:coverage] OK"
