#!/bin/bash

cd $PROJECT_DIR

docker build --rm \
  -f docker/app/Dockerfile \
  -t devcontainer-template/app/${HOST_USER}:latest \
  .

docker run --rm -ti \
  --name sample-app-${HOST_USER} \
  --network $DOCKER_NETWORK \
  devcontainer-template/app/${HOST_USER}:latest
