#!/usr/bin/env bash

set -euo pipefail

usage() {
  cat <<'EOF'
Usage: bootstrap-planned-repos.sh [options]

Create every 🔴 Planned repository listed in GENERATORS.md from a shared GitHub template repository.

Options:
  --owner OWNER                GitHub owner/org for the new repositories (default: opd-ai)
  --template-repo OWNER/REPO   GitHub template repository to copy from (default: opd-ai/untemplate)
  --visibility VISIBILITY      public, private, or internal (default: public)
  --repo NAME                  Limit execution to a specific repo name; may be repeated
  --dry-run                    Print the gh commands without creating anything
  -h, --help                   Show this help text
EOF
}

die() {
  echo "Error: $*" >&2
  exit 1
}

trim() {
  local value="$1"
  value="${value#"${value%%[![:space:]]*}"}"
  value="${value%"${value##*[![:space:]]}"}"
  printf '%s' "$value"
}

validate_visibility() {
  case "$1" in
    public|private|internal) ;;
    *) die "visibility must be one of: public, private, internal" ;;
  esac
}

should_process_repo() {
  local candidate="$1"

  if [[ "${#ONLY_REPOS[@]}" -eq 0 ]]; then
    return 0
  fi

  local selected
  for selected in "${ONLY_REPOS[@]}"; do
    if [[ "$selected" == "$candidate" ]]; then
      return 0
    fi
  done

  return 1
}

require_template_repo() {
  local is_template
  if ! is_template="$(gh api "repos/${TEMPLATE_REPO}" --jq '.is_template' 2>/dev/null)"; then
    die "unable to read template repo metadata for ${TEMPLATE_REPO}"
  fi

  if [[ "$is_template" != "true" ]]; then
    die "${TEMPLATE_REPO} is not marked as a GitHub template repository"
  fi
}

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd -- "${SCRIPT_DIR}/.." && pwd)"
GENERATORS_FILE="${REPO_ROOT}/GENERATORS.md"

OWNER="${OWNER:-opd-ai}"
TEMPLATE_REPO="${TEMPLATE_REPO:-opd-ai/unpeople}"
VISIBILITY="${VISIBILITY:-public}"
DRY_RUN=false
ONLY_REPOS=()

while [[ $# -gt 0 ]]; do
  case "$1" in
    --owner)
      [[ $# -ge 2 ]] || die "--owner requires a value"
      OWNER="$2"
      shift 2
      ;;
    --template-repo)
      [[ $# -ge 2 ]] || die "--template-repo requires a value"
      TEMPLATE_REPO="$2"
      shift 2
      ;;
    --visibility)
      [[ $# -ge 2 ]] || die "--visibility requires a value"
      VISIBILITY="$2"
      shift 2
      ;;
    --repo)
      [[ $# -ge 2 ]] || die "--repo requires a value"
      ONLY_REPOS+=("$2")
      shift 2
      ;;
    --dry-run)
      DRY_RUN=true
      shift
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      die "unknown argument: $1"
      ;;
  esac
done

[[ -f "$GENERATORS_FILE" ]] || die "missing ${GENERATORS_FILE}"
validate_visibility "$VISIBILITY"

if ! $DRY_RUN; then
  command -v gh >/dev/null 2>&1 || die "gh is required"
  gh auth status >/dev/null 2>&1 || die "gh is not authenticated"
  require_template_repo
fi

planned_rows="$(
  awk -F'|' '
    function trim_field(value) {
      gsub(/^[[:space:]]+|[[:space:]]+$/, "", value)
      return value
    }

    $0 ~ /^\| [0-9]+ / {
      repo = trim_field($4)
      status = trim_field($7)
      description = trim_field($8)

      if (status ~ /🔴 Planned/ && repo ~ /^[^[:space:]]+\/[^[:space:]]+$/) {
        split(repo, parts, "/")
        print parts[2] "|" description
      }
    }
  ' "$GENERATORS_FILE"
)"

[[ -n "$planned_rows" ]] || die "no planned repositories found in ${GENERATORS_FILE}"

created_count=0
skipped_count=0

while IFS='|' read -r repo_name description; do
  repo_name="$(trim "$repo_name")"
  description="$(trim "$description")"

  [[ -n "$repo_name" ]] || continue

  if ! should_process_repo "$repo_name"; then
    continue
  fi

  full_repo="${OWNER}/${repo_name}"
  create_command=(
    gh repo create "$full_repo"
    "--${VISIBILITY}"
    "--description" "$description"
    "--template" "$TEMPLATE_REPO"
  )

  if $DRY_RUN; then
    printf '[dry-run] '
    printf '%q ' "${create_command[@]}"
    printf '\n'
    created_count=$((created_count + 1))
    continue
  fi

  if gh repo view "$full_repo" >/dev/null 2>&1; then
    echo "Skipping existing repo: ${full_repo}"
    skipped_count=$((skipped_count + 1))
    continue
  fi

  echo "Creating ${full_repo} from ${TEMPLATE_REPO}"
  "${create_command[@]}"
  created_count=$((created_count + 1))
done <<< "$planned_rows"

echo "Done. Created ${created_count} repos; skipped ${skipped_count} existing repos."
