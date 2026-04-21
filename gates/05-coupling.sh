#!/usr/bin/env bash
# Gate 5: Acoplamento de Dependencias
# Verifica: (1) ciclos de import, (2) camadas invertidas, (3) impl-to-impl.
set -euo pipefail

PLUGIN_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

echo "[gate:coupling] verificando ciclos e camadas..."

# 1. Ciclos de import - go build ja falha se houver ciclo,
#    entao garantimos com uma compilacao seca.
if ! go build ./... 2>&1 | tee /tmp/build.out; then
  if grep -q "import cycle" /tmp/build.out; then
    echo "[gate:coupling] FAIL - ciclo de import detectado"
    exit 1
  fi
fi

# 2. Camadas invertidas + impl-to-impl via golangci-lint/depguard
if ! command -v golangci-lint >/dev/null 2>&1; then
  echo "[gate:coupling] instalando golangci-lint..."
  go install github.com/golangci/golangci-lint/cmd/golangci-lint@latest
fi

if ! golangci-lint run --config "$PLUGIN_DIR/config/depguard.yml" --no-config=false ./...; then
  echo "[gate:coupling] FAIL - violacao de camada ou impl-to-impl detectada"
  exit 1
fi

echo "[gate:coupling] OK"
