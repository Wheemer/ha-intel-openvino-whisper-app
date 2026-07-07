#!/usr/bin/env bash
set -Eeuo pipefail

VERSION="${VERSION:-0.1.0}"
ARCH="${ARCH:-amd64}"
IMAGE_BASE="${IMAGE_BASE:-ghcr.io/wheemer}"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
APP_DIR="${REPO_ROOT}/intel_openvino_whisper"
IMAGE="${IMAGE_BASE}/${ARCH}-app-intel-openvino-whisper:${VERSION}"

docker build \
    --build-arg "BUILD_VERSION=${VERSION}" \
    --build-arg "BUILD_ARCH=${ARCH}" \
    -t "${IMAGE}" \
    "${APP_DIR}"

echo "Built ${IMAGE}"
