#!/usr/bin/env bash
# Reliability 10: Goroutine leak patterns
# Coverage: HEURISTIC - go func() sem mecanismo de cancelamento visivel
set -euo pipefail
PLUGIN_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
source "$PLUGIN_DIR/lib/common.sh"
GATE="goroutine-leak"; CAT="reliability"
gate_header "$CAT" "$GATE"

# go func() que nao recebe ctx e nao tem canal de cancelamento
BAD=""
while IFS= read -r -d '' f; do
  [[ "$f" == *"_test.go" ]] && continue
  [[ "$f" == *"/vendor/"* ]] && continue
  # Cheap heuristic: any "go func()" without "ctx" or "done" or "quit" in same function
  awk '
    /^func/ {fn=$0; has_go=0; has_cancel=0; fndone=0; next}
    /go func\(/ {has_go=1}
    /ctx\.|<-done|<-quit|<-stop|<-cancel/ {has_cancel=1}
    /^}/ && fn && !fndone {
      if (has_go && !has_cancel) print FILENAME ":" fn
      fndone=1; has_go=0; has_cancel=0
    }
  ' "$f" 2>/dev/null
done < <(find . -name "*.go" -print0 2>/dev/null) | head -10 > /tmp/gorl 2>/dev/null || true
BAD="$(cat /tmp/gorl 2>/dev/null || true)"
rm -f /tmp/gorl

if [ -n "$BAD" ]; then
  gate_info "$CAT" "$GATE" "goroutines sem cancelamento visivel (heuristica):"
  echo "$BAD" | head -8 | sed 's/^/  /'
fi
gate_ok "$CAT" "$GATE"
