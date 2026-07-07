#!/bin/bash

envfile="deployment/assets/env/consumer_identityhub.env"
jar="launchers/identity-hub/build/libs/identity-hub.jar"

java -Dedc.fs.config=$envfile -jar $jar --log-level=debug
