---
description: Run all 8 quality gates ignoring the baseline. Reports the TOTAL technical debt, not just new violations.
allowed-tools: Bash
---

## Context

Full audit — runs the complete 8-gate suite with `PR_QUALITY_FULL=1`, which disables the baseline/ratchet filter. Every violation is reported, including those that were frozen via `/pr-quality-gates:baseline-freeze`.

Use this to:
- See the total technical debt in the codebase
- Plan refactor sprints (which files/functions to tackle first)
- Verify baseline still matches reality after big changes

!`cd "$(pwd)" && PR_QUALITY_FULL=1 bash "${CLAUDE_PLUGIN_ROOT}/hooks/pr-check.sh" 2>&1 || true`

## Your task

Produce a technical debt report organized by gate:

1. **Per gate with failures:** count of violations, top 5 worst offenders (highest CCN / largest file / most severe CVE / etc), and a 1-line refactor strategy
2. **Prioritization matrix:** group violations into High / Medium / Low based on:
   - Severity (secrets/SAST HIGH > CVEs > architecture > CCN > size)
   - Criticality of the affected module (domain > infra > tests)
   - Refactor effort vs impact ratio
3. **Suggested sprint scope:** pick 3-5 violations that give the biggest quality improvement per hour of work
4. **Delta vs baseline:** if `.pr-quality-gates-baseline/` exists, mention how many violations are baselined vs how many would be new today

Keep it actionable — this is a planning document, not an inventory.
