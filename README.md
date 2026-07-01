# IDS-MVD-DMS

This repository provides a minimal setup to run the data management suite (DMS).

The DMS provides a platform for sharing RDF data accross a dataspace, facilitating
- interoperability between the DS participants
- discoverability of the data provided by the DS participants.

The DMS relies on
- on Eclipse [EDC](https://eclipse-edc.github.io/)
- on FM [EDC RDF extension](https://github.com/Flanders-Make-vzw/edc-rdf)
- on FM [EDC federated catalog](https://github.com/Flanders-Make-vzw/standalone-federated-catalog)
- on FM [Digital thread agent](https://github.com/Flanders-Make-vzw/digital-thread)
- on FM [Central KG implementation]()

It follows the IDSA recommendations and implements the IDS protocol.

It used [EDC MVD](https://github.com/eclipse-edc/MinimumViableDataspace) as a starting point.

## Documentation

For user: [doc](./doc/user.md).

For developer: [doc](./doc/developer.md)

About the demo: [doc](./doc/demo.md)

## Features

This repository implements the following components and features.

The EDC applications provided by the eclipse MVD:
- the `identity-hub`: identity management
- the `runtime-embedded`: data connector
- the `issuer-service`: authority issuing credentials to participants.

The 2 deployments:
- native deployment for development
  - running on the system on java
  - see the 
    - vscode tasks
    - vscode launch configs
    - start up scripts
- k8s deployment for actual deployment (To be finalized)
  - based on kind and terraform
  - see
    - the [docker file](./deployment/docker/dataplane-eye.Dockerfile) (TODO)
    - the terraform files and modules in folder [deployment](./deployment/) (TODO)

The set-up is composed of 3 participants:
- the `consumer`
  - the dataspace platform for interoperability and discovery
- 2 stakeholder participants, or providers 
  - the `provider qna`
  - the `provider ms`.

The following applications are deployed
- dataspace applications
  - `issuer service`
- consumer applications
  - `fuseki triple store`
    - for adding the datasets fetched by the digital thread
    - NOT used
  - `graphdb triple store`
    - the central kg
  - `keycloak`
    - for regitering the participants
  - `identity hub`
  - `connector`
  - `standalone federated catalog server`
    - federating the participants registered in keycloak
  - `digital thread agent`
    - with a postgres db tracking the datasets subscribed
- provider applications
  - `fuseki triple store`
    - for exposing datasets to the dataspace
    - shared between the 2 providers
  - `identity hub`
  - `connector`


 

