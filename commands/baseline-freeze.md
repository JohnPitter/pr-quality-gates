---
description: Freeze current violations as baseline. Only NEW violations will fail afterwards. Works on gates that support ratchet mode (CCN, module-size).
allowed-tools: Bash
---

## Context

Captures current violations to `.pr-quality-gates-baseline/`. Subsequent runs only fail on new violations. The baseline list can shrink (as refactors land) but never grow.

!`cd "$(pwd)" && PR_QUALITY_BASELINE=1 bash "${CLAUDE_PLUGIN_ROOT}/gates/quality/01-ccn.sh" 2>&1 || true`
!`cd "$(pwd)" && PR_QUALITY_BASELINE=1 bash "${CLAUDE_PLUGIN_ROOT}/gates/quality/04-module-size.sh" 2>&1 || true`
!`ls -la .pr-quality-gates-baseline/ 2>&1 || echo "(no baseline dir created)"`

## Your task

Report:
1. Baseline files created and violation counts
2. Remind to commit `.pr-quality-gates-baseline/` to the repo
3. Short note: "Baseline should shrink over time, never grow."

Keep under 10 lines.
