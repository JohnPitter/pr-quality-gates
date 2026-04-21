#!/usr/bin/env bash
# Compliance 04: Consent tracking
# Coverage: HEURISTIC
set -euo pipefail
PLUGIN_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
source "$PLUGIN_DIR/lib/common.sh"
GATE="consent-tracking"; CAT="compliance"
gate_header "$CAT" "$GATE"

HAS_CONSENT="$(grep -rE 'consent|opt.in|opt.out' --include='*.go' --include='*.sql' --exclude-dir=vendor -i . 2>/dev/null | head -1 || true)"
[ -z "$HAS_CONSENT" ] && gate_info "$CAT" "$GATE" "nenhum consent tracking - requisito LGPD/GDPR se processa PII"
gate_ok "$CAT" "$GATE"
