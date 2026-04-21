#!/usr/bin/env bash
# Infrastructure 02: Dockerfile best practices (no :latest, multi-stage, .dockerignore)
# Coverage: FULL (hadolint se disponivel)
set -euo pipefail
PLUGIN_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
source "$PLUGIN_DIR/lib/common.sh"
GATE="dockerfile-hardening"; CAT="infrastructure"
gate_header "$CAT" "$GATE"

DFS="$(find . -maxdepth 3 -type f -name "Dockerfile*" -not -path '*/vendor/*' 2>/dev/null || true)"
[ -z "$DFS" ] && { gate_ok "$CAT" "$GATE" "sem Dockerfile"; exit 0; }

ISSUES=()
for df in $DFS; do
  grep -qE '^FROM\s+\S+:latest' "$df" && ISSUES+=("$df: usando tag :latest")
  grep -qE '^FROM\s+\S+$' "$df" && ISSUES+=("$df: FROM sem tag")
  STAGES="$(grep -cE '^FROM' "$df" || echo 0)"
  [ "$STAGES" = "1" ] && grep -qE 'go build|npm build|mvn' "$df" && ISSUES+=("$df: single-stage com build (binario final gigante)")
done

# .dockerignore presente quando tem Dockerfile
[ -n "$DFS" ] && [ ! -f .dockerignore ] && ISSUES+=(".dockerignore ausente (Docker context vai incluir .git, node_modules, etc)")

if [ "${#ISSUES[@]}" -gt 0 ]; then
  gate_fail "$CAT" "$GATE" "${#ISSUES[@]} problema(s) no Dockerfile:"
  for i in "${ISSUES[@]}"; do echo "  - $i"; done
  exit 1
fi

# hadolint se instalado
if command -v hadolint >/dev/null 2>&1; then
  for df in $DFS; do hadolint "$df" 2>&1 | head -5; done
fi
gate_ok "$CAT" "$GATE"
