#!/usr/bin/env bash
# Architecture 07: Package cohesion
# Coverage: HEURISTIC - detecta pacotes com muitos arquivos nao relacionados
set -euo pipefail
PLUGIN_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
source "$PLUGIN_DIR/lib/common.sh"
GATE="cohesion"; CAT="architecture"
gate_header "$CAT" "$GATE"

# Heuristic: package with >20 .go files is a cohesion smell
BIG=""
while IFS= read -r dir; do
  [[ "$dir" == *"/vendor"* ]] && continue
  count="$(find "$dir" -maxdepth 1 -name "*.go" -not -name "*_test.go" 2>/dev/null | wc -l | tr -d ' ')"
  [ "$count" -gt 20 ] && BIG+="  $dir: $count arquivos"$'\n'
done < <(find . -type d -not -path '*/vendor/*' -not -path '*/\.*' 2>/dev/null)

if [ -n "$BIG" ]; then
  gate_info "$CAT" "$GATE" "pacote(s) grande(s) - baixa coesao provavel:"
  echo -n "$BIG"
fi
gate_ok "$CAT" "$GATE"
