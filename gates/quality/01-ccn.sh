#!/usr/bin/env bash
# Quality 01: Complexidade Ciclomatica
# Coverage: FULL (gocyclo tool)
set -euo pipefail

PLUGIN_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
# shellcheck source=../../lib/common.sh
source "$PLUGIN_DIR/lib/common.sh"

GATE="ccn"; CAT="quality"
THRESHOLD="$(jq -r '.ccn_max' "$PLUGIN_DIR/config/thresholds.json")"
gate_header "$CAT" "$GATE" "threshold=$THRESHOLD"

command -v gocyclo >/dev/null 2>&1 || go install github.com/fzipp/gocyclo/cmd/gocyclo@latest

# Exclude test files — production code is what we gate on. Test functions
# can legitimately be complex (table-driven, many scenarios).
RAW="$(gocyclo -over "$THRESHOLD" -ignore '_test\.go$' . 2>/dev/null || true)"
# Fallback if older gocyclo without -ignore: grep-filter.
[ -z "$RAW" ] && RAW="$(gocyclo -over "$THRESHOLD" . 2>/dev/null | grep -v '_test\.go' || true)"
[ -z "$RAW" ] && { gate_ok "$CAT" "$GATE"; exit 0; }

WITH_SIGS="$(echo "$RAW" | awk '{loc=$4; sub(/:[0-9]+:[0-9]+$/, "", loc); printf "%s %s %s\t%s\n", $2, $3, loc, $0}')"

if baseline_mode_active; then
  echo "$WITH_SIGS" | cut -f1 | baseline_capture "$GATE"; exit 0
fi

NEW_VIOLATIONS="$(echo "$WITH_SIGS" | baseline_filter "$GATE")"
if [ -n "$NEW_VIOLATIONS" ]; then
  NC="$(echo "$NEW_VIOLATIONS" | wc -l | tr -d ' ')"
  if baseline_ignored; then gate_fail "$CAT" "$GATE" "$NC funcao(oes) CCN > $THRESHOLD (full audit)"
  else gate_fail "$CAT" "$GATE" "$NC nova(s) funcao(oes) CCN > $THRESHOLD"; fi
  echo "$NEW_VIOLATIONS"
  exit 1
fi
TC="$(echo "$RAW" | wc -l | tr -d ' ')"
baseline_exists "$GATE" && gate_ok "$CAT" "$GATE" "OK - $TC pre-existentes (baseline), zero novas" || gate_ok "$CAT" "$GATE"
