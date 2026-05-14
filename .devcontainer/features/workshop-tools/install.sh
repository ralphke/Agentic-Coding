#!/usr/bin/env bash
set -euo pipefail

export DEBIAN_FRONTEND=noninteractive

echo "[workshop-tools] Installing apt dependencies..."
apt-get update
apt-get install -y --no-install-recommends \
  bubblewrap \
  potrace \
  python3-pil
rm -rf /var/lib/apt/lists/*

echo "[workshop-tools] Installing Data API Builder (dab) to /usr/local/bin..."
if dotnet tool install --tool-path /usr/local/bin microsoft.dataapibuilder; then
  echo "[workshop-tools] dab installed"
elif dotnet tool update --tool-path /usr/local/bin microsoft.dataapibuilder; then
  echo "[workshop-tools] dab updated"
else
  echo "[workshop-tools] WARNING: Failed to install or update dab"
fi

echo "[workshop-tools] Installing Aspire CLI..."
if curl -fsSL https://aspire.dev/install.sh | bash -s -- --skip-path; then
  # The installer drops the binary under $HOME/.aspire/bin (root when Feature runs).
  # Copying to /usr/local/bin makes it accessible to all users (symlink would break
  # because /root/ is not readable by the vscode user at runtime).
  ASPIRE_SRC="$(find /root/.aspire /home -name aspire -type f 2>/dev/null | head -1 || true)"
  if [[ -x "$ASPIRE_SRC" ]]; then
    cp "$ASPIRE_SRC" /usr/local/bin/aspire
    chmod +x /usr/local/bin/aspire
    echo "[workshop-tools] Aspire CLI copied to /usr/local/bin/aspire"
  else
    echo "[workshop-tools] WARNING: aspire binary not found after install"
  fi
else
  echo "[workshop-tools] WARNING: Aspire CLI install failed"
fi

echo "[workshop-tools] Installing GitHub Copilot CLI..."
COPILOT_URL="https://github.com/github/copilot-cli/releases/latest/download/copilot-linux-x64.tar.gz"
TMP_DIR="$(mktemp -d)"
if curl -fsSL "$COPILOT_URL" -o "$TMP_DIR/copilot.tar.gz" \
  && tar -xzf "$TMP_DIR/copilot.tar.gz" -C "$TMP_DIR" \
  && mv "$TMP_DIR/copilot" /usr/local/bin/copilot \
  && chmod +x /usr/local/bin/copilot; then
  echo "[workshop-tools] Copilot CLI installed"
else
  echo "[workshop-tools] WARNING: Copilot CLI install failed"
fi
rm -rf "$TMP_DIR"

echo "[workshop-tools] Build-time tool installation complete"
