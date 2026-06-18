#!/bin/bash
# Start Provider Catalog Server

JAVA_PROPS=$(grep -v '^\s*$' deployment/assets/env/standalone-catalog.env | grep -v '^#' | sed 's/^/-D/')
echo $JAVA_PROPS

java $JAVA_PROPS -Dweb.http.default.enabled=true -jar launchers/standalone-federated-catalog/build/libs/standalone-catalog.jar --log-level=debug
