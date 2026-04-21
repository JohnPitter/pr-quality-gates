#!/usr/bin/env bash
# Infrastructure 05: Terraform security (tfsec/checkov)
# Coverage: FULL se tfsec instalado
set -euo pipefail
PLUGIN_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
source "$PLUGIN_DIR/lib/common.sh"
GATE="terraform"; CAT="infrastructure"
gate_header "$CAT" "$GATE"

TF="$(find . -type f -name "*.tf" -not -path '*/\.terraform/*' 2>/dev/null | head -1 || true)"
[ -z "$TF" ] && { gate_ok "$CAT" "$GATE" "sem Terraform"; exit 0; }

if command -v tfsec >/dev/null 2>&1; then
  OUT="$(tfsec --soft-fail --no-color . 2>&1 | grep -E 'HIGH|CRITICAL' | head -10 || true)"
  if [ -n "$OUT" ]; then
    gate_fail "$CAT" "$GATE" "problemas tfsec HIGH/CRITICAL:"
    echo "$OUT" | sed 's/^/  /'
    exit 1
  fi
else
  gate_info "$CAT" "$GATE" "tfsec nao instalado: brew install tfsec"
fi
gate_ok "$CAT" "$GATE"
