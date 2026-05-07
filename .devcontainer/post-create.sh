#!/usr/bin/env bash
# post-create.sh — runs once when the devcontainer is first created.
# Installs the latest GitHub Copilot CLI, .NET Aspire workload, Data API Builder, and verifies all tool versions.

set -uo pipefail

echo "=== Post-create: Agentic Coding Workshop ==="

# ── GitHub Copilot CLI (standalone binary) ───────────────────────────────────
echo ""
echo "Installing latest GitHub Copilot CLI..."
COPILOT_URL="https://github.com/github/copilot-cli/releases/latest/download/copilot-linux-x64.tar.gz"
COPILOT_TEMP=$(mktemp -d)
COPILOT_BIN_DIR="$HOME/.local/bin"
mkdir -p "$COPILOT_BIN_DIR"
if curl -fsSL "$COPILOT_URL" -o "$COPILOT_TEMP/copilot.tar.gz" 2>&1; then
  tar -xzf "$COPILOT_TEMP/copilot.tar.gz" -C "$COPILOT_TEMP" && \
  mv "$COPILOT_TEMP/copilot" "$COPILOT_BIN_DIR/copilot" && \
  chmod +x "$COPILOT_BIN_DIR/copilot" && \
  echo "✓ GitHub Copilot CLI installed to $COPILOT_BIN_DIR/copilot" || echo "⚠ Copilot CLI extraction/install failed"
  rm -rf "$COPILOT_TEMP"
else
  echo "⚠ GitHub Copilot CLI download failed - check network/permissions"
  rm -rf "$COPILOT_TEMP"
fi
command -v copilot &>/dev/null && echo "✓ copilot binary verified on PATH" || echo "⚠ copilot binary not on PATH"

# ── .NET Aspire workload ──────────────────────────────────────────────────────
echo ""
echo "Installing .NET Aspire workload..."
if dotnet workload install aspire 2>&1; then
  echo "✓ Aspire workload installed"
elif dotnet workload update 2>&1; then
  echo "✓ Aspire workload updated"
else
  echo "⚠ Aspire workload install failed - continuing"
fi

# ── Data API Builder (DAB) ────────────────────────────────────────────────────
echo ""
echo "Installing Data API Builder (DAB)..."
if dotnet tool install --global microsoft.dataapibuilder 2>&1; then
  echo "✓ DAB installed"
elif dotnet tool update --global microsoft.dataapibuilder 2>&1; then
  echo "✓ DAB updated"
else
  echo "⚠ DAB install failed - continuing"
fi

# Ensure global tools are on PATH for this shell session
export PATH="$PATH:$HOME/.local/bin:$HOME/.dotnet/tools"

# ── pip baseline ─────────────────────────────────────────────────────────────
echo ""
echo "Upgrading pip..."
python3 -m pip install --upgrade pip || echo "⚠ pip upgrade failed - continuing"

# ── Version verification ──────────────────────────────────────────────────────
echo ""
echo "=== Environment summary ==="
echo -n "Python:  "; python3 --version
echo -n ".NET:    "; dotnet --version
echo -n "DAB:     "; dab --version 2>/dev/null || echo "(run 'dab --version' after opening a new terminal)"
echo -n "Copilot: "; copilot --version 2>/dev/null || echo "(not installed - run: gh auth login)"
echo -n "Docker:  "; docker --version 2>/dev/null || echo "(not available)"
echo ""
echo "=== Post-create complete ==="
echo ""
echo "NOTE: Copilot CLI requires GitHub authentication. Run: gh auth login"
