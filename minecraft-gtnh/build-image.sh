#!/bin/bash

set -eu -o pipefail

GTNH_VERSION='2.7.4'
GTNH_VARIANT='Java_17-21'

IMAGE_REPO="ghcr.io/icanwalkonwater"
IMAGE_NAME="minecraft-gtnh"
IMAGE_TAG_REV="1"

IMAGE_TAG="$GTNH_VERSION-java21-rev$IMAGE_TAG_REV"

docker build \
  --build-arg GTNH_VERSION="$GTNH_VERSION" \
  --build-arg GTNH_VARIANT="$GTNH_VARIANT" \
  --label org.opencontainers.image.source=https://github.com/icanwalkonwater/homelab \
  -t "$IMAGE_NAME:$IMAGE_TAG" \
  -t "$IMAGE_NAME:latest" \
  -t "$IMAGE_REPO/$IMAGE_NAME:$IMAGE_TAG" \
  -t "$IMAGE_REPO/$IMAGE_NAME:latest" \
  ./image

docker push "$IMAGE_REPO/$IMAGE_NAME:$IMAGE_TAG"
docker push "$IMAGE_REPO/$IMAGE_NAME:latest"
