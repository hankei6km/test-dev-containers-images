#!/bin/bash

set -e
set -u
set -o pipefail

diff <(id) <(echo "uid=1000(devcontainer) gid=1000(devcontainer) groups=1000(devcontainer),998(nvm),999(docker)")
git --version
gh --version
shfmt --version
shellcheck --version
jq --version
