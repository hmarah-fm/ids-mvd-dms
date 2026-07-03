# Developer documentation

## Prerequisites

Java 17 must be installed on the system.

## Identities

Participants: did:web:localhost%3A7AB3
- B (ten's, before last char): side (provider/consumer)
  - 8: consumer
  - 9: provider
- A (hundred's, second char in port): identity for the side
  - 8: consumer
  - 9: provider

1 consumer and 2 providers:
-  did:web:localhost%3A7083 consumer
-  did:web:localhost%3A7093 provider qna
-  did:web:localhost%3A7193 provider ms

## Port numbers 

Port number conventions 8ABC
- C (units): role
- B (ten's): side (provider/consumer)
  - 8: consumer
  - 9: provider
- A (hundred's): application

### Identity hubs

  - consumer hub
    - 708*
  - provider hub
    - 709*: qna
    - 719*: ms
  - roles
    - ***0: api
    - ***1: presentation
    - ***2: identity
    - ***3: did
    - ***4: accounts
    - ***5: version
    - ***5: sts

### Connectors
  - consumer standalone catalog server
    - 818*  connector
  - consumer connector
    - 808*  connector
  - provider qna connector
    - 819*  connector
    - 12001 public
  - provider manufacturing connector
    - 829*  connector
    - 12002 public
  - roles
    - ***0: api
    - ***1: management
    - ***2: protocol dsp or ids
    - ***3: control
    - ***4: catalog
    - ***5: version

### Trusted authorities

Issuer service
- 9999: StatusList
- 10010: api
- 10011: sts
- 10012: issuance
- 10013: admin
- 10014: /.well-known/api
- 10015: identity
- 10100: did

### Keycloak
- 5000: admin UI and management api


## Usefult information

### Docker

For building the images, use gradle task `dockerize`.

### Config

The env file contains java properties like `edc.iam.sts.privatekey.alias`.

They are equivalent to env vars like `EDC_IAM_STS_PRIVATEKEY_ALIAS`.

Java properties can be passed
- individually on the command line prefixed by `-D`
- as a file with the option `-Dedc.fs.config`
- as a file with `env $(cat myenvfile) java ...`  (and filter the comments)

Env vars can be passed
- individually with `export VAR=value`
- as a file with `env $(cat myenvfile) java ...` (and filter the comments, not tested)

Note: the java properties in the env files are no env var: the dot in the name is not allowed. So this vars cannot be used in a shell. But using the env command, these vars will work in java or in node. In java, use `getenv('path.name')`. In node, use `proces.env["path.name"]`.