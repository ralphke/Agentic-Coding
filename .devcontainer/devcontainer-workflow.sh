#!/bin/bash
# Manage devcontainer image lifecycle: build, push, and switch between configurations
# Usage: ./devcontainer-workflow.sh [command] [args]
# Commands:
#   build [tag]         Build image locally (default tag: latest)
#   push [tag]          Push to GHCR (requires docker login ghcr.io)
#   build-and-push [tag] Build locally then push to GHCR
#   use-local           Switch devcontainer.json to build from Dockerfile
#   use-prebuilt        Switch devcontainer.json to pull from GHCR

set -e

REGISTRY="ghcr.io"
OWNER="ralphke"
REPO="agentic-coding-image"
DOCKERFILE=".devcontainer/Dockerfile"
CONFIG_BUILD=".devcontainer/devcontainer.json"
CONFIG_PREBUILT=".devcontainer/devcontainer-prebuilt.json"

build() {
  local tag="${1:-latest}"
  local image="${REGISTRY}/${OWNER}/${REPO}:${tag}"
  
  echo "Building image: $image"
  docker build -f "$DOCKERFILE" -t "$image" .
  echo "✓ Build complete: $image"
}

push() {
  local tag="${1:-latest}"
  local image="${REGISTRY}/${OWNER}/${REPO}:${tag}"
  
  if ! docker image inspect "$image" &>/dev/null; then
    echo "✗ Image not found locally: $image"
    echo "  Run './devcontainer-workflow.sh build $tag' first"
    exit 1
  fi
  
  echo "Pushing image: $image"
  docker push "$image"
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
  if [ -f "$CONFIG_BUILD" ]; then
    [ -f .devcontainer/devcontainer.json.bak ] && rm -f .devcontainer/devcontainer.json.bak
    [ -f .devcontainer/devcontainer.json ] && mv .devcontainer/devcontainer.json .devcontainer/devcontainer.json.bak
    cp "$CONFIG_BUILD" .devcontainer/devcontainer.json
    echo "✓ devcontainer.json now uses local Dockerfile build"
    echo "  (extends devcontainer-base.json + build mode)"
    echo "  Rebuild container in VS Code: Cmd+Shift+P > Dev Containers: Rebuild Container"
  else
    echo "✗ $CONFIG_BUILD not found"
    exit 1
  fi
}

use_prebuilt() {
  echo "Switching to pre-built image mode..."
  if [ -f "$CONFIG_PREBUILT" ]; then
    [ -f .devcontainer/devcontainer.json.bak ] && rm -f .devcontainer/devcontainer.json.bak
    [ -f .devcontainer/devcontainer.json ] && mv .devcontainer/devcontainer.json .devcontainer/devcontainer.json.bak
    cp "$CONFIG_PREBUILT" .devcontainer/devcontainer.json
    echo "✓ devcontainer.json now pulls from GHCR: ghcr.io/ralphke/agentic-coding-image:latest"
    echo "  (extends devcontainer-base.json + image mode)"
    echo "  Rebuild container in VS Code: Cmd+Shift+P > Dev Containers: Rebuild Container"
  else
    echo "✗ $CONFIG_PREBUILT not found"
    exit 1
  fi
}

show_usage() {
  cat << EOF
devcontainer-workflow.sh - Manage devcontainer image lifecycle

Usage: ./devcontainer-workflow.sh [command] [args]

Commands:
  build [tag]         Build image locally (default: latest)
  push [tag]          Push to GHCR (requires 'docker login ghcr.io')
  build-and-push [tag] Build and push to GHCR
  use-local           Switch to building from local Dockerfile
  use-prebuilt        Switch to pulling pre-built image from GHCR

File Structure:
  devcontainer-base.json       Shared configuration (features, extensions, ports)
  devcontainer.json            Active config (extends base + build mode)
  devcontainer-prebuilt.json   Template (extends base + image mode)
  devcontainer.local.json      Developer overrides (machine-local customization)

Examples:
  ./devcontainer-workflow.sh build latest
  ./devcontainer-workflow.sh build-and-push v1.0
  ./devcontainer-workflow.sh use-prebuilt

Workflow:
  1. First setup: ./devcontainer-workflow.sh use-local
     (devcontainer.json extends base.json + local Dockerfile build)
  2. Make changes to .devcontainer/Dockerfile
  3. Build and push: ./devcontainer-workflow.sh build-and-push latest
  4. Switch other machines: ./devcontainer-workflow.sh use-prebuilt
     (devcontainer.json extends base.json + pre-built GHCR image)
EOF
}

case "${1}" in
  build)
    build "${2:-latest}"
    ;;
  push)
    push "${2:-latest}"
    ;;
  build-and-push)
    build_and_push "${2:-latest}"
    ;;
  use-local)
    use_local
    ;;
  use-prebuilt)
    use_prebuilt
    ;;
  *)
    show_usage
    exit 0
    ;;
esac
