# この Dev Container は、rust-basse variant をベースにしている。
# cargo install するために最低限 rust が使える環境を利用するため。
# 他の variant とは異なるので注意(rust-base variant の後にビルドすること)
ARG BASE_REPO="ghcr.io/hankei6km/test-dev-containers-images"
ARG BASE_TAG_SUFFIX="latest"
FROM ${BASE_REPO}:rust-base_${BASE_TAG_SUFFIX}

RUN cargo install cargo-bump toml-cli \
    && cargo cache -c 
