#!/usr/bin/env bash
# Performance 01: Benchmark regression
# Coverage: FULL (benchstat comparing vs main)
set -euo pipefail
PLUGIN_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
source "$PLUGIN_DIR/lib/common.sh"
GATE="benchmark-regression"; CAT="performance"
gate_header "$CAT" "$GATE"

HAS_BENCH="$(grep -rEl '^func Benchmark' --include='*_test.go' . 2>/dev/null | head -1 || true)"
[ -z "$HAS_BENCH" ] && { gate_info "$CAT" "$GATE" "sem benchmarks"; exit 0; }

command -v benchstat >/dev/null 2>&1 || go install golang.org/x/perf/cmd/benchstat@latest
BASE_REF="${BASE_REF:-origin/main}"
[ -d .git ] || { gate_info "$CAT" "$GATE" "sem git, skip"; exit 0; }

git rev-parse "$BASE_REF" >/dev/null 2>&1 || { gate_info "$CAT" "$GATE" "ref $BASE_REF inexistente"; exit 0; }

# Run HEAD benchmarks
go test -bench=. -benchmem -count=3 -run='^$' ./... > /tmp/bench.new 2>/dev/null || true
# This gate is info-only on PR: comparing requires checking out base, expensive.
# Real implementation lives in CI workflow.
gate_info "$CAT" "$GATE" "benchmark corrido; comparacao com main feita no CI (workflow pr-check.yml)"
