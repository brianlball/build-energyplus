#!/bin/bash -e
echo "build energyplus branch: $1"
docker build . -t="build-energyplus:$1" --build-arg BRANCH=$1