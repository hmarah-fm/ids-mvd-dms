#!/bin/bash

envfile="deployment/assets/env/issuerservice.env"
jar="launchers/issuerservice/build/libs/issuerservice.jar"

env $(cat $envfile | grep -v '^#') java -jar $jar --log-level=debug
