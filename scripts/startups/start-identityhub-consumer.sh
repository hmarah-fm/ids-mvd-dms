#!/bin/bash
# Start IdentityHub Consumer

JAVA_PROPS=$(grep -v '^#' deployment/assets/env/consumer_identityhub.env | sed 's/^/-D/')

java $JAVA_PROPS -jar launchers/identity-hub/build/libs/identity-hub.jar --log-level=debug
