#!/usr/bin/env bash
# PR check: roda a suite completa no CI.
set -euo pipefail

PLUGIN_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

echo "=== PR Quality Gates (full suite) ==="

bash "$PLUGIN_DIR/gates/01-ccn.sh"
bash "$PLUGIN_DIR/gates/02-coverage.sh"
bash "$PLUGIN_DIR/gates/03-mutation.sh"
bash "$PLUGIN_DIR/gates/04-module-size.sh"
bash "$PLUGIN_DIR/gates/05-coupling.sh"
bash "$PLUGIN_DIR/gates/06-sast.sh"
bash "$PLUGIN_DIR/gates/07-supply-chain.sh"
bash "$PLUGIN_DIR/gates/08-secrets.sh"

echo "=== Todos os 8 gates passaram ==="
