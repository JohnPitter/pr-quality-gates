#!/usr/bin/env bash
# API 06: GraphQL depth/complexity limits
# Coverage: HEURISTIC
set -euo pipefail
PLUGIN_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
source "$PLUGIN_DIR/lib/common.sh"
GATE="graphql-limits"; CAT="api"
gate_header "$CAT" "$GATE"

HAS_GQL="$(grep -rE 'graphql-go|gqlgen|graphql\.' --include='*.go' --exclude-dir=vendor . 2>/dev/null | head -1 || true)"
[ -z "$HAS_GQL" ] && { gate_ok "$CAT" "$GATE" "sem GraphQL"; exit 0; }

HAS_LIMIT="$(grep -rE 'depth|complexity|MaxDepth|MaxComplexity' --include='*.go' --exclude-dir=vendor . 2>/dev/null | head -1 || true)"
if [ -z "$HAS_LIMIT" ]; then
  gate_fail "$CAT" "$GATE" "GraphQL sem depth/complexity limit (risco DoS)"
  echo "  sugestao: gqlgen FixedComplexityLimit ou ast.NewLimiter"
  exit 1
fi
gate_ok "$CAT" "$GATE"
