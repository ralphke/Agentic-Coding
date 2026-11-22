#!/bin/bash
# Manage devcontainer image lifecycle: build, push, and switch between configurations
# Usage: ./devcontainer-workflow.sh [command] [args]
# Commands:
#   build [tag]         Build image locally (default tag: latest)
#   push [tag]          Push to GHCR (requires docker login ghcr.io)
#   build-and-push [tag] Build locally then push to GHCR
#   use-local           Switch devcontainer.json to build from Dockerfile
#   use-prebuilt        Switch devcontainer.json to pull from GHCR
#   use-wslc            Switch to the Docker-free WSL container configuration

set -e

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

REGISTRY="ghcr.io"
OWNER="ralphke"
REPO="agentic-coding-image"
DOCKERFILE=".devcontainer/Dockerfile"
CONFIG_BUILD_TEMPLATE=".devcontainer/devcontainer-build.json"
CONFIG_PREBUILT=".devcontainer/devcontainer-prebuilt.json"
CONFIG_WSLC=".devcontainer/devcontainer-wslc.json"
CONFIG_ACTIVE=".devcontainer/devcontainer.json"

select_engine() {
  case "${DEVCONTAINER_ENGINE:-docker}" in
    docker) ENGINE="docker" ;;
    wslc)
      if command -v wslc >/dev/null 2>&1; then
        ENGINE="wslc"
      else
        ENGINE="wslc.exe"
      fi
      ;;
    *)
      echo "Unsupported DEVCONTAINER_ENGINE: ${DEVCONTAINER_ENGINE}. Use docker or wslc." >&2
      exit 1
      ;;
  esac
  if ! command -v "$ENGINE" >/dev/null 2>&1; then
    echo "Container engine not found: $ENGINE" >&2
    exit 1
  fi
}

build() {
  local tag="${1:-latest}"
  local image="${REGISTRY}/${OWNER}/${REPO}:${tag}"
  
  echo "Building image: $image"
  "$ENGINE" build -f "$DOCKERFILE" -t "$image" .
  echo "✓ Build complete: $image"
}

push() {
  local tag="${1:-latest}"
  local image="${REGISTRY}/${OWNER}/${REPO}:${tag}"
  
  if ! "$ENGINE" image inspect "$image" &>/dev/null; then
    echo "✗ Image not found locally: $image"
    echo "  Run 'bash .devcontainer/devcontainer-workflow.sh build $tag' first"
    exit 1
  fi
  
  echo "Pushing image: $image"
  "$ENGINE" push "$image"
  echo "✓ Push complete: $image"
}

build_and_push() {
  local tag="${1:-latest}"
  build "$tag"
  push "$tag"
  echo "✓ Build and push complete for tag: $tag"
}

use_local() {
  echo "Switching to local build mode..."
  if [ -f "$CONFIG_BUILD_TEMPLATE" ]; then
    [ -f .devcontainer/devcontainer.json.bak ] && rm -f .devcontainer/devcontainer.json.bak
    [ -f "$CONFIG_ACTIVE" ] && mv "$CONFIG_ACTIVE" .devcontainer/devcontainer.json.bak
    cp "$CONFIG_BUILD_TEMPLATE" "$CONFIG_ACTIVE"
    echo "✓ devcontainer.json now uses local Dockerfile build"
    echo "  (schema-valid explicit configuration, no extends)"
    echo "  Rebuild container in VS Code: Cmd+Shift+P > Dev Containers: Rebuild Container"
  else
    echo "✗ $CONFIG_BUILD_TEMPLATE not found"
    exit 1
  fi
}

use_prebuilt() {
  echo "Switching to pre-built image mode..."
  if [ -f "$CONFIG_PREBUILT" ]; then
    [ -f devcontainer.json.bak ] && rm -f devcontainer.json.bak
    [ -f "$CONFIG_ACTIVE" ] && mv "$CONFIG_ACTIVE" devcontainer.json.bak
    cp "$CONFIG_PREBUILT" "$CONFIG_ACTIVE"
    echo "✓ devcontainer.json now pulls from GHCR: ghcr.io/ralphke/agentic-coding-image:latest"
    echo "  (schema-valid explicit configuration, no extends)"
    echo "  Rebuild container in VS Code: Cmd+Shift+P > Dev Containers: Rebuild Container"
  else
    echo "✗ $CONFIG_PREBUILT not found"
    exit 1
  fi
}

use_wslc() {
  if [ ! -f "$CONFIG_WSLC" ]; then
    echo "✗ $CONFIG_WSLC not found" >&2
    exit 1
  fi
  if [ -f "$CONFIG_ACTIVE" ] && ! cmp -s "$CONFIG_ACTIVE" "$CONFIG_WSLC"; then
    if [ -e .devcontainer/devcontainer.json.bak ]; then
      echo "Backup already exists: .devcontainer/devcontainer.json.bak. Move it before switching." >&2
      exit 1
    fi
    cp "$CONFIG_ACTIVE" .devcontainer/devcontainer.json.bak
  fi
  cp "$CONFIG_WSLC" "$CONFIG_ACTIVE"
  echo "✓ devcontainer.json now uses the WSL container configuration"
  echo "  Set VS Code's Dev Containers: Docker Path to wslc and rebuild the container."
}

show_usage() {
  cat << EOF
devcontainer-workflow.sh - Manage devcontainer image lifecycle

Usage: ./devcontainer-workflow.sh [command] [args]

Commands:
  build [tag]         Build image locally (default: latest)
  push [tag]          Push to GHCR (requires engine login to ghcr.io)
  build-and-push [tag] Build and push to GHCR
  use-local           Switch to building from local Dockerfile
  use-prebuilt        Switch to pulling pre-built image from GHCR
  use-wslc            Switch to the Docker-free WSL container configuration

Set DEVCONTAINER_ENGINE=wslc to build and push with wslc instead of Docker.
The image stores and registry credentials of Docker and wslc are separate.

File Structure:
  devcontainer-build.json      Local-build template (schema-valid)
  devcontainer-prebuilt.json   Pre-built-image template (schema-valid)
  devcontainer.json            Active config copied from one of the templates
  devcontainer-wslc.json       WSL container template without a Docker socket

Examples:
  ./devcontainer-workflow.sh build latest
  ./devcontainer-workflow.sh build-and-push v1.0
  ./devcontainer-workflow.sh use-prebuilt

Workflow:
  1. First setup: ./devcontainer-workflow.sh use-local
    (devcontainer.json copied from devcontainer-build.json)
  2. Make changes to .devcontainer/Dockerfile
  3. Build and push: ./devcontainer-workflow.sh build-and-push latest
  4. Switch other machines: ./devcontainer-workflow.sh use-prebuilt
    (devcontainer.json copied from devcontainer-prebuilt.json)
EOF
}

case "${1}" in
  build)
    select_engine
    build "${2:-latest}"
    ;;
  push)
    select_engine
    push "${2:-latest}"
    ;;
  build-and-push)
    select_engine
    build_and_push "${2:-latest}"
    ;;
  use-local)
    use_local
    ;;
  use-prebuilt)
    use_prebuilt
    ;;
  use-wslc)
    use_wslc
    ;;
  *)
    show_usage
    exit 0
    ;;
esac
