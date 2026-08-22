#!/usr/bin/env bash

set -euo pipefail

MODE="${1:-all}"

ROOT_DIR="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
cd "$ROOT_DIR"

collect_changed_files() {
  case "$MODE" in
    pre-commit)
      git diff --cached --name-only
      ;;
    pre-push)
      if git rev-parse --abbrev-ref --symbolic-full-name '@{upstream}' >/dev/null 2>&1; then
        git diff --name-only '@{upstream}'...HEAD
      else
        git diff --name-only HEAD~1..HEAD 2>/dev/null || git show --pretty='' --name-only HEAD
      fi
      ;;
    *)
      {
        git diff --name-only
        git diff --cached --name-only
        git ls-files --others --exclude-standard
      } | sort -u
      ;;
  esac
}

has_relevant_changes() {
  if printf '%s\n' "$CHANGED_FILES" | grep -Eq '^(spec/openspec/|.*requirements[^/]*\.txt$|.*package\.json$|.*\.csproj$|.*packages\.lock\.json$)'; then
    return 0
  fi
  return 1
}

validate_openspec_structure() {
  local missing=0
  for path in spec/openspec/config.yaml spec/openspec/specs spec/openspec/changes spec/openspec/changes/archive; do
    if [ ! -e "$path" ]; then
      echo "❌ Missing required OpenSPEC path: $path"
      missing=1
    fi
  done
  [ "$missing" -eq 0 ]
}

validate_change_folders() {
  local failed=0
  local dir slug

  while IFS= read -r dir; do
    [ -z "$dir" ] && continue
    if [ "$dir" = "spec/openspec/changes/archive" ]; then
      continue
    fi
    slug="$(basename "$dir")"

    if ! printf '%s' "$slug" | grep -Eq '^[a-z0-9]+(-[a-z0-9]+)*$'; then
      echo "❌ Invalid OpenSPEC change slug '$slug' in $dir"
      echo "   Slugs must be lowercase kebab-case."
      failed=1
    fi

    if [ ! -f "$dir/proposal.md" ]; then
      echo "❌ Missing required proposal.md in $dir"
      failed=1
    fi

    if [ -f "$dir/design.md" ] && [ ! -f "$dir/tasks.md" ]; then
      echo "❌ Missing tasks.md in $dir (design.md exists)"
      failed=1
    fi

    if [ -f "$dir/tasks.md" ] && [ ! -f "$dir/design.md" ]; then
      echo "❌ Missing design.md in $dir (tasks.md exists)"
      failed=1
    fi
  done < <(printf '%s\n' "$CHANGED_FILES" | grep -E '^spec/openspec/changes/[^/]+/' | cut -d/ -f1-4 | sort -u)

  [ "$failed" -eq 0 ]
}

validate_dependency_pinning() {
  local failed=0
  local req_file

  while IFS= read -r req_file; do
    [ -z "$req_file" ] && continue
    if [[ "$req_file" == *"dev"* ]] || [[ "$req_file" == *"test"* ]]; then
      continue
    fi

    if ! grep -q -- '--hash=' "$req_file"; then
      echo "❌ Production requirements file lacks hash pinning: $req_file"
      failed=1
    fi
    while IFS= read -r dep_line; do
      [ -z "$dep_line" ] && continue
      if ! printf '%s\n' "$dep_line" | grep -Eq '^[[:space:]]*[A-Za-z0-9_.-]+(\[[^]]+\])?==[^[:space:]]+'; then
        echo "❌ Unpinned dependency version found in $req_file: $dep_line"
        failed=1
      fi
    done < <(grep -Ev '^[[:space:]]*($|#|-)' "$req_file")
  done < <(printf '%s\n' "$CHANGED_FILES" | grep -E 'requirements[^/]*\.txt$' | sort -u)

  while IFS= read -r package_json; do
    [ -z "$package_json" ] && continue
    local pkg_dir
    pkg_dir="$(dirname "$package_json")"
    if [ ! -f "$pkg_dir/package-lock.json" ]; then
      echo "❌ Missing package-lock.json for $package_json"
      failed=1
    fi
  done < <(printf '%s\n' "$CHANGED_FILES" | grep -E 'package\.json$' | sort -u)

  while IFS= read -r csproj; do
    [ -z "$csproj" ] && continue
    local proj_dir
    proj_dir="$(dirname "$csproj")"
    if [ ! -f "$proj_dir/packages.lock.json" ]; then
      echo "❌ Missing packages.lock.json for $csproj"
      failed=1
    fi
  done < <(printf '%s\n' "$CHANGED_FILES" | grep -E '\.csproj$' | sort -u)

  [ "$failed" -eq 0 ]
}

CHANGED_FILES="$(collect_changed_files)"

if ! has_relevant_changes; then
  exit 0
fi

echo "Running OpenSPEC local validation ($MODE)..."
validate_openspec_structure
validate_change_folders
validate_dependency_pinning

echo "✅ OpenSPEC local validation passed"
