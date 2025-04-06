#!/bin/bash

set -e
set -u
set -o pipefail

REPO="${1:-}"
VARIANT="${2:-}"
PLATFORM="${3:-linux/amd64,linux/arm64}"
ERR_MSG="Usage: $0 <repo> [variant] [platform]"
if [[ -z "$REPO" ]]; then
    echo "${ERR_MSG}"
    exit 1
fi
if [[ -z "$VARIANT" ]]; then
    echo "${ERR_MSG}"
    exit 1
fi
TAG_TEMP="temp"

devcontainer build \
    --workspace-folder "./src/${VARIANT}/" \
    --config "./src/${VARIANT}/.devcontainer/devcontainer.json" \
    --image-name "ghcr.io/${REPO}:${VARIANT}-${TAG_TEMP}" \
    --platform "${PLATFORM}"

# "devcontainer build" の "--label" が動作しない \
# おそらくこれ -> https://github.com/devcontainers/cli/issues/930  \
# push.sh でラベルを付ける

# devcontaienr-lock.json が作成されないときは、以下を実行すると作成される。
# 正しい方法であるかは知らない。
# devcontainer upgrade \
#     --workspace-folder "./src/${VARIANT}/" \
#     --config "./src/${VARIANT}/.devcontainer/devcontainer.json" \
