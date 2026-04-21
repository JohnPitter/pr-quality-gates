#!/usr/bin/env bash
# Operational 05: Feature flags em features novas
# Coverage: HEURISTIC
set -euo pipefail
PLUGIN_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
source "$PLUGIN_DIR/lib/common.sh"
GATE="feature-flags"; CAT="operational"
gate_header "$CAT" "$GATE"

HAS_FF="$(grep -rE 'featureflag|feature_flag|flipt|launchdarkly|unleash|growthbook' --include='*.go' --exclude-dir=vendor -i . 2>/dev/null | head -1 || true)"
[ -z "$HAS_FF" ] && gate_info "$CAT" "$GATE" "nenhum feature flag framework detectado (LaunchDarkly, GrowthBook, Unleash, Flipt)"
gate_ok "$CAT" "$GATE"
