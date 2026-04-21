#!/usr/bin/env bash
# Pre-commit: roda gates rapidos antes de permitir o commit.
# Gates lentos (coverage, mutation, supply-chain) ficam apenas no CI/PR.
set -euo pipefail

PLUGIN_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

echo "=== PR Quality Gates (pre-commit) ==="

bash "$PLUGIN_DIR/gates/01-ccn.sh"
bash "$PLUGIN_DIR/gates/04-module-size.sh"
bash "$PLUGIN_DIR/gates/05-coupling.sh"
bash "$PLUGIN_DIR/gates/08-secrets.sh"

echo "=== Todos os gates rapidos passaram ==="
