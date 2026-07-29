#!/bin/bash

## This script must be executed when running the dataspace from vscode. 

echo
echo Starting seeding ...
echo

## Seed identity data to identityhubs
API_KEY="c3VwZXItdXNlcg==.c3VwZXItc2VjcmV0LWtleQo="

###############################################################################
# add participant "consumer"
echo
echo
echo "Create consumer participant context in IdentityHub"
PEM_CONSUMER=$(sed -E ':a;N;$!ba;s/\r{0,1}\n/\\n/g' deployment/assets/consumer_public.pem)
DATA_CONSUMER=$(jq -n --arg pem "$PEM_CONSUMER" '{
           "roles":[],
           "serviceEndpoints":[
             {
                "type": "CredentialService",
                "serviceEndpoint": "http://localhost:7081/api/credentials/v1/participants/ZGlkOndlYjpsb2NhbGhvc3QlM0E3MDgzOmNvbnN1bWVy",
                "id": "consumer-credentialservice-1"
             },
             {
                "type": "DataspaceConnector",
                "serviceEndpoint": "http://localhost:8082/api/dsp",
                "id": "consumer-dsp"
             }
           ],
           "active": true,
           "participantId": "did:web:localhost%3A7083:consumer",
           "did": "did:web:localhost%3A7083:consumer",
           "key":{
               "keyId": "did:web:localhost%3A7083:consumer#key-1",
               "privateKeyAlias": "key-1",
               "publicKeyPem":"\($pem)"
           }
       }')

# the consumer runtime will need to have the client_secret in its vault as well, so we store it in a variable
# and use the Secrets API (part of Management API) to insert it.
clientSecret=$(curl -s --location 'http://localhost:7082/api/identity/v1alpha/participants/' \
--header 'Content-Type: application/json' \
--header "x-api-key: $API_KEY" \
--data "$DATA_CONSUMER" | jq -r '.clientSecret')

# add client secret to the consumer runtime
SECRETS_DATA=$(jq -n --arg secret "$clientSecret" \
'{
  "@context" : {
    "edc" : "https://w3id.org/edc/v0.0.1/ns/"
  },
  "@type" : "https://w3id.org/edc/v0.0.1/ns/Secret",
  "@id" : "did:web:localhost%3A7083-sts-client-secret",
  "https://w3id.org/edc/v0.0.1/ns/value": "\($secret)"
}')

echo
echo "Consumer client secret $clientSecret"
echo
echo "Set consumer secret in consumer connector"
curl -sL -X POST http://localhost:8081/api/management/v3/secrets \
  -H "x-api-key: password" -H "Content-Type: application/json" -d "$SECRETS_DATA"
echo
echo
echo "Set consumer secret in consumer standalone catalog server"
curl -sL -X POST http://localhost:8181/api/management/v3/secrets \
  -H "x-api-key: password" -H "Content-Type: application/json" -d "$SECRETS_DATA"
echo


###############################################################################
# add participant "provider qna"
echo
echo
echo
echo "Create provider QNA participant context in IdentityHub"
PEM_PROVIDER=$(sed -E ':a;N;$!ba;s/\r{0,1}\n/\\n/g' deployment/assets/provider_public.pem)
DATA_PROVIDER=$(jq -n --arg pem "$PEM_PROVIDER" '{
            "roles":[],
            "serviceEndpoints":[
              {
                 "type": "CredentialService",
                 "serviceEndpoint": "http://localhost:7091/api/credentials/v1/participants/ZGlkOndlYjpsb2NhbGhvc3QlM0E3MDkzOnByb3ZpZGVyMQ==",
                 "id": "provider-credentialservice-1"
              },
              {
                "type": "DataspaceConnector",
                "serviceEndpoint": "http://localhost:8192/api/dsp",
                "id": "provider-qna-catalog-dsp"
              }
            ],
            "active": true,
            "participantId": "did:web:localhost%3A7093:provider1",
            "did": "did:web:localhost%3A7093:provider1",
            "key":{
                "keyId": "did:web:localhost%3A7093:provider1#key-1",
                "privateKeyAlias": "key-1",
                "publicKeyPem":"\($pem)"
            }
      }')

# the provider runtime will need to have the client_secret in its vault as well, so we store it in a variable
# and use the Secrets API (part of Management API) to insert it.
clientSecret=$(curl -s --location 'http://localhost:7092/api/identity/v1alpha/participants/' \
--header 'Content-Type: application/json' \
--header "x-api-key: $API_KEY" \
--data "$DATA_PROVIDER" | jq -r '.clientSecret')

