#!/usr/bin/env bash
# post-create.sh — runs once when the devcontainer is first created.
# Installs the GitHub Copilot CLI, Aspire CLI, Data API Builder, and verifies all tool versions.

set -uo pipefail

echo "=== Post-create: Agentic Coding Workshop ==="

# ── PATH setup (early, so all installed tools are immediately visible) ────────
export PATH="$PATH:$HOME/.local/bin:$HOME/.dotnet/tools:$HOME/.aspire/bin"

# ── GitHub Copilot CLI (standalone binary) ───────────────────────────────────
echo ""
echo "Installing latest GitHub Copilot CLI..."
COPILOT_URL="https://github.com/github/copilot-cli/releases/latest/download/copilot-linux-x64.tar.gz"
COPILOT_TEMP=$(mktemp -d)
COPILOT_BIN_DIR="$HOME/.local/bin"
mkdir -p "$COPILOT_BIN_DIR"
if curl -fsSL "$COPILOT_URL" -o "$COPILOT_TEMP/copilot.tar.gz"; then
  if tar -xzf "$COPILOT_TEMP/copilot.tar.gz" -C "$COPILOT_TEMP" && \
     mv "$COPILOT_TEMP/copilot" "$COPILOT_BIN_DIR/copilot" && \
     chmod +x "$COPILOT_BIN_DIR/copilot"; then
    echo "✓ GitHub Copilot CLI installed to $COPILOT_BIN_DIR/copilot"
  else
    echo "⚠ Copilot CLI extraction/install failed"
  fi
  rm -rf "$COPILOT_TEMP"
else
  echo "⚠ GitHub Copilot CLI download failed - check network/permissions"
  rm -rf "$COPILOT_TEMP"
fi
command -v copilot &>/dev/null && echo "✓ copilot binary verified on PATH" || echo "⚠ copilot binary not on PATH"

# ── .NET Aspire CLI ───────────────────────────────────────────────────────────
echo ""
echo "Installing Aspire CLI..."
if curl -sSL https://aspire.dev/install.sh | bash -s -- --skip-path 2>&1; then
  echo "✓ Aspire CLI installed"
else
  echo "⚠ Aspire CLI install failed - continuing"
fi
command -v aspire &>/dev/null && echo "✓ aspire verified on PATH" || echo "⚠ aspire not on PATH (check ~/.aspire/bin)"

# ── Data API Builder (DAB) ────────────────────────────────────────────────────
echo ""
echo "Installing Data API Builder (DAB)..."
if dotnet tool install --global microsoft.dataapibuilder 2>/dev/null; then
  echo "✓ DAB installed"
elif dotnet tool update --global microsoft.dataapibuilder 2>/dev/null; then
  echo "✓ DAB updated"
else
  echo "⚠ DAB install failed - continuing"
fi

# ── potrace (for PNG to SVG vectorization) ───────────────────────────────────
echo ""
echo "Installing potrace for diagram vectorization..."
if command -v potrace &>/dev/null; then
  echo "✓ potrace already installed"
elif sudo apt-get update && sudo apt-get install -y potrace; then
  echo "✓ potrace installed"
else
  echo "⚠ potrace install failed - continuing (convert2svg.py will use fallback)"
fi

# ── bubblewarp (for rootless container functionality) ──────────────────────
echo ""
echo "Installing bubblewarp for rootless containers..."
if command -v bwrap &>/dev/null; then
  echo "✓ bubblewarp already installed"
elif sudo apt-get update && sudo apt-get install -y bubblewrap; then
  echo "✓ bubblewrap installed"
else
  echo "⚠ bubblewrap install failed - continuing"
fi

# ── Pillow (for PNG loading in convert2svg.py) ───────────────────────────────
echo ""
echo "Installing Pillow for PNG image processing..."
if python3 -c 'from PIL import Image' 2>/dev/null; then
  echo "✓ Pillow already available"
elif sudo apt-get update && sudo apt-get install -y python3-pil; then
  echo "✓ Pillow installed"
else
  echo "⚠ Pillow install failed - convert2svg.py will not be able to import PIL"
fi

# ── Python 3.14 virtual environment (.venv-linux) ────────────────────────────
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
  "$VENV_DIR/bin/pip" install -r "$REPO_ROOT/src/requirements.txt" --quiet || echo "⚠ requirements install in venv failed"
  echo "✓ .venv-linux ready. Activate with: source .venv-linux/bin/activate"
else
  echo "⚠ python3.14 not found — skipping .venv-linux creation"
fi

# ── Version verification ──────────────────────────────────────────────────────
echo ""
echo "=== Environment summary ==="
echo -n "Python:  "; python3.14 --version 2>/dev/null || python3 --version
echo -n ".venv-linux: "; [ -f "$VENV_DIR/bin/python3" ] && "$VENV_DIR/bin/python3" --version || echo "(not created)"
echo -n ".NET:    "; dotnet --version
echo -n "DAB:     "; dab --version 2>/dev/null || echo "(run 'dab --version' after opening a new terminal)"
echo -n "Aspire:  "; aspire --version 2>/dev/null || echo "(not found - check ~/.aspire/bin)"
echo -n "Copilot: "; copilot --version 2>/dev/null || echo "(not installed - run: gh auth login)"
echo -n "Potrace: "; potrace --version 2>/dev/null || echo "(not installed)"
echo -n "Bubblewrap: "; bwrap --version 2>/dev/null || echo "(not installed)"
echo -n "Docker:  "; docker --version 2>/dev/null || echo "(not available)"
echo ""
echo "=== Post-create complete ==="
echo ""
echo "NOTE: Copilot CLI requires GitHub authentication. Run: gh auth login"
