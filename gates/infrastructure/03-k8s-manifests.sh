#!/usr/bin/env bash
# Infrastructure 03: K8s manifests (resource limits, probes)
# Coverage: HEURISTIC
set -euo pipefail
PLUGIN_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
source "$PLUGIN_DIR/lib/common.sh"
GATE="k8s-manifests"; CAT="infrastructure"
gate_header "$CAT" "$GATE"

MANIFESTS="$(find . -type f \( -name "*.yaml" -o -name "*.yml" \) -not -path '*/vendor/*' -not -path '*/node_modules/*' 2>/dev/null | \
  xargs grep -l 'apiVersion:\s*apps/v1\|apiVersion:\s*v1$' 2>/dev/null | head -20 || true)"
[ -z "$MANIFESTS" ] && { gate_ok "$CAT" "$GATE" "sem manifests k8s"; exit 0; }

ISSUES=()
for m in $MANIFESTS; do
  grep -qE '^kind:\s*(Deployment|StatefulSet|DaemonSet)' "$m" || continue
  grep -qE 'resources:\s*$|limits:|requests:' "$m" || ISSUES+=("$m: sem resources.limits/requests")
  grep -qE 'livenessProbe:' "$m" || ISSUES+=("$m: sem livenessProbe")
  grep -qE 'readinessProbe:' "$m" || ISSUES+=("$m: sem readinessProbe")
done

if [ "${#ISSUES[@]}" -gt 0 ]; then
  gate_fail "$CAT" "$GATE" "${#ISSUES[@]} problema(s) em manifests:"
  for i in "${ISSUES[@]}"; do echo "  - $i"; done | head -10
  exit 1
fi
gate_ok "$CAT" "$GATE"
