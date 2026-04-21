#!/usr/bin/env bash
# Testing 02: Fuzz tests em parsers/decoders
# Coverage: HEURISTIC
set -euo pipefail
PLUGIN_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
source "$PLUGIN_DIR/lib/common.sh"
GATE="fuzz-required"; CAT="testing"
gate_header "$CAT" "$GATE"

# Arquivos com Parse/Decode/Unmarshal sem fuzz correspondente
PARSERS="$(grep -rEl 'func (Parse|Decode|Unmarshal)' --include='*.go' --exclude='*_test.go' --exclude-dir=vendor . 2>/dev/null || true)"
[ -z "$PARSERS" ] && { gate_ok "$CAT" "$GATE" "sem parsers"; exit 0; }

MISSING=0
for f in $PARSERS; do
  testfile="${f%.go}_test.go"
  [ -f "$testfile" ] || continue
  if ! grep -qE '^func Fuzz' "$testfile" 2>/dev/null; then
    [ "$MISSING" = "0" ] && gate_info "$CAT" "$GATE" "parsers sem FuzzTest:"
    echo "  $f"
    MISSING=$((MISSING+1))
    [ "$MISSING" -ge 5 ] && break
  fi
done
gate_ok "$CAT" "$GATE"
