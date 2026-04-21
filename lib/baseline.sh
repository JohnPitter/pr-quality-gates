#!/usr/bin/env bash
# Baseline (ratchet) support for PR Quality Gates.
#
# Idea: freeze the current list of violations, then only fail on NEW ones.
# Allows adoption on legacy codebases without the first PR needing a full
# refactor. As refactors happen, baseline shrinks; no regression allowed.
#
# Design decisions:
# - Baseline lives in the consumer repo at .pr-quality-gates-baseline/<gate>.txt
# - One violation signature per line; unordered; grep -vFxf for set difference
# - Signatures are normalized per gate (CCN number stripped so refactors
#   that lower complexity don't re-flag the same function)
# - Baseline is capture-by-gate: running `baseline_mode_active` tells the
#   gate to WRITE its current violations instead of checking

# Default baseline dir, overridable via env
: "${BASELINE_DIR:=.pr-quality-gates-baseline}"

# Returns 0 if PR_QUALITY_BASELINE=1 (baseline-freeze mode).
baseline_mode_active() {
  [ "${PR_QUALITY_BASELINE:-0}" = "1" ]
}

# Returns 0 if PR_QUALITY_FULL=1 (ignore baseline, audit everything).
baseline_ignored() {
  [ "${PR_QUALITY_FULL:-0}" = "1" ]
}

# Returns 0 if a baseline file exists for the given gate AND
# the caller hasn't asked to ignore it.
# Usage: baseline_exists "ccn"
baseline_exists() {
  local gate="$1"
  baseline_ignored && return 1
  [ -f "$BASELINE_DIR/$gate.txt" ]
}

# Writes signatures from stdin to the baseline file for the given gate.
# Usage: echo "$signatures" | baseline_capture "ccn"
baseline_capture() {
  local gate="$1"
  mkdir -p "$BASELINE_DIR"
  sort -u > "$BASELINE_DIR/$gate.txt"
  local count
  count="$(wc -l < "$BASELINE_DIR/$gate.txt" | tr -d ' ')"
  echo "[baseline:$gate] captured $count violation(s) -> $BASELINE_DIR/$gate.txt" >&2
}

# Filters stdin, removing lines whose signatures are in the baseline.
# Input: lines of "signature<TAB>original_violation"
# Output: only the original_violation parts whose signature is NEW.
# Usage: cat violations_with_sigs | baseline_filter "ccn"
baseline_filter() {
  local gate="$1"
  local baseline_file="$BASELINE_DIR/$gate.txt"

  # Full-audit mode: ignore baseline, report everything.
  if baseline_ignored; then
    cut -f2-
    return
  fi

  if [ ! -f "$baseline_file" ]; then
    # No baseline -> everything is a violation
    cut -f2-
    return
  fi

  # Read signatures from baseline into a temp; emit only new ones
  local tmp
  tmp="$(mktemp)"
  trap 'rm -f "$tmp"' RETURN

  while IFS=$'\t' read -r sig rest; do
    if ! grep -qFx "$sig" "$baseline_file"; then
      printf '%s\n' "$rest"
    fi
  done
}
