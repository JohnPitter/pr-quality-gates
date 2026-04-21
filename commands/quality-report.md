---
description: Run all 8 PR quality gates and explain any failures with refactor suggestions.
allowed-tools: Bash
---

## Context

Run the complete 8-gate quality suite from the pr-quality-gates plugin:

!`bash "${CLAUDE_PLUGIN_ROOT}/hooks/pr-check.sh" 2>&1 || true`

## Your task

For each gate that failed:

1. Summarize the violation in 1 line (file, metric, current value vs threshold)
2. Suggest a concrete refactor action (extract function, split file, invert dependency, rotate secret, upgrade dep)
3. Prioritize violations by impact (high / medium / low) based on:
   - Size of the affected file/function
   - Criticality of the module (domain layer > infra > utils)
   - Security severity (secrets/CVEs/SAST always HIGH)
   - Regression risk

At the end, list the passing gates in one line each. Do not elaborate on passing gates.

If all 8 pass, report: "All 8 gates OK — PR ready for review."
