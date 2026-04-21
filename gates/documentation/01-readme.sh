#!/usr/bin/env bash
# Documentation 01: README.md com secoes minimas
# Coverage: HEURISTIC
set -euo pipefail
PLUGIN_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
source "$PLUGIN_DIR/lib/common.sh"
GATE="readme"; CAT="documentation"
gate_header "$CAT" "$GATE"

if [ ! -f README.md ]; then
  gate_fail "$CAT" "$GATE" "README.md ausente"
  exit 1
fi

LINES="$(wc -l < README.md | tr -d ' ')"
if [ "$LINES" -lt 20 ]; then
  gate_fail "$CAT" "$GATE" "README muito curto ($LINES linhas)"
  exit 1
fi

MISSING=()
grep -qiE '^#+\s+(install|setup|getting.started)' README.md || MISSING+=("Install/Setup")
grep -qiE '^#+\s+(usage|quick.?start|how to)' README.md || MISSING+=("Usage/Quickstart")
grep -qiE '^#+\s+(license)' README.md || MISSING+=("License")

if [ "${#MISSING[@]}" -gt 0 ]; then
  gate_fail "$CAT" "$GATE" "README sem secoes: ${MISSING[*]}"
  exit 1
fi
gate_ok "$CAT" "$GATE"
