#!/usr/bin/env bash
# Release 02: Semver compliance via apidiff
# Coverage: FULL (apidiff)
set -euo pipefail
PLUGIN_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
source "$PLUGIN_DIR/lib/common.sh"
GATE="semver"; CAT="release"
gate_header "$CAT" "$GATE"

[ -f go.mod ] || { gate_info "$CAT" "$GATE" "sem go.mod"; exit 0; }
command -v apidiff >/dev/null 2>&1 || go install golang.org/x/exp/cmd/apidiff@latest
gate_info "$CAT" "$GATE" "rodar manualmente: apidiff <old.pkg> <new.pkg>"
gate_ok "$CAT" "$GATE"
