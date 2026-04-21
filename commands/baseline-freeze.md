---
description: Freeze the current state of violations as a baseline. Subsequent runs only fail on NEW violations.
allowed-tools: Bash
---

## Context

Capture the current state of CCN and module-size violations into `.pr-quality-gates-baseline/`. After this, gates 1 and 4 will only fail on NEW violations added in future PRs.

!`cd "$(pwd)" && PR_QUALITY_BASELINE=1 bash "${CLAUDE_PLUGIN_ROOT}/gates/01-ccn.sh" 2>&1 || true`
!`cd "$(pwd)" && PR_QUALITY_BASELINE=1 bash "${CLAUDE_PLUGIN_ROOT}/gates/04-module-size.sh" 2>&1 || true`
!`ls -la .pr-quality-gates-baseline/ 2>&1 || echo "(no baseline dir created)"`

## Your task

Report:

1. Which baseline files were created and how many violations each contains
2. A reminder to commit the `.pr-quality-gates-baseline/` directory to the repo (it's the shared technical debt ledger)
3. A short next-step suggestion: "Open an issue to track CCN refactors — baseline should shrink over time, never grow."

Keep it under 10 lines.
