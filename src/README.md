# コンテナイメージ ソースファイル

## ファイルの配置

- Dev Container - `src/<VARIANT>/.devcontainer/`

## Build

スクリプトによるビルド(`devcontainer build` が使われる)。

```
Usage: image_build.sh [OPTIONS] -- <variant>
Options:
    -r, --repo       <repo>          Repository name (required)
    -t, --tag        <tag>           Image tag (default: latest)
    -p, --platform   <platforms>     Target platforms (default: linux/amd64,linux/arm64)
        --push       <boolean>       Whether to push the image (default: false)
Arguments:
    <variant>                        Variant name (required)"
```

```
$ ./scripts/image_build.sh --repo "hankei6km/test-dev-containers-images" --tag test --platform linux/arm64 basic
```

> **Note:**  
> `--push true` を指定すると、ビルド後にイメージを ghcr へ push する。
> なお、`devcontainer build` のフラグ指定により、ラベル `org.opencontainers.image.source` に `<repo>` を設定しているが、`devcontainer build` の不具合により現状では実際には設定されない。よって、 ghcr へ push した後に手動で設定する必要がある。
