#!/bin/bash
# Start Provider Catalog Server

JAVA_PROPS=$(grep -v '^\s*$' deployment/assets/env/standalone-catalog.env | grep -v '^#' | sed 's/^/-D/')
# Just for testing purposes....
#export KEYCLOAK_CONFIG_PATH="deployment/assets/keycloak/keycloak.properties" 
echo $JAVA_PROPS

java $JAVA_PROPS -Dweb.http.default.enabled=true -jar launchers/standalone-federated-catalog/build/libs/standalone-catalog.jar --log-level=debug
#java -Dedc.fs.config=launchers/standalone-catalog/config.properties -jar launchers/standalone-catalog/build/libs/standalone-catalog.jar --log-level=info