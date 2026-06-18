# Keycloak

Used by the federated catlog to retrieve DS participants, registerd in keycloak as clients.

Set up downloaded from [unimaas](https://github.com/UniMaaS-project-eu/ed-node/tree/master/tests/keycloak)

- set up keycloak
  - start keycloak
    - docker compose up
  - open the admin UI
    - open browser on 5080
  - add client did:web:localhost:7093 (provider)
     - use as id the did NOT url encoded
  - set the client secret
    - secret JHbEb2C1Dsj0OWmKlnrg7Pv5uIXaWMpQ

Important: set the client ID in keycloak NOT url encoded.

Retrieve the token for this client:
```shell
curl -X POST \
"http://localhost:5080/realms/unimaas/protocol/openid-connect/token" \
-H "Content-Type: application/x-www-form-urlencoded"   \
-d "grant_type=client_credentials&client_id=did:web:localhost%3A7093&client_secret=JHbEb2C1Dsj0OWmKlnrg7Pv5uIXaWMpQ"
```

This is the token:
```shell
{"access_token":"eyJhbGciOiJSUzI1NiIsInR5cCIgOiAiSldUIiwia2lkIiA6ICI4dWp5ZWdKVkxOWUtBbW9FYmE0OVlGMVQ2MXpQcEViQWl5X202Ym1XRUZjIn0.eyJleHAiOjE3ODExODk5NTYsImlhdCI6MTc4MTE4OTY1NiwianRpIjoiNmFkZmUxOTMtODNlNi00ODk3LTg1NmItNzFhODM5Nzk1MjE2IiwiaXNzIjoiaHR0cDovL2xvY2FsaG9zdDo1MDgwL3JlYWxtcy91bmltYWFzIiwiYXVkIjoiYWNjb3VudCIsInN1YiI6ImQyODVlMzFkLTJkMWItNDdjZS1iNTNjLWY3ZjRlYjVhZTcxNSIsInR5cCI6IkJlYXJlciIsImF6cCI6ImRpZDp3ZWI6bG9jYWxob3N0OjcwOTMiLCJhY3IiOiIxIiwiYWxsb3dlZC1vcmlnaW5zIjpbIi8qIl0sInJlYWxtX2FjY2VzcyI6eyJyb2xlcyI6WyJvZmZsaW5lX2FjY2VzcyIsInVtYV9hdXRob3JpemF0aW9uIiwiZGVmYXVsdC1yb2xlcy11bmltYWFzIl19LCJyZXNvdXJjZV9hY2Nlc3MiOnsiYWNjb3VudCI6eyJyb2xlcyI6WyJtYW5hZ2UtYWNjb3VudCIsIm1hbmFnZS1hY2NvdW50LWxpbmtzIiwidmlldy1wcm9maWxlIl19fSwic2NvcGUiOiJwcm9maWxlIGVtYWlsIiwiZW1haWxfdmVyaWZpZWQiOmZhbHNlLCJjbGllbnRIb3N0IjoiMTcyLjE5LjAuMSIsInByZWZlcnJlZF91c2VybmFtZSI6InNlcnZpY2UtYWNjb3VudC1kaWQ6d2ViOmxvY2FsaG9zdDo3MDkzIiwiY2xpZW50QWRkcmVzcyI6IjE3Mi4xOS4wLjEiLCJjbGllbnRfaWQiOiJkaWQ6d2ViOmxvY2FsaG9zdDo3MDkzIn0.Y4KRG-UOhkEDEuBJ7D_rbJs_SBkc3mCLhqFn789egWgsWcbqY0QYok1hgzD5dyCdSMmMvoI0nc-Pn3YcLbYFND571tzERtm8rZ6zrWbtCPDUsl0KhvdaoMNtgjdub83dUmysfpl9f2ENX9WQkkNFB8nyegQMlq8Y94WbzbLT1flPpK610e-sxShYi_oNSXWres4meMlUrVFIHrJWhNqGEg8-FMrNNsCnXBv4OhDk2f3SD2xgiJn_bCmRhwUVfxxzPanNkF1ggi4fgK4DuiGisLLBLz4OuDfhoJYI0q6sXuJXiIj5Acm4hmeeRWkdhTe_ExjvCO4GB4VuCQYTt4FLkg","expires_in":300,"refresh_expires_in":0,"token_type":"Bearer","not-before-policy":0,"scope":"profile email"}
```

## Retrieve the list of clients through the api

Look at this: https://github.com/Flanders-Make-vzw/DPP-IDS-Dataspace/issues/75


```shell
curl -X GET "http://localhost:5080/admin/realms/unimaas/clients" \
  -H "Authorization: Bearer $TOKEN \
  -H "Content-Type: application/json"
```