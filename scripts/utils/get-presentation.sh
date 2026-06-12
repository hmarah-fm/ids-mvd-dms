curl --location 'http://localhost:7081/api/presentation/v1/participants/ZGlkOndlYjpsb2NhbGhvc3QlM0E3MDgz/presentations/query' \
--header 'Content-Type: application/json' \
--header 'Authorization: Basic c3VwZXItdXNlcjpjM1Z3WlhJdGMyVmpjbVYwTFd0bGVRbz0=' \
--data-raw '{
  "@context": [
    "https://w3id.org/tractusx-trust/v0.8",
    "https://identity.foundation/presentation-exchange/submission/v1"
  ],
  "@type": "PresentationQueryMessage",
  "presentationDefinition": null,
  "scope": [
    "org.eclipse.edc.vc.type:SomeCredential_0.3.5:write",
    "org.eclipse.edc.vc.type:SomeOtherCredential:read",
    "org.eclipse.edc.vc.type:ThirdCredential:*"
  ]
}'

c3VwZXItc2VjcmV0LWtleQo=

curl --location 'http://localhost:7081/api/presentation/v1/participants/ZGlkOndlYjpsb2NhbGhvc3QlM0E3MDgz/presentations/query' \
--header 'Content-Type: application/json' \
--header 'Authorization: Basic c3VwZXItdXNlcjpzdXBlci1zZWNyZXQta2V5' \
--data-raw '{
  "@context": [
    "https://w3id.org/tractusx-trust/v0.8",
    "https://identity.foundation/presentation-exchange/submission/v1"
  ],
  "@type": "PresentationQueryMessage",
  "presentationDefinition": null,
  "scope": [
    "org.eclipse.edc.vc.type:SomeCredential_0.3.5:write",
    "org.eclipse.edc.vc.type:SomeOtherCredential:read",
    "org.eclipse.edc.vc.type:ThirdCredential:*"
  ]
}'