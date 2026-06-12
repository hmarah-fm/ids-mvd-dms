#!/bin/bash
# Start Connector Provider Manufacturing

JAVA_PROPS=$(grep -v '^#' deployment/assets/env/provider_connector_manufacturing.env | sed 's/^/-D/')

java $JAVA_PROPS -jar launchers/runtime-embedded/build/libs/runtime-embedded.jar --log-level=debug
