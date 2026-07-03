#!/bin/bash

envfile="deployment/assets/env/digital_thread.env"
jar="launchers/digital-thread/build/libs/digital-thread.jar"

env $(cat $envfile | grep -v '^#') java -jar $jar --log-level=debug
