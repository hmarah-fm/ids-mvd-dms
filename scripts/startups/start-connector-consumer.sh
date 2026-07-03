#!/bin/bash

envfile="deployment/assets/env/consumer_connector.env"
jar="launchers/runtime-embedded/build/libs/runtime-embedded.jar"

env $(cat $envfile | grep -v '^#') java -jar $jar --log-level=debug

