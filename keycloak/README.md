# Keycloak 

## Set up

Used by the federated catlog to retrieve DS participants, registered in keycloak as clients.

Set up downloaded from [unimaas](https://github.com/UniMaaS-project-eu/ed-node/tree/master/tests/keycloak)

- set up keycloak
  - start keycloak
    - docker compose up
  - open the admin UI
    - open browser on 5080 as admin/admin
  - add client did:web:localhost:7093 (provider)
     - use as id the did NOT url encoded
  - set the client secret
    - secret JHbEb2C1Dsj0OWmKlnrg7Pv5uIXaWMpQ

Important: set the client ID in keycloak NOT url encoded.

## Retrieve the token for this client:
```sh
RESPONSE=$(curl -X POST \
"http://localhost:5080/realms/unimaas/protocol/openid-connect/token" \
-H "Content-Type: application/x-www-form-urlencoded"   \
-d "grant_type=client_credentials&client_id=did:web:localhost%3A7093&client_secret=JHbEb2C1Dsj0OWmKlnrg7Pv5uIXaWMpQ")
```

This is the response:
```json
{
  "access_token": "eyJhbGciOiJSUzI1NiIsInR5cCIgOiAiSldUIiwia2lkIiA6ICI4dWp5ZWdKVkxOWUtBbW9FYmE0OVlGMVQ2MXpQcEViQWl5X202Ym1XRUZjIn0.eyJleHAiOjE3ODE3ODYxOTUsImlhdCI6MTc4MTc4NTg5NSwianRpIjoiMmVhNjkwNTgtZDM0Zi00Y2I1LTg4NzgtM2Q2ZDZmNzZhZmJmIiwiaXNzIjoiaHR0cDovL2xvY2FsaG9zdDo1MDgwL3JlYWxtcy91bmltYWFzIiwiYXVkIjoiYWNjb3VudCIsInN1YiI6ImQyODVlMzFkLTJkMWItNDdjZS1iNTNjLWY3ZjRlYjVhZTcxNSIsInR5cCI6IkJlYXJlciIsImF6cCI6ImRpZDp3ZWI6bG9jYWxob3N0OjcwOTMiLCJhY3IiOiIxIiwiYWxsb3dlZC1vcmlnaW5zIjpbIi8qIl0sInJlYWxtX2FjY2VzcyI6eyJyb2xlcyI6WyJvZmZsaW5lX2FjY2VzcyIsInVtYV9hdXRob3JpemF0aW9uIiwiZGVmYXVsdC1yb2xlcy11bmltYWFzIl19LCJyZXNvdXJjZV9hY2Nlc3MiOnsiYWNjb3VudCI6eyJyb2xlcyI6WyJtYW5hZ2UtYWNjb3VudCIsIm1hbmFnZS1hY2NvdW50LWxpbmtzIiwidmlldy1wcm9maWxlIl19fSwic2NvcGUiOiJwcm9maWxlIGVtYWlsIiwiZW1haWxfdmVyaWZpZWQiOmZhbHNlLCJjbGllbnRIb3N0IjoiMTcyLjE5LjAuMSIsInByZWZlcnJlZF91c2VybmFtZSI6InNlcnZpY2UtYWNjb3VudC1kaWQ6d2ViOmxvY2FsaG9zdDo3MDkzIiwiY2xpZW50QWRkcmVzcyI6IjE3Mi4xOS4wLjEiLCJjbGllbnRfaWQiOiJkaWQ6d2ViOmxvY2FsaG9zdDo3MDkzIn0.fm9vExDzUIS324wZjWOrzv5uh-1WWwVsCdL5C2KZ7Xm1srUAE_EINqn1mwo3VX2lAbd9YwBM7cIV1gF4jZZuX_7FpjhrujbxA2s8YQzXVo4yrVN0qXApNxBX4g9EEqxyXyQEM_hWGTzut8vSKfx2iPcaiWTcqTB8UXOliazJ6qg7wHhzYyzYRBiD5nzITcVRFaREMKLEMn2aZtPJQoMlcrmL04v8g80HIx9lc3PEitW_jwEZLKaaOHJeZlorK4eIvvlkpD9Z1iJ-liH6IXxY3aCJM_1xr_8spAv-KVG3ZsrX6qiqbQ0ASWg9t7cKY0dI0kPE-u6u2-Znl44Rl2X88w",
  "expires_in": 300,
  "refresh_expires_in": 0,
  "token_type": "Bearer",
  "not-before-policy": 0,
  "scope": "profile email"
}
```

Get the token
```sh
TOKEN=$(echo $RESPONSE | jq -r .access_token)
```

## Retrieve the list of clients through the api

Look at this: https://github.com/Flanders-Make-vzw/DPP-IDS-Dataspace/issues/75

Get the admine token
```sh
RESPONSE=$(curl -X POST "http://localhost:5080/realms/master/protocol/openid-connect/token" \
  -H "Content-Type: application/x-www-form-urlencoded" \
  -d "grant_type=password" \
  -d "client_id=admin-cli" \
  -d "username=admin" \
  -d "password=admin")
```

Get the token
```sh
TOKEN=$(echo $RESPONSE | jq -r .access_token)
```

Get the list of clients
```sh
curl -X GET "http://localhost:5080/admin/realms/unimaas/clients" \
-H "Authorization: Bearer $TOKEN" \
-H "Content-Type: application/json"
```

This is the list
```json
[
    {
        "id": "b0e23c62-c62c-49c5-a895-6301bac3fe3f",
        "clientId": "account",
        "name": "${client_account}",
        "rootUrl": "${authBaseUrl}",
        "baseUrl": "/realms/unimaas/account/",
        "surrogateAuthRequired": false,
        "enabled": true,
        "alwaysDisplayInConsole": false,
        "clientAuthenticatorType": "client-secret",
        "redirectUris": [
            "/realms/unimaas/account/*"
        ],
        "webOrigins": [],
        "notBefore": 0,
        "bearerOnly": false,
        "consentRequired": false,
        "standardFlowEnabled": true,
        "implicitFlowEnabled": false,
        "directAccessGrantsEnabled": false,
        "serviceAccountsEnabled": false,
        "publicClient": true,
        "frontchannelLogout": false,
        "protocol": "openid-connect",
        "attributes": {
            "post.logout.redirect.uris": "+"
        },
        "authenticationFlowBindingOverrides": {},
        "fullScopeAllowed": false,
        "nodeReRegistrationTimeout": 0,
        "defaultClientScopes": [
            "web-origins",
            "acr",
            "profile",
            "roles",
            "email"
        ],
        "optionalClientScopes": [
            "address",
            "phone",
            "offline_access",
            "microprofile-jwt"
        ],
        "access": {
            "view": true,
            "configure": true,
            "manage": true
        }
    },
    {
        "id": "b9188f3b-e2f4-47cc-83db-5c78c53d059c",
        "clientId": "account-console",
        "name": "${client_account-console}",
        "rootUrl": "${authBaseUrl}",
        "baseUrl": "/realms/unimaas/account/",
        "surrogateAuthRequired": false,
        "enabled": true,
        "alwaysDisplayInConsole": false,
        "clientAuthenticatorType": "client-secret",
        "redirectUris": [
            "/realms/unimaas/account/*"
        ],
        "webOrigins": [],
        "notBefore": 0,
        "bearerOnly": false,
        "consentRequired": false,
        "standardFlowEnabled": true,
        "implicitFlowEnabled": false,
        "directAccessGrantsEnabled": false,
        "serviceAccountsEnabled": false,
        "publicClient": true,
        "frontchannelLogout": false,
        "protocol": "openid-connect",
        "attributes": {
            "post.logout.redirect.uris": "+",
            "pkce.code.challenge.method": "S256"
        },
        "authenticationFlowBindingOverrides": {},
        "fullScopeAllowed": false,
        "nodeReRegistrationTimeout": 0,
        "protocolMappers": [
            {
                "id": "e2d2d479-2471-4ce8-baf3-9ea2009afc41",
                "name": "audience resolve",
                "protocol": "openid-connect",
                "protocolMapper": "oidc-audience-resolve-mapper",
                "consentRequired": false,
                "config": {}
            }
        ],
        "defaultClientScopes": [
            "web-origins",
            "acr",
            "profile",
            "roles",
            "email"
        ],
        "optionalClientScopes": [
            "address",
            "phone",
            "offline_access",
            "microprofile-jwt"
        ],
        "access": {
            "view": true,
            "configure": true,
            "manage": true
        }
    },
    {
        "id": "a004b5ac-a735-4329-aab2-190f093dbda7",
        "clientId": "admin-cli",
        "name": "${client_admin-cli}",
        "surrogateAuthRequired": false,
        "enabled": true,
        "alwaysDisplayInConsole": false,
        "clientAuthenticatorType": "client-secret",
        "redirectUris": [],
        "webOrigins": [],
        "notBefore": 0,
        "bearerOnly": false,
        "consentRequired": false,
        "standardFlowEnabled": false,
        "implicitFlowEnabled": false,
        "directAccessGrantsEnabled": true,
        "serviceAccountsEnabled": false,
        "publicClient": true,
        "frontchannelLogout": false,
        "protocol": "openid-connect",
        "attributes": {},
        "authenticationFlowBindingOverrides": {},
        "fullScopeAllowed": false,
        "nodeReRegistrationTimeout": 0,
        "defaultClientScopes": [
            "web-origins",
            "acr",
            "profile",
            "roles",
            "email"
        ],
        "optionalClientScopes": [
            "address",
            "phone",
            "offline_access",
            "microprofile-jwt"
        ],
        "access": {
            "view": true,
            "configure": true,
            "manage": true
        }
    },
    {
        "id": "1c0a4fcd-4dc4-4823-8652-c44e1a4bfbd3",
        "clientId": "broker",
        "name": "${client_broker}",
        "surrogateAuthRequired": false,
        "enabled": true,
        "alwaysDisplayInConsole": false,
        "clientAuthenticatorType": "client-secret",
        "redirectUris": [],
        "webOrigins": [],
        "notBefore": 0,
        "bearerOnly": true,
        "consentRequired": false,
        "standardFlowEnabled": true,
        "implicitFlowEnabled": false,
        "directAccessGrantsEnabled": false,
        "serviceAccountsEnabled": false,
        "publicClient": false,
        "frontchannelLogout": false,
        "protocol": "openid-connect",
        "attributes": {},
        "authenticationFlowBindingOverrides": {},
        "fullScopeAllowed": false,
        "nodeReRegistrationTimeout": 0,
        "defaultClientScopes": [
            "web-origins",
            "acr",
            "profile",
            "roles",
            "email"
        ],
        "optionalClientScopes": [
            "address",
            "phone",
            "offline_access",
            "microprofile-jwt"
        ],
        "access": {
            "view": true,
            "configure": true,
            "manage": true
        }
    },
    {
        "id": "0f1ccb53-5fce-4792-a3c1-0b14426d4aa0",
        "clientId": "did:web:localhost:7093",
        "name": "did:web:localhost:7093",
        "description": "MVD Provider",
        "rootUrl": "",
        "adminUrl": "",
        "baseUrl": "",
        "surrogateAuthRequired": false,
        "enabled": true,
        "alwaysDisplayInConsole": false,
        "clientAuthenticatorType": "client-secret",
        "secret": "JHbEb2C1Dsj0OWmKlnrg7Pv5uIXaWMpQ",
        "redirectUris": [
            "/*"
        ],
        "webOrigins": [
            "/*"
        ],
        "notBefore": 0,
        "bearerOnly": false,
        "consentRequired": false,
        "standardFlowEnabled": true,
        "implicitFlowEnabled": false,
        "directAccessGrantsEnabled": false,
        "serviceAccountsEnabled": true,
        "publicClient": false,
        "frontchannelLogout": true,
        "protocol": "openid-connect",
        "attributes": {
            "oidc.ciba.grant.enabled": "false",
            "client.secret.creation.time": "1781178074",
            "backchannel.logout.session.required": "true",
            "oauth2.device.authorization.grant.enabled": "false",
            "display.on.consent.screen": "false",
            "backchannel.logout.revoke.offline.tokens": "false"
        },
        "authenticationFlowBindingOverrides": {},
        "fullScopeAllowed": true,
        "nodeReRegistrationTimeout": -1,
        "protocolMappers": [
            {
                "id": "d89d19c5-50a4-4ffe-beb6-f7f616476f31",
                "name": "Client Host",
                "protocol": "openid-connect",
                "protocolMapper": "oidc-usersessionmodel-note-mapper",
                "consentRequired": false,
                "config": {
                    "user.session.note": "clientHost",
                    "id.token.claim": "true",
                    "access.token.claim": "true",
                    "claim.name": "clientHost",
                    "jsonType.label": "String"
                }
            },
            {
                "id": "617cd1e2-a278-4653-85a4-317e98dadaec",
                "name": "Client ID",
                "protocol": "openid-connect",
                "protocolMapper": "oidc-usersessionmodel-note-mapper",
                "consentRequired": false,
                "config": {
                    "user.session.note": "client_id",
                    "id.token.claim": "true",
                    "access.token.claim": "true",
                    "claim.name": "client_id",
                    "jsonType.label": "String"
                }
            },
            {
                "id": "37bbf6ff-c140-4cde-85e5-86e234155795",
                "name": "Client IP Address",
                "protocol": "openid-connect",
                "protocolMapper": "oidc-usersessionmodel-note-mapper",
                "consentRequired": false,
                "config": {
                    "user.session.note": "clientAddress",
                    "id.token.claim": "true",
                    "access.token.claim": "true",
                    "claim.name": "clientAddress",
                    "jsonType.label": "String"
                }
            }
        ],
        "defaultClientScopes": [
            "web-origins",
            "acr",
            "profile",
            "roles",
            "email"
        ],
        "optionalClientScopes": [
            "address",
            "phone",
            "offline_access",
            "microprofile-jwt"
        ],
        "access": {
            "view": true,
            "configure": true,
            "manage": true
        }
    },
    {
        "id": "4171df65-7348-4e94-901f-84618090e161",
        "clientId": "realm-management",
        "name": "${client_realm-management}",
        "surrogateAuthRequired": false,
        "enabled": true,
        "alwaysDisplayInConsole": false,
        "clientAuthenticatorType": "client-secret",
        "redirectUris": [],
        "webOrigins": [],
        "notBefore": 0,
        "bearerOnly": true,
        "consentRequired": false,
        "standardFlowEnabled": true,
        "implicitFlowEnabled": false,
        "directAccessGrantsEnabled": false,
        "serviceAccountsEnabled": false,
        "publicClient": false,
        "frontchannelLogout": false,
        "protocol": "openid-connect",
        "attributes": {},
        "authenticationFlowBindingOverrides": {},
        "fullScopeAllowed": false,
        "nodeReRegistrationTimeout": 0,
        "defaultClientScopes": [
            "web-origins",
            "acr",
            "profile",
            "roles",
            "email"
        ],
        "optionalClientScopes": [
            "address",
            "phone",
            "offline_access",
            "microprofile-jwt"
        ],
        "access": {
            "view": true,
            "configure": true,
            "manage": true
        }
    },
    {
        "id": "3d3f0563-5713-4774-a90f-256e3de9bd14",
        "clientId": "security-admin-console",
        "name": "${client_security-admin-console}",
        "rootUrl": "${authAdminUrl}",
        "baseUrl": "/admin/unimaas/console/",
        "surrogateAuthRequired": false,
        "enabled": true,
        "alwaysDisplayInConsole": false,
        "clientAuthenticatorType": "client-secret",
        "redirectUris": [
            "/admin/unimaas/console/*"
        ],
        "webOrigins": [
            "+"
        ],
        "notBefore": 0,
        "bearerOnly": false,
        "consentRequired": false,
        "standardFlowEnabled": true,
        "implicitFlowEnabled": false,
        "directAccessGrantsEnabled": false,
        "serviceAccountsEnabled": false,
        "publicClient": true,
        "frontchannelLogout": false,
        "protocol": "openid-connect",
        "attributes": {
            "post.logout.redirect.uris": "+",
            "pkce.code.challenge.method": "S256"
        },
        "authenticationFlowBindingOverrides": {},
        "fullScopeAllowed": false,
        "nodeReRegistrationTimeout": 0,
        "protocolMappers": [
            {
                "id": "b5d1abc5-2285-4719-96d6-36251029547e",
                "name": "locale",
                "protocol": "openid-connect",
                "protocolMapper": "oidc-usermodel-attribute-mapper",
                "consentRequired": false,
                "config": {
                    "userinfo.token.claim": "true",
                    "user.attribute": "locale",
                    "id.token.claim": "true",
                    "access.token.claim": "true",
                    "claim.name": "locale",
                    "jsonType.label": "String"
                }
            }
        ],
        "defaultClientScopes": [
            "web-origins",
            "acr",
            "profile",
            "roles",
            "email"
        ],
        "optionalClientScopes": [
            "address",
            "phone",
            "offline_access",
            "microprofile-jwt"
        ],
        "access": {
            "view": true,
            "configure": true,
            "manage": true
        }
    }
]
```