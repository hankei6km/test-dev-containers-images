#!/bin/bash

set -e
set -u
set -o pipefail

id
source /usr/local/share/nvm/nvm.sh
nvm --version
node --version
npm --version
