---
description: Run core quality gates (security + reliability + quality) and explain failures.
allowed-tools: Bash
---

## Context

Runs the **core** category (~23 gates): security (10) + reliability (15) + quality (4). These are the blockers — fast, deterministic, high-signal.

**Token cost:** ~3-8k tokens depending on failures. For full audit (67 gates), use `/pr-quality-gates:full-audit`. For a single category, use `/pr-quality-gates:category-report <name>`.

!`cd "$(pwd)" && PR_QUALITY_CATEGORIES=core bash "${CLAUDE_PLUGIN_ROOT}/hooks/pr-check.sh" 2>&1 || true`

## Your task

For each failing gate:
1. Summarize the violation in 1 line
2. Suggest a concrete refactor (extract function, add timeout, wrap error with %w, rotate secret)
3. Prioritize by impact (high = security/reliability breakers, medium = architecture, low = style)

Treat `[INFO]` lines as advisory — do not report them as failures. If all core gates pass, report: "Core gates OK — PR ready for review. Run `/pr-quality-gates:full-audit` for broader check."
