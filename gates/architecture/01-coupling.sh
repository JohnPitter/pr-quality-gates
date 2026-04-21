#!/usr/bin/env bash
# Architecture 01: Coupling (ciclos, camadas invertidas, impl-to-impl)
# Coverage: FULL (golangci-lint + depguard + go build)
set -euo pipefail
PLUGIN_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
source "$PLUGIN_DIR/lib/common.sh"
GATE="coupling"; CAT="architecture"
gate_header "$CAT" "$GATE"

# 1. Import cycles (go build catches these)
if go build ./... 2>&1 | tee /tmp/build.out | grep -q "import cycle"; then
  gate_fail "$CAT" "$GATE" "ciclo de import"
  grep "import cycle" /tmp/build.out
  exit 1
fi

# 2. Layer + impl-to-impl via depguard
command -v golangci-lint >/dev/null 2>&1 || go install github.com/golangci/golangci-lint/cmd/golangci-lint@latest
if ! golangci-lint run --config "$PLUGIN_DIR/config/depguard.yml" --no-config=false ./... 2>&1 | head -30; then
  gate_fail "$CAT" "$GATE" "violacao de camada ou impl-to-impl"
  exit 1
fi
gate_ok "$CAT" "$GATE"
