#!/bin/bash

vendir sync

for dir in $(ls src); do
    pushd src/$dir
      rm -rf .git
      go mod vendor
    popd
done
