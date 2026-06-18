#!/bin/bash
# Start Provider Catalog Server

JAVA_PROPS=$(grep -v '^#' deployment/assets/env/provider_catalogserver.env | sed 's/^/-D/')
# Just for testing purposes....
echo $JAVA_PROPS

java $JAVA_PROPS -jar launchers/catalog-server/build/libs/catalog-server.jar --log-level=debug
