#!/bin/bash

set -e
set -u
set -o pipefail

rustup --version
cargo --version

clippy-driver --version
cargo bump --version
toml --version
