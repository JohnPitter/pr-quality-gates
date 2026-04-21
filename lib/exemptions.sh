#!/usr/bin/env bash
# Exemption helpers: merge plugin defaults with project-local overrides.
#
# Plugin defaults live in $PLUGIN_DIR/config/thresholds.json.
# Project-local overrides (optional) live in $(pwd)/.pr-quality-gates.json.
# Both are JSON with the shape { "exemptions": { "category": [...] } }.
# exemption_list returns the merged list for a category on stdout, one per line.

# exemption_list <category>  e.g. exemption_list "god_structs"
exemption_list() {
  local category="$1"
  {
    jq -r --arg c "$category" '.exemptions[$c][]?' "$PLUGIN_DIR/config/thresholds.json" 2>/dev/null || true
    [ -f ".pr-quality-gates.json" ] && \
      jq -r --arg c "$category" '.exemptions[$c][]?' ".pr-quality-gates.json" 2>/dev/null || true
  } | sort -u
}