# add client secret to the provider runtimes
SECRETS_DATA=$(jq -n --arg secret "$clientSecret" \
'{
  "@context" : {
    "edc" : "https://w3id.org/edc/v0.0.1/ns/"
  },
  "@type" : "https://w3id.org/edc/v0.0.1/ns/Secret",
  "@id" : "did:web:localhost%3A7093-sts-client-secret",
  "https://w3id.org/edc/v0.0.1/ns/value": "\($secret)"
}')

echo
echo "Provider QNA client secret $clientSecret"
echo
echo "Set provider qna secret in provider connector qna"
curl -sL -X POST http://localhost:8191/api/management/v3/secrets -H "x-api-key: password" -H "Content-Type: application/json" -d "$SECRETS_DATA"
echo

###############################################################################
# add participant "provider ms"
echo
echo
echo
echo "Create provider MS participant context in IdentityHub"
PEM_PROVIDER=$(sed -E ':a;N;$!ba;s/\r{0,1}\n/\\n/g' deployment/assets/provider_public.pem)
DATA_PROVIDER=$(jq -n --arg pem "$PEM_PROVIDER" '{
            "roles":[],
            "serviceEndpoints":[
              {
                 "type": "CredentialService",
                 "serviceEndpoint": "http://localhost:7191/api/credentials/v1/participants/ZGlkOndlYjpsb2NhbGhvc3QlM0E3MTkzOnByb3ZpZGVyMg==",
                 "id": "provider-ms-credentialservice-1"
              },
              {
                "type": "DataspaceConnector",
                "serviceEndpoint": "http://localhost:8292/api/dsp",
                "id": "provider-ms-catalog-dsp"
              }
            ],
            "active": true,
            "participantId": "did:web:localhost%3A7193:provider2",
            "did": "did:web:localhost%3A7193:provider2",
            "key":{
                "keyId": "did:web:localhost%3A7193:provider2#key-1",
                "privateKeyAlias": "key-1",
                "publicKeyPem":"\($pem)"
            }
      }')

# the provider runtime will need to have the client_secret in its vault as well, so we store it in a variable
# and use the Secrets API (part of Management API) to insert it.
clientSecret=$(curl -s --location 'http://localhost:7192/api/identity/v1alpha/participants/' \
--header 'Content-Type: application/json' \
--header "x-api-key: $API_KEY" \
--data "$DATA_PROVIDER" | jq -r '.clientSecret')

# add client secret to the provider runtimes
SECRETS_DATA=$(jq -n --arg secret "$clientSecret" \
'{
  "@context" : {
    "edc" : "https://w3id.org/edc/v0.0.1/ns/"
  },
  "@type" : "https://w3id.org/edc/v0.0.1/ns/Secret",
  "@id" : "did:web:localhost%3A7193-sts-client-secret",
  "https://w3id.org/edc/v0.0.1/ns/value": "\($secret)"
}')

echo
echo "Provider MS client secret $clientSecret"
echo
echo "Set provider ms secret in provider connector ms"
curl -sL -X POST http://localhost:8291/api/management/v3/secrets -H "x-api-key: password" -H "Content-Type: application/json" -d "$SECRETS_DATA"
echo


###############################################################################
# SEED ISSUER SERVICE
###############################################################################

echo
echo
echo
echo "Create dataspace issuer participant"
PEM_ISSUER=$(sed -E ':a;N;$!ba;s/\r{0,1}\n/\\n/g' deployment/assets/issuer_public.pem)
DATA_ISSUER=$(jq -n --arg pem "$PEM_ISSUER" '{
            "roles":["admin"],
            "serviceEndpoints":[
              {
                 "type": "IssuerService",
                 "serviceEndpoint": "http://localhost:10012/api/issuance/v1alpha/participants/ZGlkOndlYjpsb2NhbGhvc3QlM0ExMDEwMA==",
                 "id": "issuer-service-1"
              }
            ],
            "active": true,
            "participantId": "did:web:localhost%3A10100",
            "did": "did:web:localhost%3A10100",
            "key":{
                "keyId": "did:web:localhost%3A10100#key-1",
                "privateKeyAlias": "key-1",
                "keyGeneratorParams":{
                  "algorithm": "EdDSA"
                }
            }
      }')

curl -s --location 'http://localhost:10015/api/identity/v1alpha/participants/' \
--header 'Content-Type: application/json' \
--data "$DATA_ISSUER"
echo

echo
echo Seeding done
echo

# Seed participant data to the issuer service
# newman run \
#   --folder "Seed Issuer" \
#   --env-var "ISSUER_ADMIN_URL=http://localhost:10013" \
#   --env-var "CONSUMER_ID=did:web:localhost%3A7083" \
#   --env-var "CONSUMER_NAME=MVD Consumer Participant" \
#   --env-var "PROVIDER_ID=did:web:localhost%3A7093" \
#   --env-var "PROVIDER_NAME=MVD Provider Participant" \
#   ./deployment/postman/MVD.postman_collection.json