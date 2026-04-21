#!/usr/bin/env bash
# Release 03: Release signing (cosign/sigstore)
# Coverage: HEURISTIC - detecta config de signing no CI
set -euo pipefail
PLUGIN_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
source "$PLUGIN_DIR/lib/common.sh"
GATE="release-signing"; CAT="release"
gate_header "$CAT" "$GATE"

HAS_SIGN="$(grep -rE 'cosign|sigstore|gpg.*sign|goreleaser.*sign' .github/ 2>/dev/null | head -1 || true)"
[ -z "$HAS_SIGN" ] && gate_info "$CAT" "$GATE" "releases nao assinadas (sem cosign/sigstore/gpg)"
gate_ok "$CAT" "$GATE"
