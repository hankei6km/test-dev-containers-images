#!/bin/bash

set -e
set -u
set -o pipefail
# set -x

REPO="${1:-}"
VARIANT="${2:-}"
TAG="${3:-latest}"
ERR_MSG="Usage: $0 <repo> [variant] [tag]"
if [[ -z "$REPO" ]]; then
    echo "${ERR_MSG}"
    exit 1
fi
if [[ -z "$VARIANT" ]]; then
    echo "${ERR_MSG}"
    exit 1
fi
TAG_TEMP="temp"

TEMP_DIR="$(mktemp -d)"
trap 'rm -rf "${TEMP_DIR}"' EXIT

echo "${GH_TOKEN}" | docker login ghcr.io -u "${GITHUB_ACTOR}" --password-stdin
echo "Pushing ${REPO}:${VARIANT}-${TAG} to ghcr.io"

# "devcontainer build" の "--label" が動作しない対応。
# おそらくこれ -> https://github.com/devcontainers/cli/issues/930
TEMP_DOCKERFILE="${TEMP_DIR}/Dockerfile"
cat <<EOF >"${TEMP_DOCKERFILE}"
FROM ghcr.io/${REPO}:${VARIANT}-${TAG_TEMP}
LABEL org.opencontainers.image.source=https://github.com/${REPO}
EOF

docker buildx build \
    -t "ghcr.io/${REPO}:${VARIANT}-${TAG}" \
    --push \
    "${TEMP_DIR}"
