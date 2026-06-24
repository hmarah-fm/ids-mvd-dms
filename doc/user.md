# User documentation

## Prerequisites

- build the application
  - task B99 Build All
- import the postman collection [EDC-Request-RDF-Service-local](../deployment/postman/EDC-Request-RDF-Service-local.postman_collection.json) 

## Starting the environment, consume an RDF dataset exposed to the DS

Do the following steps:
- start the provider fuseki 
  - make sure the databases folder is writable by docker
  - start the server: task FP01
  - load the server: task FP02
  - check:open a browser on http://localhost:3032
- start the consumer fuseki
  - start the server: task FC01
  - check:open a browser on http://localhost:3031
- start all edc processes (but the digital thread and standalone catalog server): task ST99
- do the seeding task ST50
- create the consumer/provider credentials: postman folder 000, 100, 200
- create a provider sparql asset: postman folder 510
- request from consumer : postman folder 520
  - check: postman request 528 must return RDF data

## Run the digital thread agent

Do the following steps:
- start the consumer postgres: task PC01
- optional: empty the inserted datasets table: task PC03
- start the agent: task ST60
- check:
  - query the inserted datasets: task PC02
  - query the consumer triple store: consumer fuseki UI

## Run the standalone federated catalog

run the federated catalogue

- start keycloak
  - follow [procedure](https://github.com/UniMaaS-project-eu/ed-node/tree/master/tests/keycloak)
  - docker compose up
  - open browser on 5080
  - add client did:web:localhost%3A7093 (provider)
  - set the client secret (consumer)
    - JHbEb2C1Dsj0OWmKlnrg7Pv5uIXaWMpQ
  - start the Standalone Federated Catalog Server
    - will access the Keycloak every minute to get the participants
    - will crawl the catalog of every participant  


