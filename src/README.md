# コンテナイメージ ソースファイル

## ファイルの配置

- Dev Container - `src/<VARIANT>/.devcontainer/`

## Build

スクリプトによりビルド(`devcontainer build` が使われる)。

```
scripts/image_build.sh <REPO> <VARIANT> <PLATFORM>
```

以下のように push 用の中間イメージが作成される。
(`devcontainer build` とオプションでラベルを指定できないため中間イメージ扱いとしている)

```
$ scripts/image_build.sh "hankei6km/test-dev-containers-images" basic linux/arm64 

$ dcoker image ls
REPOSITORY                                           TAG            IMAGE ID       CREATED         SIZE
ghcr.io/hankei6km/test-dev-containers-images         basic-temp     baf61f8f7d1b   17 hours ago    885MB
```

## Push

スクリプトにより push (`docker buildx build` が使われる)。

push の認証情報として以下が必要(GitHub Action での実行を想定)。
- `GITHUB_ACTOR` - GitHub のユーザ名
- `GH_TOKEN` - GitHub の Personal Access Token (package への write 権限が必要)

```
scripts/image_push.sh <REPO> <VARIANT> <TAG>
```

ラベル `org.opencontainers.image.source` に `<REPO>` が設定されたイメージが ghcr へ push される。
