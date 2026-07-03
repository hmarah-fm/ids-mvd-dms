#!/bin/bash

envfile="deployment/assets/env/provider_connector_manufacturing.env"
jar="launchers/runtime-embedded/build/libs/runtime-embedded.jar"

env $(cat $envfile | grep -v '^#') java -jar $jar --log-level=debug

