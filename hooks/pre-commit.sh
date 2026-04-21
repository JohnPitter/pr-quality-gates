#!/usr/bin/env bash
# Pre-commit: executa apenas a categoria "core" (security + reliability + quality).
# Gates lentos (mutation, benchmark) pulados no pre-commit.
set -euo pipefail
PLUGIN_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "$PLUGIN_DIR/lib/common.sh"
export PR_QUALITY_CATEGORIES="${PR_QUALITY_CATEGORIES:-core}"
run_gates "$PLUGIN_DIR"
