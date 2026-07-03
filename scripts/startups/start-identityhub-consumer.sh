#!/bin/bash

envfile="deployment/assets/env/consumer_identityhub.env"
jar="launchers/identity-hub/build/libs/identity-hub.jar"

env $(cat $envfile | grep -v '^#') java -jar $jar --log-level=debug

