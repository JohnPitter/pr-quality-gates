#!/usr/bin/env bash
# Architecture 04: Dependency injection discipline
# Coverage: HEURISTIC - detecta anti-patterns: http.DefaultClient, log.Default, init() com side effects
set -euo pipefail
PLUGIN_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
source "$PLUGIN_DIR/lib/common.sh"
GATE="di-discipline"; CAT="architecture"
gate_header "$CAT" "$GATE"

ISSUES=()

# Global mutable state = DI smell
GLOBALS="$(grep -rn -E '^var [a-z][A-Za-z0-9]* \*?(sql\.DB|http\.Client|log\.Logger|redis\.Client)' --include='*.go' --exclude-dir=vendor . 2>/dev/null | head -10 || true)"
[ -n "$GLOBALS" ] && ISSUES+=("globals mutaveis:\n$GLOBALS")

# http.DefaultClient usage (no timeout, no configuration)
DEFC="$(grep -rn 'http\.DefaultClient' --include='*.go' --exclude-dir=vendor . 2>/dev/null | head -5 || true)"
[ -n "$DEFC" ] && ISSUES+=("http.DefaultClient (sem timeout):\n$DEFC")

# log.Default / log.Printf / log.Println (package-level logger)
LOGDEF="$(grep -rn -E '^\s*(log\.(Printf|Println|Print|Fatal|Panic))' --include='*.go' --exclude-dir=vendor . 2>/dev/null | head -5 || true)"
[ -n "$LOGDEF" ] && ISSUES+=("log package-level (sem DI):\n$LOGDEF")

# init() with side effects (network, DB, file writes)
INITSE="$(grep -rn -B1 -A5 '^func init()' --include='*.go' --exclude-dir=vendor . 2>/dev/null | grep -E '(http\.|sql\.|os\.(Create|WriteFile)|net\.)' | head -5 || true)"
[ -n "$INITSE" ] && ISSUES+=("init() com side effects (I/O):\n$INITSE")

if [ "${#ISSUES[@]}" -gt 0 ]; then
  gate_fail "$CAT" "$GATE" "${#ISSUES[@]} violacao(oes) de DI:"
  for i in "${ISSUES[@]}"; do printf '  %s\n' "$i" | head -6; done
  exit 1
fi
gate_ok "$CAT" "$GATE"
