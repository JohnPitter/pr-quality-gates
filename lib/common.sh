#!/usr/bin/env bash
# Shared bootstrap for all gates.
# Ensures jq (or gojq as drop-in replacement) is available before running,
# and exposes baseline (ratchet) helpers.
set -euo pipefail

# Load baseline helpers (no-op if not used by the gate)
# shellcheck source=./baseline.sh
source "$(dirname "${BASH_SOURCE[0]}")/baseline.sh"

# Load category filter helpers
# shellcheck source=./categories.sh
source "$(dirname "${BASH_SOURCE[0]}")/categories.sh"

# PLUGIN_DIR convenience (2 levels up from lib/common.sh)
PLUGIN_DIR="${PLUGIN_DIR:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}"
export PLUGIN_DIR

# gate_header <category> <name> [threshold_desc]
gate_header() {
  local cat="$1" name="$2" thr="${3:-}"
  if [ -n "$thr" ]; then
    echo "[$cat:$name] $thr"
  else
    echo "[$cat:$name] running..."
  fi
}

# gate_ok <category> <name> [detail]
gate_ok() {
  local cat="$1" name="$2" detail="${3:-OK}"
  echo "[$cat:$name] $detail"
}

# gate_fail <category> <name> <reason>
gate_fail() {
  echo "[$1:$2] FAIL - $3"
}

# gate_info <category> <name> <msg>  (non-blocking, heuristic coverage)
gate_info() {
  echo "[$1:$2] INFO - $3"
}

# If real jq is present, nothing to do.
if command -v jq >/dev/null 2>&1; then
  return 0 2>/dev/null || exit 0
fi

# Fallback: install gojq (pure Go, same query syntax and flags).
# Requires Go, which all other gates already need.
if command -v gojq >/dev/null 2>&1; then
  jq() { gojq "$@"; }
  export -f jq
  return 0 2>/dev/null || exit 0
fi

if ! command -v go >/dev/null 2>&1; then
  echo "[pr-quality-gates] ERROR: neither jq nor gojq found, and Go is not installed." >&2
  echo "  Install jq (https://stedolan.github.io/jq/) or install Go and rerun." >&2
  exit 1
fi

echo "[pr-quality-gates] installing gojq (jq substitute, pure Go)..." >&2
if ! go install github.com/itchyny/gojq/cmd/gojq@latest >&2; then
  echo "[pr-quality-gates] ERROR: failed to install gojq. Install jq manually." >&2
  exit 1
fi

# Ensure GOBIN (or GOPATH/bin) is on PATH for this session.
GOBIN_DIR="$(go env GOBIN 2>/dev/null || true)"
[ -z "$GOBIN_DIR" ] && GOBIN_DIR="$(go env GOPATH)/bin"
case ":$PATH:" in
  *":$GOBIN_DIR:"*) ;;
  *) export PATH="$GOBIN_DIR:$PATH" ;;
esac

if ! command -v gojq >/dev/null 2>&1; then
  echo "[pr-quality-gates] ERROR: gojq installed but not on PATH. Expected: $GOBIN_DIR" >&2
  exit 1
fi

jq() { gojq "$@"; }
export -f jq
