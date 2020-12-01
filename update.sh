#!/bin/bash

vendir sync

for dir in $(ls src); do
    pushd src/$dir
    [[ -f go.mod ]] || go mod init $(git remote -v | head -1 | awk '{print $2}' | sed 's@https://@@g')
    go mod vendor
    rm -rf .git
    popd
done
