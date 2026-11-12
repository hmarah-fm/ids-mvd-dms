#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
CONFIG_DIR="$SCRIPT_DIR"
TDB2_DIR="$SCRIPT_DIR/databases"
HOST_PORT=3031
IMAGE="stain/jena-fuseki"
HOST_GID="$(id -g)"

mkdir -p "$TDB2_DIR"
if [[ ! -w "$TDB2_DIR" ]]; then
  echo "Error: $TDB2_DIR must be writable by $(id -un) before Fuseki can start."
  exit 1
fi

docker run -d --rm\
  --name fuseki-server-consumer \
  --group-add "${HOST_GID}" \
  -p ${HOST_PORT}:3030 \
  -v ${CONFIG_DIR}/config.ttl:/fuseki/config.ttl \
  -v ${TDB2_DIR}:/fuseki/databases \
  -v ${CONFIG_DIR}/shiro.ini:/fuseki/shiro.ini \
  ${IMAGE} \
  /jena-fuseki/fuseki-server --config=/fuseki/config.ttl


echo "Fuseki running at http://localhost:${HOST_PORT}"
