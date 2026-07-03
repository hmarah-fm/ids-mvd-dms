#!/bin/bash

envfile="deployment/assets/env/provider_identityhub-qna.env"
jar="launchers/identity-hub/build/libs/identity-hub.jar" 

env $(cat $envfile | grep -v '^#') java -jar $jar --log-level=debug
