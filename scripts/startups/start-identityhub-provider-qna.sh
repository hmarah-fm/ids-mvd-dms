#!/bin/bash
# Start IdentityHub Provider

JAVA_PROPS=$(grep -v '^#' deployment/assets/env/provider_identityhub-qna.env | sed 's/^/-D/')

java $JAVA_PROPS -jar launchers/identity-hub/build/libs/identity-hub.jar --log-level=debug
