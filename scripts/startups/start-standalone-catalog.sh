#!/bin/bash

envfile="deployment/assets/env/standalone-catalog.env"
jar="launchers/standalone-federated-catalog/build/libs/standalone-catalog.jar"

java -Dedc.fs.config=$envfile -jar $jar --log-level=debug
