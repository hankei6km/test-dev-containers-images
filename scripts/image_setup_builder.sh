#! /bin/bash

set -e
set -u

# https://qiita.com/Tomato_otamoT/items/e808eb7f959c5942eaf6

docker buildx create --use --name mybuilder
# binfmt は上記の記事のままだと CodeSpaces で git feature ビルドで停止してしまう(原因は不明) 。
# あと、deprecated だった。
docker run --privileged --rm linuxkit/binfmt:ce9509ccfa25002227ccd7ed8dd48d6947854427-amd64
# arm64 用の binfmt を利用する場合。
# ただし、手持ちの arm64 環境で builder を作成してのビルドがエラーになるので、実際には試していない。
# docker run --privileged --rm tonistiigi/binfmt --install all
docker buildx inspect --bootstrap
