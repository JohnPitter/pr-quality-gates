#!/usr/bin/env bash
# Security 05: Version pinning enforcement
# Coverage: FULL - Go modules always use explicit versions + go.sum hashes
set -euo pipefail
PLUGIN_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
source "$PLUGIN_DIR/lib/common.sh"
GATE="version-pinning"; CAT="security"
gate_header "$CAT" "$GATE"
[ -f go.mod ] || { gate_info "$CAT" "$GATE" "sem go.mod"; exit 0; }
[ -f go.sum ] || { gate_fail "$CAT" "$GATE" "go.sum ausente - deps nao pinned"; exit 1; }

# Check for replace directives pointing to local paths (can break CI)
REPL="$(grep -E '^\s*replace\s' go.mod 2>/dev/null | grep -vE 'v[0-9]' || true)"
if [ -n "$REPL" ]; then
  gate_fail "$CAT" "$GATE" "replace directives apontando pra paths nao-versionados:"
  echo "$REPL" | sed 's/^/  /'
  exit 1
fi

# Verify go.sum integrity
go mod verify >/dev/null 2>&1 || { gate_fail "$CAT" "$GATE" "go mod verify falhou"; exit 1; }
gate_ok "$CAT" "$GATE"
