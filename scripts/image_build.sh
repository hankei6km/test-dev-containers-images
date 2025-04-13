#!/bin/bash

set -e
set -u
set -o pipefail

USAGE_MSG="Usage: $0 [OPTIONS] -- <variant>
Options:
    -r, --repo       <repo>          Repository name (required)
    -t, --tag        <tag>           Image tag (default: latest)
    -p, --platform   <platforms>     Target platforms (default: linux/amd64,linux/arm64)
        --push       <boolean>       Whether to push the image (default: false)
Arguments:
    <variant>                        Variant name (required)"

# Parse arguments using getopt
OPTIONS=$(getopt -o r:t:p: --long repo:,tag:,platform:,push: -- "$@")
if [[ $? -ne 0 ]]; then
    echo "${USAGE_MSG}"
    exit 1
fi

eval set -- "${OPTIONS}"

REPO=""
TAG="latest"
PLATFORM="linux/amd64,linux/arm64"
PUSH="false"

while true; do
    case "$1" in
    --repo | -r)
        REPO="$2"
        shift 2
        ;;
    --tag | -t)
        TAG="$2"
        shift 2
        ;;
    --platform | -p)
        PLATFORM="$2"
        shift 2
        ;;
    --push)
        PUSH="$2"
        shift 2
        ;;
    --)
        shift
        break
        ;;
    *)
        echo "${USAGE_MSG}"
        exit 1
        ;;
    esac
done

VARIANT="${1:-}"
if [[ -z "$REPO" || -z "$VARIANT" ]]; then
    echo "${USAGE_MSG}"
    exit 1
fi

echo "${GH_TOKEN}" | docker login ghcr.io -u "${GITHUB_ACTOR}" --password-stdin
echo "Pushing ${REPO}:${VARIANT}-${TAG} to ghcr.io"

devcontainer build \
    --workspace-folder "./src/${VARIANT}/" \
    --config "./src/${VARIANT}/.devcontainer/devcontainer.json" \
    --image-name "ghcr.io/${REPO}:${VARIANT}-${TAG}" \
    --push ${PUSH} \
    --platform "${PLATFORM}"

# "devcontainer build" の "--label" が動作しない \
# おそらくこれ -> https://github.com/devcontainers/cli/issues/930  \
# push.sh でラベルを付ける
#--label "org.opencontainers.image.source=https://github.com/${REPO}" \

# devcontaienr-lock.json が作成されないときは、以下を実行すると作成される。
# 正しい方法であるかは知らない。
# devcontainer upgrade \
#     --workspace-folder "./src/${VARIANT}/" \
#     --config "./src/${VARIANT}/.devcontainer/devcontainer.json" \
