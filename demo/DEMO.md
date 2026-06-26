# Demo Setup

The demo has the goal to show the full DMS functionalities working. 
It uses the Adient data received from the partners and splits in two datasets: 1) External processes and 2) Internal processes.

The datasets can be found in the Teams folder under WP4 and should be included in the demo/dataset_1 folder the one about external processes and the seocnd one on demo/dataset_2 about the internal processes. 

Additionally, the DEMO postman collection runs the registration of these datasets where:
dataset_1 is registered by the connector QNA and dataset_2 is registered by the connector Manufacturing. 

This DEMO setup, uses the demo/demo_dms.json as the properties for the digital thread and should be set in the digital-thread.env:

DMS_PROPERTIES_PATH=demo/demo_dms.json

## run the demo

- make sure Keycloak is running
- run all auxiliary services: task ST98
  - check provider fuseki loaded with dataset 1
  - check graphdb empty with the rule nextStep
  - check postgres empty
- start all the edc processes: task ST99
- do the seeding: task ST50
- run the postman folders 100, 200, 300, 410, 510
  - check dataset 1 and 2 in cached catalog
  - check: get dataset 1 with htpp-proxy
  - check: det dataset 2 with htpp-proxy
- start the digital thread agent: task ST60
  - check: datasets in the standalone catalog
  - check: 2 graphs in graphdb
  - check: inferred statement nextStep

## Note 

Actually, the federation is done by the provider federated catalog, not by the consumer standalone federated catalog:
- this is a different config from the unimaas config
- a closer config would be
  - 2 provider identities (=participants)
  - each with a connector exposing a catalog
  - no provider catalog
  - to do
    - extra identity
    - extra identityhub
- open whether it is stronger or weaker