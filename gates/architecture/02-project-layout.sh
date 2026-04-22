#!/usr/bin/env bash
# Architecture 02: Standard project layout
# Coverage: HEURISTIC - valida presenca de cmd/ ou internal/ (golden path Go)
set -euo pipefail
PLUGIN_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
source "$PLUGIN_DIR/lib/common.sh"
GATE="project-layout"; CAT="architecture"
gate_header "$CAT" "$GATE"
[ -f go.mod ] || { gate_info "$CAT" "$GATE" "sem go.mod"; exit 0; }

ISSUES=()
# Single-file module is fine for CLI tools; more files should use structure
FILE_COUNT="$(find . -maxdepth 2 -name "*.go" -not -path "./vendor/*" 2>/dev/null | wc -l | tr -d ' ')"
if [ "$FILE_COUNT" -gt 5 ]; then
  [ -d cmd ] || [ -d internal ] || [ -d pkg ] || ISSUES+=("projeto com $FILE_COUNT arquivos mas sem cmd/, internal/ ou pkg/")
fi

# Detect top-level .go files (besides main.go) which should be in packages.
# Override via .pr-quality-gates.json -> project_layout_max_top_files (default 3).
# Desktop/Wails apps legitimately need bindings at the root for framework exposure.
TOP_GO="$(find . -maxdepth 1 -name "*.go" -not -name "main.go" -not -name "*_test.go" 2>/dev/null | wc -l | tr -d ' ')"
LIMIT_TOP="$(threshold_get project_layout_max_top_files)"
[ -z "$LIMIT_TOP" ] && LIMIT_TOP=3
[ "$TOP_GO" -gt "$LIMIT_TOP" ] && ISSUES+=("$TOP_GO arquivos .go no root (exceto main.go) - mover pra pacote (max=$LIMIT_TOP)")

if [ "${#ISSUES[@]}" -gt 0 ]; then
  gate_fail "$CAT" "$GATE" "layout nao-padrao:"
  for i in "${ISSUES[@]}"; do echo "  - $i"; done
  echo "  padrao: cmd/<name>/main.go + internal/<packages>/"
  exit 1
fi
gate_ok "$CAT" "$GATE"
