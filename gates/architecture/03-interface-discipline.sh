#!/usr/bin/env bash
# Architecture 03: Interface segregation (ISP)
# Coverage: HEURISTIC - detecta interfaces com >5 metodos
set -euo pipefail
PLUGIN_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
source "$PLUGIN_DIR/lib/common.sh"
GATE="interface-discipline"; CAT="architecture"
MAX="$(threshold_get interface_max_methods)"
[ -z "$MAX" ] && MAX=5
gate_header "$CAT" "$GATE" "max metodos/interface=$MAX"

VIOL=""
while IFS= read -r -d '' f; do
  [[ "$f" == *"_test.go" ]] && continue
  [[ "$f" == *"/vendor/"* ]] && continue
  awk -v max="$MAX" -v file="$f" '
    /^type [A-Z][A-Za-z0-9]* interface \{/ {name=$2; count=0; in=1; next}
    in && /^\}/ {if (count>max) printf "%s:%s (%d metodos, max %d)\n", file, name, count, max; in=0; next}
    in && /^[[:space:]]+[A-Z][A-Za-z0-9]*\(/ {count++}
  ' "$f"
done < <(find . -name "*.go" -print0 2>/dev/null) > /tmp/iface-viol 2>/dev/null || true

VIOL="$(cat /tmp/iface-viol 2>/dev/null || true)"
rm -f /tmp/iface-viol
if [ -n "$VIOL" ]; then
  gate_fail "$CAT" "$GATE" "interface(s) viola(m) ISP:"
  echo "$VIOL" | sed 's/^/  /' | head -20
  exit 1
fi
gate_ok "$CAT" "$GATE"
