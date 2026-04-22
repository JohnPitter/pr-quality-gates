#!/usr/bin/env bash
# Exemption + threshold-override helpers: merge plugin defaults with
# project-local overrides.
#
# Plugin defaults live in $PLUGIN_DIR/config/thresholds.json.
# Project-local overrides (optional) live in $(pwd)/.pr-quality-gates.json.
#
# Both are JSON. Exemptions have shape { "exemptions": { "category": [...] } }.
# Thresholds are flat top-level keys (ccn_max, coverage_min, etc.).

# exemption_list <category>  e.g. exemption_list "god_structs"
exemption_list() {
  local category="$1"
  {
    jq -r --arg c "$category" '.exemptions[$c][]?' "$PLUGIN_DIR/config/thresholds.json" 2>/dev/null || true
    [ -f ".pr-quality-gates.json" ] && \
      jq -r --arg c "$category" '.exemptions[$c][]?' ".pr-quality-gates.json" 2>/dev/null || true
  } | sort -u
}

# threshold_get <key>  — returns the effective threshold value for <key>,
# preferring project-local override from .pr-quality-gates.json. Falls back
# to plugin default. Prints empty on miss.
#
# Use this in every gate instead of reading thresholds.json directly so users
# can tune thresholds per-project (critical for legacy-codebase adoption).
threshold_get() {
  local key="$1"
  local val=""
  if [ -f ".pr-quality-gates.json" ]; then
    val="$(jq -r --arg k "$key" '.[$k] // empty' ".pr-quality-gates.json" 2>/dev/null || true)"
  fi
  if [ -z "$val" ] || [ "$val" = "null" ]; then
    val="$(jq -r --arg k "$key" '.[$k] // empty' "$PLUGIN_DIR/config/thresholds.json" 2>/dev/null || true)"
  fi
  [ "$val" = "null" ] && val=""
  echo "$val"
}
