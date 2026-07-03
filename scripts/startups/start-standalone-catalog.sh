#!/bin/bash

envfile="deployment/assets/env/standalone-catalog.env"
jar="launchers/standalone-federated-catalog/build/libs/standalone-catalog.jar"

env $(cat $envfile | grep -v '^#') java -jar $jar --log-level=debug
