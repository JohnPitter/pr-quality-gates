---
description: Run gates from a specific category (security, reliability, performance, architecture, observability, operational, data, testing, compliance, release, quality).
allowed-tools: Bash
argument-hint: <category>
---

## Context

Runs only the category passed as argument. Use when you want to focus on one theme without the token cost of a full audit.

**Categories available:** security, quality, architecture, performance, reliability, observability, operational, data, testing, compliance, release

**Token cost:** ~1-5k tokens depending on category size and violations.

!`cd "$(pwd)" && PR_QUALITY_CATEGORIES="$ARGUMENTS" bash "${CLAUDE_PLUGIN_ROOT}/hooks/pr-check.sh" 2>&1 || true`

## Your task

For the selected category only:
1. List failures with 1-line explanation and suggested fix
2. List `[INFO]` items separately as "advisory notes" (not blocking)
3. Summary: how many gates passed / failed / info

If category is invalid, point to the list of valid categories above.
