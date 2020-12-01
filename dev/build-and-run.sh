#!/bin/bash

docker build . -t pg-multi-exporter
docker run --name pg-multi-exporter --rm pg-multi-exporter
