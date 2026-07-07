#!/bin/bash

envfile="deployment/assets/env/issuerservice.env"
jar="launchers/issuerservice/build/libs/issuerservice.jar"

java -Dedc.fs.config=$envfile -jar $jar --log-level=debug
