#!/bin/bash

set -eu -o pipefail

GTNH_VERSION='2.7.4'
GTNH_VARIANT='Java_17-21'

REPO_PREFIX="ghcr.io/icanwalkonwater"
IMAGE_NAME="minecraft-gtnh"
IMAGE_TAG="$GTNH_VERSION-java21"

docker build \
  --build-arg GTNH_VERSION="$GTNH_VERSION" \
  --build-arg GTNH_VARIANT="$GTNH_VARIANT" \
  --label org.opencontainers.image.source=https://github.com/icanwalkonwater/homelab \
  -t "$IMAGE_NAME:$IMAGE_TAG" \
  -t "$IMAGE_NAME:latest" \
  -t "$REPO_PREFIX/$IMAGE_NAME:$IMAGE_TAG" \
  -t "$REPO_PREFIX/$IMAGE_NAME:latest" \
  ./image

docker push "$REPO_PREFIX/$IMAGE_NAME:$IMAGE_TAG"
docker push "$REPO_PREFIX/$IMAGE_NAME:latest"
