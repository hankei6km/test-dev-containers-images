# この Dev Container は、rust-basse variant をベースにしている。
# cargo install するために最低限 rust が使える環境を利用するため。
# 他の variant とは異なるので注意(rust-base variant の後にビルドすること)
ARG BASE_REPO="ghcr.io/hankei6km/test-dev-containers-images"
ARG BASE_TAG_SUFFIX="latest"

FROM ${BASE_REPO}:rust-base_${BASE_TAG_SUFFIX} AS build

RUN cargo install cargo-bump toml-cli 

FROM ${BASE_REPO}:rust-base_${BASE_TAG_SUFFIX}

COPY --from=build /usr/local/cargo/bin/cargo-bump /usr/local/bin/cargo-bump
COPY --from=build /usr/local/cargo/bin/toml /usr/local/bin/toml
