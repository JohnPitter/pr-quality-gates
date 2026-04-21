---
description: Run ALL 67 gates across all 11 categories. High token cost — use sparingly.
allowed-tools: Bash
---

## Context

**TOKEN WARNING:** Full audit runs 67 gates across 11 categories. Output can be 10-30k tokens depending on violations found. Each violation the model explains costs additional tokens. Use this command for:
- Quarterly tech debt review
- Pre-release audit
- Planning refactor sprints
- After big architectural changes

For daily PRs, use `/pr-quality-gates:quality-report` (core only, ~3-8k tokens).

!`cd "$(pwd)" && PR_QUALITY_CATEGORIES=all PR_QUALITY_FULL=1 bash "${CLAUDE_PLUGIN_ROOT}/hooks/pr-check.sh" 2>&1 || true`

## Your task

Produce a technical debt report organized by category:

1. **Per category:** failure count, top 3 worst issues, 1-line refactor strategy per issue
2. **Prioritization matrix:** High/Medium/Low by severity (secrets/SAST HIGH > CVEs > reliability > architecture > style)
3. **Suggested sprint scope:** 5-10 violations with biggest quality-per-effort ratio
4. **Delta vs baseline:** if `.pr-quality-gates-baseline/` exists, mention baselined vs new

Treat `[INFO]` lines as advisory context, not failures. Keep actionable — this is a planning document.
