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
CONFIG_BUILD_TEMPLATE=".devcontainer/devcontainer-build.json"
CONFIG_PREBUILT=".devcontainer/devcontainer-prebuilt.json"
CONFIG_ACTIVE=".devcontainer/devcontainer.json"

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
    [ -f .devcontainer/devcontainer.json.bak ] && rm -f .devcontainer/devcontainer.json.bak
    [ -f "$CONFIG_ACTIVE" ] && mv "$CONFIG_ACTIVE" .devcontainer/devcontainer.json.bak
    cp "$CONFIG_PREBUILT" "$CONFIG_ACTIVE"
    echo "✓ devcontainer.json now pulls from GHCR: ghcr.io/ralphke/agentic-coding-image:latest"
    echo "  (schema-valid explicit configuration, no extends)"
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
  devcontainer-build.json      Local-build template (schema-valid)
  devcontainer-prebuilt.json   Pre-built-image template (schema-valid)
  devcontainer.json            Active config copied from one of the templates
  devcontainer.local.json      Optional local-mount variant (schema-valid)

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
