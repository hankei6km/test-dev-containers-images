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
        --cache-from <cache-from>    Cache source (optional)
        --cache-to   <cache-to>      Cache destination (optional)
    -u, --user       <user>          Custom user for docker login (optional)
        --is-main-branch <boolean>   Whether the current branch is the main branch (default: false)
Arguments:
    <variant>                        Variant name (required)"

# Parse arguments using getopt
OPTIONS=$(getopt -o r:t:p:u: --long repo:,tag:,platform:,push:,cache-from:,cache-to:,user:,is-main-branch: -- "$@")

eval set -- "${OPTIONS}"

REPO=""
TAG="latest"
PLATFORM="linux/amd64,linux/arm64"
PUSH="false"
CACHE_FROM=""
CACHE_TO=""
USER=""
IS_MAIN_BRANCH="false"

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
    --cache-from)
        CACHE_FROM="$2"
        shift 2
        ;;
    --cache-to)
        CACHE_TO="$2"
        shift 2
        ;;
    --user | -u)
        USER="$2"
        shift 2
        ;;
    --is-main-branch)
        IS_MAIN_BRANCH="$2"
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

# Check if USER is empty and exit with an error if not provided
if [[ -z "$USER" ]]; then
    echo "Error: --user argument is required. Please specify a user."
    exit 1
fi

if [[ -n "$USER" ]]; then
    echo "${GH_TOKEN}" | docker login ghcr.io -u "$USER" --password-stdin
else
    echo "${GH_TOKEN}" | docker login ghcr.io -u "${GITHUB_ACTOR}" --password-stdin
fi

echo "Pushing ${REPO}:${VARIANT}-${TAG} to ghcr.io"

DEVCONTAINER_ARGS=(
    --workspace-folder "./src/${VARIANT}/"
    --config "./src/${VARIANT}/.devcontainer/devcontainer.json"
    --image-name "ghcr.io/${REPO}:${VARIANT}-${TAG}"
    --push "${PUSH}"
    --platform "${PLATFORM}"
)

if [[ -n "$CACHE_FROM" ]]; then
    DEVCONTAINER_ARGS+=(--cache-from "$CACHE_FROM")
fi

if [[ -n "$CACHE_TO" ]]; then
    DEVCONTAINER_ARGS+=(--cache-to "$CACHE_TO")
fi

# Capture the output of the first devcontainer build command
BUILD_OUTPUT=$(devcontainer build "${DEVCONTAINER_ARGS[@]}")

# Parse the JSON output and check the outcome
OUTCOME=$(echo "$BUILD_OUTPUT" | jq -r '.outcome')
if [[ "$OUTCOME" != "success" ]]; then
    echo "Build failed with output: $BUILD_OUTPUT"
    exit 1
fi

# If PUSH and IS_MAIN_BRANCH are both true, rebuild with updated image name
if [[ "$PUSH" == "true" && "$IS_MAIN_BRANCH" == "true" ]]; then
    NEW_IMAGE_NAME="ghcr.io/${REPO}:${VARIANT}-latest"
    DEVCONTAINER_ARGS=(
        --workspace-folder "./src/${VARIANT}/"
        --config "./src/${VARIANT}/.devcontainer/devcontainer.json"
        --image-name "$NEW_IMAGE_NAME"
        --push "$PUSH"
        --platform "$PLATFORM"
    )

    if [[ -n "$CACHE_FROM" ]]; then
        DEVCONTAINER_ARGS+=(--cache-from "$CACHE_FROM")
    fi

    if [[ -n "$CACHE_TO" ]]; then
        DEVCONTAINER_ARGS+=(--cache-to "$CACHE_TO")
    fi

    devcontainer build "${DEVCONTAINER_ARGS[@]}"
fi

# "devcontainer build" の "--label" が動作しない \
# おそらくこれ -> https://github.com/devcontainers/cli/issues/930  \
# push.sh でラベルを付ける
#--label "org.opencontainers.image.source=https://github.com/${REPO}" \

# devcontaienr-lock.json が作成されないときは、以下を実行すると作成される。
# 正しい方法であるかは知らない。
# devcontainer upgrade \
#     --workspace-folder "./src/${VARIANT}/" \
#     --config "./src/${VARIANT}/.devcontainer/devcontainer.json" \
