#!/usr/bin/env bash
set -euo pipefail

export DEBIAN_FRONTEND=noninteractive

echo "[workshop-tools] Installing apt dependencies..."
apt-get update
apt-get install -y --no-install-recommends \
  ca-certificates \
  bubblewrap \
  gnupg \
  lsb-release \
  potrace \
  python3-pil \
  rsync \
  wget

# Ensure rsync is upgraded to the latest patched package to address CVE-2026-29518 and CVE-2026-43618.
apt-get install -y --only-upgrade rsync

echo "[workshop-tools] Installing Trivy..."
wget -qO - https://aquasecurity.github.io/trivy-repo/deb/public.key \
  | gpg --dearmor -o /usr/share/keyrings/trivy.gpg
echo "deb [signed-by=/usr/share/keyrings/trivy.gpg] https://aquasecurity.github.io/trivy-repo/deb $(lsb_release -sc) main" \
  > /etc/apt/sources.list.d/trivy.list
apt-get update
apt-get install -y --no-install-recommends trivy
rm -rf /var/lib/apt/lists/*

INSTALL_DAB="${FEATURE_WORKSHOP_TOOLS_INSTALLDAB:-${FEATURE_WORKSHOP_TOOLS_INSTALL_DAB:-true}}"
INSTALL_ASPIRE="${FEATURE_WORKSHOP_TOOLS_INSTALLASPIRE:-${FEATURE_WORKSHOP_TOOLS_INSTALL_ASPIRE:-true}}"
INSTALL_COPILOT="${FEATURE_WORKSHOP_TOOLS_INSTALLCOPILOT:-${FEATURE_WORKSHOP_TOOLS_INSTALL_COPILOT:-true}}"

if [ "$INSTALL_DAB" = "false" ] || [ "$INSTALL_DAB" = "0" ]; then
  echo "[workshop-tools] Skipping Data API Builder installation"
else
  echo "[workshop-tools] Installing Data API Builder (dab) to /usr/local/bin..."
  if dotnet tool install --tool-path /usr/local/bin microsoft.dataapibuilder; then
    echo "[workshop-tools] dab installed"
  elif dotnet tool update --tool-path /usr/local/bin microsoft.dataapibuilder; then
    echo "[workshop-tools] dab updated"
  else
    echo "[workshop-tools] WARNING: Failed to install or update dab"
  fi
fi

if [ "$INSTALL_ASPIRE" = "false" ] || [ "$INSTALL_ASPIRE" = "0" ]; then
  echo "[workshop-tools] Skipping Aspire CLI installation"
else
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
fi

if [ "$INSTALL_COPILOT" = "false" ] || [ "$INSTALL_COPILOT" = "0" ]; then
  echo "[workshop-tools] Skipping GitHub Copilot CLI installation"
else
  echo "[workshop-tools] Installing GitHub Copilot CLI..."
  COPILOT_URL="https://github.com/github/copilot-cli/releases/latest/download/copilot-linux-x64.tar.gz"
  TMP_DIR="$(mktemp -d)"
  if curl -fsSL "$COPILOT_URL" -o "$TMP_DIR/copilot.tar.gz" \
    && tar -xzf "$TMP_DIR/copilot.tar.gz" -C "$TMP_DIR" \
    && mv "$TMP_DIR/copilot" /usr/local/bin/copilot \
    && chmod +x /usr/local/bin/copilot; then
    echo "[workshop-tools] Copilot CLI installed"
    echo "[workshop-tools] Running Copilot CLI self-update..."
    if /usr/local/bin/copilot update; then
      echo "[workshop-tools] Copilot CLI updated"
    else
      echo "[workshop-tools] WARNING: Copilot CLI update failed"
    fi
  else
    echo "[workshop-tools] WARNING: Copilot CLI install failed"
  fi
  rm -rf "$TMP_DIR"
fi

echo "[workshop-tools] Build-time tool installation complete"
