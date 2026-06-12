#!/bin/bash
# Start Provider Catalog Server

JAVA_PROPS=$(grep -v '^#' deployment/assets/env/issuerservice.env | sed 's/^/-D/')

java $JAVA_PROPS -jar launchers/issuerservice/build/libs/issuerservice.jar --log-level=debug
