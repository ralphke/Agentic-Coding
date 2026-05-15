#!/usr/bin/env bash
# post-create.sh — runs once when the devcontainer is first created.
# Performs workspace-specific setup only.

set -u
if (set -o pipefail) >/dev/null 2>&1; then
  set -o pipefail
fi

echo "=== Post-create: Agentic Coding Workshop ==="

# PATH additions for user-scoped and workspace tooling.
export PATH="$PATH:$HOME/.local/bin:$HOME/.dotnet/tools:$HOME/.aspire/bin"

# Python 3.14 virtual environment (.venv-linux).
echo ""
echo "Creating .venv-linux with Python 3.14..."
REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
VENV_DIR="$REPO_ROOT/.venv-linux"
PYTHON314="$(command -v python3.14 2>/dev/null || true)"
if [ -z "$PYTHON314" ]; then
  PYTHON314="$(find /usr/local/python -name 'python3.14' -type f 2>/dev/null | head -1 || true)"
fi
if [ -n "$PYTHON314" ]; then
  echo "Using Python 3.14 at: $PYTHON314"
  "$PYTHON314" -m venv "$VENV_DIR" && echo "✓ .venv-linux created at $VENV_DIR" || echo "⚠ venv creation failed"
  echo "Upgrading pip in .venv-linux..."
  "$VENV_DIR/bin/pip" install --upgrade pip --quiet || echo "⚠ pip upgrade in venv failed"
  echo "Installing Python requirements into .venv-linux..."
  "$VENV_DIR/bin/pip" install -r "$REPO_ROOT/src/requirements-dev.txt" --quiet || echo "⚠ requirements install in venv failed"
  echo "✓ .venv-linux ready. Activate with: source .venv-linux/bin/activate"
else
  echo "⚠ python3.14 not found — skipping .venv-linux creation"
fi

# Version verification.
echo ""
echo "=== Environment summary ==="
echo -n "Python:  "; python3.14 --version 2>/dev/null || python3 --version
echo -n ".venv-linux: "; [ -f "$VENV_DIR/bin/python3" ] && "$VENV_DIR/bin/python3" --version || echo "(not created)"
echo -n ".NET:    "; dotnet --version
echo -n "DAB:     "; dab --version 2>/dev/null || echo "(not found)"
echo -n "Aspire:  "; aspire --version 2>/dev/null || echo "(not found)"
echo -n "Copilot: "; copilot --version 2>/dev/null || echo "(not found)"
echo -n "Potrace: "; potrace --version 2>/dev/null || echo "(not installed)"
echo -n "Bubblewrap: "; bwrap --version 2>/dev/null || echo "(not installed)"
echo -n "Docker:  "; docker --version 2>/dev/null || echo "(not available)"
echo ""
echo "=== Post-create complete ==="
echo ""
echo "NOTE: Copilot CLI requires GitHub authentication. Run: gh auth login"
