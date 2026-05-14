#!/usr/bin/env bash
set -u

# Quick verification of build-time and runtime workshop tooling.

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

check_version() {
  local label="$1"
  shift
  if output=$("$@" 2>/dev/null | head -n 1); then
    pass "$label version: $output"
  else
    fail "$label version check failed"
  fi
}

echo "=== Devcontainer smoke-check ==="

check_cmd dab "Data API Builder (dab)"
check_cmd aspire "Aspire CLI"
check_cmd copilot "GitHub Copilot CLI"
check_cmd potrace "Potrace"
check_cmd bwrap "Bubblewrap"
check_cmd python3.14 "Python 3.14"
check_cmd dotnet ".NET SDK"

if [[ -x .venv-linux/bin/python3 ]]; then
  pass ".venv-linux exists"
  check_version ".venv-linux Python" .venv-linux/bin/python3 --version
else
  warn ".venv-linux not found (run post-create or rebuild container)"
fi

if [[ -f src/requirements.txt ]] && [[ -x .venv-linux/bin/python3 ]]; then
  if .venv-linux/bin/python3 -m pip check >/dev/null 2>&1; then
    pass "pip dependency check passed in .venv-linux"
  else
    warn "pip dependency check reported issues in .venv-linux"
  fi
fi

check_version "dab" dab --version
check_version "aspire" aspire --version
check_version "copilot" copilot --version
check_version "potrace" potrace --version
check_version "bwrap" bwrap --version
check_version "python3.14" python3.14 --version
check_version "dotnet" dotnet --version

echo ""
echo "Summary: PASS=$pass_count WARN=$warn_count FAIL=$fail_count"

if [[ $fail_count -gt 0 ]]; then
  exit 1
fi

exit 0
