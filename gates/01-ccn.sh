#!/usr/bin/env bash
# Gate 1: Complexidade Ciclomatica (CCN)
# Falha se qualquer funcao ultrapassar o threshold configurado.
# Suporta baseline: em codebases legados, PR_QUALITY_BASELINE=1 congela
# o estado atual e gates subsequentes so falham em violacoes NOVAS.
set -euo pipefail

PLUGIN_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
# shellcheck source=../lib/common.sh
source "$PLUGIN_DIR/lib/common.sh"

GATE="ccn"
THRESHOLD="$(jq -r '.ccn_max' "$PLUGIN_DIR/config/thresholds.json")"

echo "[gate:$GATE] threshold=$THRESHOLD"

if ! command -v gocyclo >/dev/null 2>&1; then
  echo "[gate:$GATE] instalando gocyclo..."
  go install github.com/fzipp/gocyclo/cmd/gocyclo@latest
fi

# Raw gocyclo output: "<ccn> <pkg> <func> <file>:<line>:<col>"
# Stable signature (for baseline): "<pkg> <func> <file>" (CCN stripped,
# line:col stripped) so that refactoring that lowers CCN doesn't
# re-flag the function.
RAW="$(gocyclo -over "$THRESHOLD" . || true)"

if [ -z "$RAW" ]; then
  echo "[gate:$GATE] OK"
  exit 0
fi

# Build signature\tfull-line pairs
WITH_SIGS="$(echo "$RAW" | awk '{
  ccn=$1; pkg=$2; fn=$3; loc=$4
  # Strip ":line:col" from loc -> file
  sub(/:[0-9]+:[0-9]+$/, "", loc)
  printf "%s %s %s\t%s\n", pkg, fn, loc, $0
}')"

if baseline_mode_active; then
  echo "$WITH_SIGS" | cut -f1 | baseline_capture "$GATE"
  echo "[gate:$GATE] baseline mode - all violations accepted"
  exit 0
fi

NEW_VIOLATIONS="$(echo "$WITH_SIGS" | baseline_filter "$GATE")"

if [ -n "$NEW_VIOLATIONS" ]; then
  NEW_COUNT="$(echo "$NEW_VIOLATIONS" | wc -l | tr -d ' ')"
  TOTAL_COUNT="$(echo "$RAW" | wc -l | tr -d ' ')"
  BASELINED_COUNT="$((TOTAL_COUNT - NEW_COUNT))"
  if baseline_ignored; then
    echo "[gate:$GATE] FAIL - $NEW_COUNT funcao(oes) acima de CCN $THRESHOLD (baseline ignorado - full audit):"
  else
    echo "[gate:$GATE] FAIL - $NEW_COUNT nova(s) funcao(oes) acima de CCN $THRESHOLD (ignoradas $BASELINED_COUNT do baseline):"
  fi
  echo "$NEW_VIOLATIONS"
  exit 1
fi

if baseline_exists "$GATE"; then
  TOTAL_COUNT="$(echo "$RAW" | wc -l | tr -d ' ')"
  echo "[gate:$GATE] OK - $TOTAL_COUNT violacao(oes) pre-existentes (baseline), zero novas"
else
  echo "[gate:$GATE] OK"
fi
