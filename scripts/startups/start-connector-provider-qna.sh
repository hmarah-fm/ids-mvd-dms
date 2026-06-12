#!/bin/bash
# Start Connector Provider QnA

JAVA_PROPS=$(grep -v '^#' deployment/assets/env/provider_connector_qna.env | sed 's/^/-D/')

java $JAVA_PROPS -jar launchers/runtime-embedded/build/libs/runtime-embedded.jar --log-level=debug
