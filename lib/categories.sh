#!/usr/bin/env bash
# Category filter system for PR Quality Gates.
# Categories: security, quality, architecture, performance, reliability,
# observability, operational, data, testing, compliance, release.
#
# Selection:
#   PR_QUALITY_CATEGORIES=all                       -> run every gate
#   PR_QUALITY_CATEGORIES=security,reliability      -> subset
#   PR_QUALITY_CATEGORIES=core                      -> critical-blocker set
#                                                     (security + reliability + quality)
#
# Gates are discovered as gates/<category>/*.sh.

ALL_CATEGORIES=(
  security quality architecture performance reliability
  observability operational data testing compliance release
  api infrastructure documentation git-hygiene ai-ml
)

CORE_CATEGORIES=(security reliability quality)

# Returns the active category list based on PR_QUALITY_CATEGORIES env var
# or the config file default, one per line.
active_categories() {
  local raw="${PR_QUALITY_CATEGORIES:-}"

  if [ -z "$raw" ] && [ -n "${PLUGIN_DIR:-}" ] && [ -f "$PLUGIN_DIR/config/categories.json" ]; then
    raw="$(jq -r '.default // "core"' "$PLUGIN_DIR/config/categories.json" 2>/dev/null || echo core)"
  fi
  [ -z "$raw" ] && raw="core"

  case "$raw" in
    all)  printf '%s\n' "${ALL_CATEGORIES[@]}" ;;
    core) printf '%s\n' "${CORE_CATEGORIES[@]}" ;;
    *)    echo "$raw" | tr ',' '\n' | sed '/^$/d' ;;
  esac
}

# Iterates over gate scripts in selected categories, in deterministic order.
# Usage: run_gates <plugin_dir>
run_gates() {
  local plugin_dir="$1"
  local categories
  mapfile -t categories < <(active_categories)

  local total_fail=0 total_run=0 total_skip=0
  echo "=== PR Quality Gates - categorias: ${categories[*]} ==="

  for cat in "${categories[@]}"; do
    local dir="$plugin_dir/gates/$cat"
    if [ ! -d "$dir" ]; then
      echo "[warn] categoria desconhecida: $cat" >&2
      continue
    fi

    echo ""
    echo "--- Categoria: $cat ---"
    for gate in "$dir"/*.sh; do
      [ -f "$gate" ] || continue
      total_run=$((total_run + 1))
      if ! bash "$gate"; then
        total_fail=$((total_fail + 1))
      fi
    done
  done

  echo ""
  echo "=== Resumo: $total_run gates executados, $total_fail falharam ==="
  return "$total_fail"
}
