#!/usr/bin/env bash
# Compliance 02: Audit trail
# Coverage: HEURISTIC
set -euo pipefail
PLUGIN_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
source "$PLUGIN_DIR/lib/common.sh"
GATE="audit-trail"; CAT="compliance"
gate_header "$CAT" "$GATE"

HAS_AUDIT="$(grep -rE 'audit_log|AuditLog|audit\.' --include='*.go' --include='*.sql' --exclude-dir=vendor -i . 2>/dev/null | head -1 || true)"
[ -z "$HAS_AUDIT" ] && gate_info "$CAT" "$GATE" "nenhuma infra de audit log detectada"
gate_ok "$CAT" "$GATE"
