#!/bin/bash
envfile="deployment/assets/env/provider_identityhub-ms.env"
jar="launchers/identity-hub/build/libs/identity-hub.jar" 

java -Dedc.fs.config=$envfile -jar $jar --log-level=debug


