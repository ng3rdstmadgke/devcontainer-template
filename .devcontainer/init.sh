#!/bin/bash

mkdir -p ~/.ssh
mkdir -p ~/.aws
mkdir -p ~/.devcontainer-template/.claude
[ ! -f ~/.devcontainer-template/.claude.json ] && echo '{}' > ~/.devcontainer-template/.claude.json
mkdir -p ~/.devcontainer-template/.gemini
mkdir -p ~/.devcontainer-template/.kube
mkdir -p ~/.devcontainer-template/.config/helm

DOCKER_NETWORK=br-devcontainer-template-${USER}
NETWORK_EXISTS=$(docker network ls --filter name=$DOCKER_NETWORK --format '{{.Name}}')

if [ -z "$NETWORK_EXISTS" ]; then
  docker network create $DOCKER_NETWORK
fi