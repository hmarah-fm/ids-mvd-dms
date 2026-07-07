#!/bin/bash

envfile="deployment/assets/env/consumer_connector.env"
jar="launchers/runtime-embedded/build/libs/runtime-embedded.jar"

java -Dedc.fs.config=$envfile -jar $jar --log-level=debug

