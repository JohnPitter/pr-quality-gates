#!/usr/bin/env bash
# API 01: REST status codes usage
# Coverage: HEURISTIC - detecta 200 onde deveria ser 201/204, 500 generico
set -euo pipefail
PLUGIN_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
source "$PLUGIN_DIR/lib/common.sh"
GATE="rest-status-codes"; CAT="api"
gate_header "$CAT" "$GATE"

HAS_HTTP="$(grep -rEl 'http\.(Handle|HandlerFunc)|\.Handler\(\)' --include='*.go' --exclude-dir=vendor . 2>/dev/null | head -1 || true)"
[ -z "$HAS_HTTP" ] && { gate_ok "$CAT" "$GATE" "sem HTTP"; exit 0; }

# 500 generico sem contexto
GENERIC="$(grep -rEn 'WriteHeader\(500\)|StatusCode:\s*500|StatusInternalServerError' --include='*.go' --exclude='*_test.go' --exclude-dir=vendor . 2>/dev/null | head -5 || true)"
# DELETE que retorna 200 (deveria ser 204 ou 202)
D_200="$(grep -rEn -B 3 'WriteHeader\(200\)' --include='*.go' --exclude-dir=vendor . 2>/dev/null | grep -B 2 -iE 'delete|remove' | grep 'WriteHeader' | head -3 || true)"
[ -n "$D_200" ] && gate_info "$CAT" "$GATE" "DELETE retornando 200 (preferir 204 No Content)"

# POST que cria recurso mas retorna 200 (deveria ser 201)
[ -n "$GENERIC" ] && gate_info "$CAT" "$GATE" "500 generico - considerar categorizar (502 upstream, 503 busy, 504 timeout)"
gate_ok "$CAT" "$GATE"
