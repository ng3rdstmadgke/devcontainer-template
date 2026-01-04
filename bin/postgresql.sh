#!/bin/bash

set -e


CONTAINER_NAME="${PROJECT_NAME}-sample-postgresql"

function usage() {
cat >&2 <<EOF
Usage: $0 [options]

[options]
  -h, --help        Show this help message and exit
  --dump-conf       postgresql.conf を docker/postgresql/conf/postgresql.conf にダンプ
EOF
exit 1
}

DUMP_CONF=
args=()
while [ "$1" != "" ]; do
  case $1 in
    -h | --help ) usage ;;
    --dump-conf ) DUMP_CONF=1 ;;
    *           ) args+=("$1") ;;
  esac
  shift
done


# DockerHub: https://hub.docker.com/_/postgres
IMAGE=postgres:16.11
if [ -n "$DUMP_CONF" ]; then
  docker run -i --rm \
  $IMAGE \
  cat /usr/share/postgresql/postgresql.conf.sample > $PROJECT_DIR/docker/postgresql/conf/postgresql.conf
else
  docker rm -f $CONTAINER_NAME || true
  docker run \
    --rm \
    -d \
    --network $DOCKER_NETWORK \
    --name $CONTAINER_NAME \
    -v "$HOST_DIR/docker/postgresql/conf/postgresql.conf:/etc/postgresql/postgresql.conf" \
    -e POSTGRES_PASSWORD=root1234 \
    -e POSTGRES_USER=app \
    -e POSTGRES_DB=sample \
    $IMAGE \
    postgres -c 'config_file=/etc/postgresql/postgresql.conf'
  docker logs -f $CONTAINER_NAME
fi
