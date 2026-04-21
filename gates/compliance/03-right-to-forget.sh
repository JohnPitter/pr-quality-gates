#!/usr/bin/env bash
# Compliance 03: Right to be forgotten (LGPD/GDPR)
# Coverage: HEURISTIC
set -euo pipefail
PLUGIN_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
source "$PLUGIN_DIR/lib/common.sh"
GATE="right-to-forget"; CAT="compliance"
gate_header "$CAT" "$GATE"

HAS_USER_TABLE="$(grep -rE 'CREATE TABLE.*(users|accounts)' --include='*.sql' -i . 2>/dev/null | head -1 || true)"
[ -z "$HAS_USER_TABLE" ] && { gate_ok "$CAT" "$GATE" "sem tabelas de usuario"; exit 0; }

HAS_DELETE="$(grep -rE 'DeleteUser|Forget|Anonymize' --include='*.go' --exclude-dir=vendor . 2>/dev/null | head -1 || true)"
[ -z "$HAS_DELETE" ] && gate_info "$CAT" "$GATE" "tabela de usuarios detectada sem funcao de delete/anonymize"
gate_ok "$CAT" "$GATE"
