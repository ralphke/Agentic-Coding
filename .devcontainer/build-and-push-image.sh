#!/bin/bash
# Build and push the private devcontainer image to GHCR
# Usage: ./build-and-push-image.sh [tag]
# Example: ./build-and-push-image.sh latest

set -e

REGISTRY="ghcr.io"
OWNER="ralphke"
REPO="agentic-coding-image"
TAG="${1:-latest}"
IMAGE="${REGISTRY}/${OWNER}/${REPO}:${TAG}"

echo "Building devcontainer image: $IMAGE"
docker build -f .devcontainer/Dockerfile -t "$IMAGE" .

echo "Authenticating with GHCR (ensure you're logged in with: docker login ghcr.io)"
docker push "$IMAGE"

echo "Successfully pushed $IMAGE"
echo "To use this image in devcontainer.json, change 'build' to 'image': \"$IMAGE\""
