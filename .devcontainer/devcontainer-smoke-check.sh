#!/usr/bin/env bash
set -uo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

pass_count=0
fail_count=0
warn_count=0

pass() {
  echo "[PASS] $1"
  pass_count=$((pass_count + 1))
}

fail() {
  echo "[FAIL] $1"
  fail_count=$((fail_count + 1))
}

warn() {
  echo "[WARN] $1"
  warn_count=$((warn_count + 1))
}

check_cmd() {
  local cmd="$1"
  local label="$2"
  if command -v "$cmd" >/dev/null 2>&1; then
    pass "$label found at $(command -v "$cmd")"
  else
    fail "$label not found on PATH"
  fi
}

check_tool() {
  local cmd="$1"
  local label="$2"
  shift
  shift

  if ! command -v "$cmd" >/dev/null 2>&1; then
    fail "$label not found on PATH"
    return
  fi

  pass "$label found at $(command -v "$cmd")"
  if output=$("$@" 2>&1 | head -n 1) && [[ -n "$output" ]]; then
    pass "$label version: $output"
  else
    fail "$label version check failed"
  fi
}

echo "=== Devcontainer smoke-check ==="

check_tool dab "Data API Builder (dab)" dab --version
check_tool aspire "Aspire CLI" aspire --version
check_tool copilot "GitHub Copilot CLI" copilot --version
check_tool potrace "Potrace" potrace --version
check_tool bwrap "Bubblewrap" bwrap --version
check_tool trivy "Trivy" trivy --version
check_tool node "Node.js" node --version
check_tool npx "npx" npx --version
check_tool openspec "OpenSpec CLI" openspec --version
check_tool python3.14 "Python 3.14" python3.14 --version
check_tool dotnet ".NET SDK" dotnet --version
check_tool docker "Docker" docker --version

if [[ -x .venv-linux/bin/python3 ]]; then
  pass ".venv-linux exists"
  check_tool .venv-linux/bin/python3 ".venv-linux Python" .venv-linux/bin/python3 --version
else
  warn ".venv-linux not found (run post-create or rebuild container)"
fi

if [[ -f src/requirements-dev.txt ]] && [[ -x .venv-linux/bin/python3 ]]; then
  if .venv-linux/bin/python3 -m pip check >/dev/null 2>&1; then
    pass "pip dependency check passed in .venv-linux"
  else
    warn "pip dependency check reported issues in .venv-linux"
  fi
fi

if command -v docker >/dev/null 2>&1; then
  if output=$(docker scout version 2>&1 | tail -n 1) && [[ -n "$output" ]]; then
    pass "Docker Scout version: $output"
  else
    fail "Docker Scout version check failed"
  fi
fi

echo ""
echo "Summary: PASS=$pass_count WARN=$warn_count FAIL=$fail_count"

if [[ $fail_count -gt 0 ]]; then
  exit 1
fi

exit 0
