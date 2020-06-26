#!/bin/bash -e
echo "rebuild energyplus branch: $1"
docker image rm build-energyplus:$1 -f
docker build . -t="build-energyplus:$1" --build-arg BRANCH=$1