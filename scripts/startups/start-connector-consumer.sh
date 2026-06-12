#!/bin/bash
# Start Connector Consumer

JAVA_PROPS=$(grep -v '^#' deployment/assets/env/consumer_connector.env | sed 's/^/-D/')

java $JAVA_PROPS -jar launchers/runtime-embedded/build/libs/runtime-embedded.jar --log-level=debug
