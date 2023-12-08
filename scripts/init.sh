#!/bin/bash

set -euo pipefail

## Change to directory relative to this script
cd "$(dirname "$(readlink -f "$0")")" && cd ../src

echo "Cloning archive-core..."
git clone https://github.com/scimma/archive-core.git || GIT_CEILING_DIRECTORIES=$(pwd) git -C archive-core status
cd archive-core
git fetch --all && git pull --ff-only
docker build . -f docker/Dockerfile -t scimma/archive-core:dev
cd ..

echo "Cloning archive-ingest..."
git clone https://github.com/scimma/archive-ingest.git || GIT_CEILING_DIRECTORIES=$(pwd) git -C archive-ingest status
cd archive-ingest
git fetch --all && git pull --ff-only
make container
cd ..

git clone https://github.com/scimma/archive-api.git || GIT_CEILING_DIRECTORIES=$(pwd) git -C archive-api status
cd archive-api
git fetch --all && git pull --ff-only
make container
cd ..

