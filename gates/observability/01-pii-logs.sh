#!/usr/bin/env bash
# Observability 01: PII em logs
# Coverage: HEURISTIC - detecta strings logadas que parecem email/token/CPF
set -euo pipefail
PLUGIN_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
source "$PLUGIN_DIR/lib/common.sh"
GATE="pii-logs"; CAT="observability"
gate_header "$CAT" "$GATE"

BAD="$(grep -rEn '(log\.|logger\.|slog\.).+(email|password|token|cpf|cnpj|ssn|credit.?card)' --include='*.go' --exclude='*_test.go' --exclude-dir=vendor -i . 2>/dev/null | head -10 || true)"
if [ -n "$BAD" ]; then
  gate_fail "$CAT" "$GATE" "logs com provavel PII:"
  echo "$BAD" | sed 's/^/  /' | head -10
  exit 1
fi
gate_ok "$CAT" "$GATE"
