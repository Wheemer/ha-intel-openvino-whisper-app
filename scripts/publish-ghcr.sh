#!/usr/bin/env bash
set -Eeuo pipefail

VERSION="${VERSION:-0.1.0}"
ARCH="${ARCH:-amd64}"
IMAGE_BASE="${IMAGE_BASE:-ghcr.io/wheemer}"
IMAGE="${IMAGE_BASE}/${ARCH}-app-intel-openvino-whisper:${VERSION}"

docker push "${IMAGE}"

echo "Published ${IMAGE}"
