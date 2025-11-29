#!/bin/bash

cd $PROJECT_DIR

docker build --rm \
  -f docker/sample-app/Dockerfile \
  -t devcontainer-template/sample-app/${HOST_USER}:latest \
  .

docker run --rm -ti \
  --name sample-app-${HOST_USER} \
  --network $DOCKER_NETWORK \
  devcontainer-template/sample-app/${HOST_USER}:latest
