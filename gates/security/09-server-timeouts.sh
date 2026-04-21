#!/usr/bin/env bash
# Security 09: Server timeouts (slow-loris protection)
# Coverage: HEURISTIC
set -euo pipefail
PLUGIN_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
source "$PLUGIN_DIR/lib/common.sh"
GATE="server-timeouts"; CAT="security"
gate_header "$CAT" "$GATE"

# http.Server literal without timeouts is vulnerable to slow-loris
BAD="$(grep -rE 'http\.Server\s*\{' --include='*.go' -A 10 . 2>/dev/null | grep -B 1 -A 10 'http.Server{' | grep -L -E 'ReadTimeout|WriteTimeout|IdleTimeout' || true)"
VULN="$(grep -rEl 'http\.Server\s*\{' --include='*.go' . 2>/dev/null || true)"
if [ -n "$VULN" ]; then
  for f in $VULN; do
    # Check if file has timeout configured
    if ! grep -qE 'ReadTimeout|ReadHeaderTimeout|WriteTimeout' "$f" 2>/dev/null; then
      gate_fail "$CAT" "$GATE" "http.Server sem timeouts (slow-loris)"
      echo "  $f"
      echo "  adicionar: ReadHeaderTimeout, ReadTimeout, WriteTimeout, IdleTimeout"
      exit 1
    fi
  done
fi
# http.ListenAndServe uses DefaultServeMux which has no timeouts
if grep -rE 'http\.ListenAndServe\(' --include='*.go' . 2>/dev/null | head -1 | grep -qE 'ListenAndServe\('; then
  gate_fail "$CAT" "$GATE" "http.ListenAndServe sem http.Server configurado (DefaultServeMux = sem timeouts)"
  exit 1
fi
gate_ok "$CAT" "$GATE"
