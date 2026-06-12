#!/bin/bash
# Start Provider Catalog Server

JAVA_PROPS=$(grep -v '^#' deployment/assets/env/provider_catalogserver.env | sed 's/^/-D/')
# Just for testing purposes....
export KEYCLOAK_CONFIG_PATH="deployment/assets/keycloak/keycloak.properties" 
echo $JAVA_PROPS

java $JAVA_PROPS -jar launchers/catalog-server/build/libs/catalog-server.jar --log-level=debug
