#!/usr/bin/env bash
# PR check: executa categorias selecionadas (padrao: all no CI).
set -euo pipefail
PLUGIN_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "$PLUGIN_DIR/lib/common.sh"
export PR_QUALITY_CATEGORIES="${PR_QUALITY_CATEGORIES:-all}"
run_gates "$PLUGIN_DIR"
