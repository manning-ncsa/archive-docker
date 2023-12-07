#!/bin/bash

set -euo pipefail

## Change to directory relative to this script
cd "$(dirname "$(readlink -f "$0")")" && cd ../src

git_reset() {
    MAIN_BRANCH=$1
    git reset --hard HEAD
    git checkout $MAIN_BRANCH
    git pull --ff-only
}

set -x

cd archive-core
git_reset master
cd ..

cd archive-ingest
git_reset main
cd ..

cd archive-api
git_reset master
cd ..

