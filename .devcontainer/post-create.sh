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

# ── pip baseline ─────────────────────────────────────────────────────────────
echo ""
echo "Upgrading pip..."
python3 -m pip install --upgrade pip --break-system-packages || echo "⚠ pip upgrade failed - continuing"

# ── Version verification ──────────────────────────────────────────────────────
echo ""
echo "=== Environment summary ==="
echo -n "Python:  "; python3 --version
echo -n ".NET:    "; dotnet --version
echo -n "DAB:     "; dab --version 2>/dev/null || echo "(run 'dab --version' after opening a new terminal)"
echo -n "Aspire:  "; aspire --version 2>/dev/null || echo "(not found - check ~/.aspire/bin)"
echo -n "Copilot: "; copilot --version 2>/dev/null || echo "(not installed - run: gh auth login)"
echo -n "Docker:  "; docker --version 2>/dev/null || echo "(not available)"
echo ""
echo "=== Post-create complete ==="
echo ""
echo "NOTE: Copilot CLI requires GitHub authentication. Run: gh auth login"
