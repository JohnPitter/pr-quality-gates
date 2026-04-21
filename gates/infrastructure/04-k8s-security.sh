#!/usr/bin/env bash
# Infrastructure 04: K8s securityContext
# Coverage: HEURISTIC
set -euo pipefail
PLUGIN_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
source "$PLUGIN_DIR/lib/common.sh"
GATE="k8s-security"; CAT="infrastructure"
gate_header "$CAT" "$GATE"

MANIFESTS="$(find . -type f \( -name "*.yaml" -o -name "*.yml" \) -not -path '*/vendor/*' 2>/dev/null | \
  xargs grep -l 'kind:\s*Deployment\|kind:\s*StatefulSet' 2>/dev/null | head -20 || true)"
[ -z "$MANIFESTS" ] && { gate_ok "$CAT" "$GATE" "sem Deployments"; exit 0; }

ISSUES=()
for m in $MANIFESTS; do
  grep -qE 'privileged:\s*true' "$m" && ISSUES+=("$m: privileged: true (nunca fazer em prod)")
  grep -qE 'runAsUser:\s*0' "$m" && ISSUES+=("$m: runAsUser: 0 (root)")
  grep -qE 'securityContext:' "$m" || ISSUES+=("$m: sem securityContext")
done

if [ "${#ISSUES[@]}" -gt 0 ]; then
  gate_fail "$CAT" "$GATE" "${#ISSUES[@]} violacao(oes) de security:"
  for i in "${ISSUES[@]}"; do echo "  - $i"; done | head -10
  exit 1
fi
gate_ok "$CAT" "$GATE"
