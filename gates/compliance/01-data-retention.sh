#!/usr/bin/env bash
# Compliance 01: Data retention policy
# Coverage: HEURISTIC
set -euo pipefail
PLUGIN_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
source "$PLUGIN_DIR/lib/common.sh"
GATE="data-retention"; CAT="compliance"
gate_header "$CAT" "$GATE"

HAS_DB="$(find . -name "*.sql" -not -path './vendor/*' 2>/dev/null | head -1 || true)"
[ -z "$HAS_DB" ] && { gate_ok "$CAT" "$GATE" "sem SQL migrations"; exit 0; }

HAS_PURGE="$(grep -rE 'retention|purge|DELETE.*WHERE.*created_at|cleanup' --include='*.go' --include='*.sql' --exclude-dir=vendor -i . 2>/dev/null | head -1 || true)"
[ -z "$HAS_PURGE" ] && gate_info "$CAT" "$GATE" "nenhuma rotina de purge/retention detectada"
gate_ok "$CAT" "$GATE"
