#!/usr/bin/env bash
# Gate 8: Secrets Detection
# Bloqueia commit se encontrar: AWS keys, tokens (Riot/GitHub/Slack/etc),
# private keys, JWTs, senhas hardcoded, connection strings com credenciais.
set -euo pipefail

PLUGIN_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

echo "[gate:secrets] scanning..."

# gitleaks - scanner dedicado, baixa taxa de falso positivo
if ! command -v gitleaks >/dev/null 2>&1; then
  echo "[gate:secrets] instalando gitleaks..."
  go install github.com/gitleaks/gitleaks/v8@latest
fi

REPORT="$(mktemp -t gitleaks.XXXXXX.json)"
trap 'rm -f "$REPORT"' EXIT

# Scan completo do repo + unstaged changes
# --no-banner para output limpo
# --redact para nao vazar o secret no log
if gitleaks detect \
    --no-banner \
    --redact \
    --report-format json \
    --report-path "$REPORT" \
    --exit-code 0 \
    >/dev/null 2>&1; then

  LEAKS="$(jq 'length' "$REPORT" 2>/dev/null || echo 0)"

  if [ "$LEAKS" -gt 0 ]; then
    echo "[gate:secrets] FAIL - $LEAKS secret(s) detectado(s):"
    jq -r '.[] | "  [\(.RuleID)] \(.File):\(.StartLine) - \(.Description)"' "$REPORT"
    echo ""
    echo "  ACAO: rotacionar o secret IMEDIATAMENTE e remover do historico:"
    echo "    git filter-repo --path <arquivo> --invert-paths"
    exit 1
  fi
fi

echo "[gate:secrets] OK - nenhum secret detectado"
