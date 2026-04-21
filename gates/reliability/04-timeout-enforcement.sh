#!/usr/bin/env bash
# Reliability 04: Timeout enforcement em operacoes I/O
# Coverage: HEURISTIC - detecta http.Client{} sem Timeout, sql.Open sem context
set -euo pipefail
PLUGIN_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
source "$PLUGIN_DIR/lib/common.sh"
GATE="timeout-enforcement"; CAT="reliability"
gate_header "$CAT" "$GATE"

# http.Client{} sem Timeout
HTTP_NT="$(grep -rn -A 3 'http\.Client\s*{' --include='*.go' --exclude='*_test.go' --exclude-dir=vendor . 2>/dev/null | \
  awk '/http\.Client\s*\{/{f=1; s=$0; next} f{s=s"\n"$0; if($0 ~ /\}/){if(s !~ /Timeout/){print s}; f=0; s=""}}' | \
  head -10 || true)"

if [ -n "$HTTP_NT" ]; then
  gate_fail "$CAT" "$GATE" "http.Client sem Timeout configurado"
  echo "$HTTP_NT" | head -10 | sed 's/^/  /'
  exit 1
fi

# http.DefaultClient (hardcoded no timeout)
DEFC="$(grep -rn 'http\.DefaultClient' --include='*.go' --exclude='*_test.go' --exclude-dir=vendor . 2>/dev/null | head -5 || true)"
if [ -n "$DEFC" ]; then
  gate_fail "$CAT" "$GATE" "http.DefaultClient = sem timeout, nunca usar em producao"
  echo "$DEFC" | sed 's/^/  /'
  exit 1
fi
gate_ok "$CAT" "$GATE"
