#!/usr/bin/env bash
# API 07: gRPC proto backwards compat
# Coverage: HEURISTIC (buf check opcional)
set -euo pipefail
PLUGIN_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
source "$PLUGIN_DIR/lib/common.sh"
GATE="grpc-compat"; CAT="api"
gate_header "$CAT" "$GATE"

PROTOS="$(find . -name "*.proto" -not -path '*/vendor/*' 2>/dev/null | head -1 || true)"
[ -z "$PROTOS" ] && { gate_ok "$CAT" "$GATE" "sem .proto"; exit 0; }

if command -v buf >/dev/null 2>&1; then
  if [ -f buf.yaml ] && git rev-parse origin/main >/dev/null 2>&1; then
    if ! buf breaking --against '.git#branch=origin/main' 2>&1 | head -10; then
      gate_fail "$CAT" "$GATE" "breaking change em proto detectado"
      exit 1
    fi
  fi
fi
gate_ok "$CAT" "$GATE"
