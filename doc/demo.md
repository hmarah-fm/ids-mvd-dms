# Demo Setup

The demo has the goal to show the full DMS functionalities working. 
It uses the Adient data received from the partners and splits in two datasets: 1) External processes and 2) Internal processes.

The datasets can be found in the Teams folder under WP4 and should be included in the demo/dataset_1 folder the one about external processes and the seocnd one on demo/dataset_2 about the internal processes. 

Additionally, the DEMO postman collection runs the registration of these datasets where:
dataset_1 is registered by the connector QNA and dataset_2 is registered by the connector Manufacturing. 

This DEMO setup, uses the [property file](../deployment/config/demo_dms.json) as the properties for the digital thread and should be set in the [digital-thread.env](../deployment/assets/env/digital_thread.env).

## Architecture

### Consumer participant

The consumer is the dataspace central platform, featuring these components
- a identity hub
- a connector: 
  - allowing direct access to the published datasets
  - implementing a cached catalog
    - federating the participant catalogs from a list of participants
- a standalone federated catalog
  - federating the participant catalogs from the keycloak clients
- a digital thread agent, with a postgres database
- a graphdb instance, with an api
- a digital thread agent
  - using the standalone federated catalog
  - retrieving the datasets via the connector
   
### Provider participants

The providers are the dataspace stakeholders, featuring these components
- a identity hub
- a connector, publishing RDF datasets, controling access to the datasets
- a fuseki instance

## Run the demo

### Data preparation

#### Ontology

- Retrieved from unimaas repo [MSC-Ontology-RDF](https://github.com/UniMaaS-project-eu/MSC-Ontology-RDF)
- Copied in [central-kg repo](https://github.com/Flanders-Make-vzw/unimaas-central-kg) at `graphdb/config/MSC-ontology-1.2.0.ttl` 
- completed with owl statements for the `sc:nextStep` predicate
  - from file [next-steps.ttl](../central-kg/graphdb/config/next-steps.ttl)
  - at lines from 15 to 27
- used when creating the graphdb repository `centralKG`  
  - see config file [repo-config.ttl](../central-kg/graphdb/config/repo-config.ttl)
  - see script file [init-repo.sh](../central-kg/graphdb/scripts/init-repo.sh)

#### Dataset 1

Provided by provider MS, containing 'External data':
- file available in unimaas teams [General/Project Execution/WP4 Data-driven and Interoperable Manufacturing/AdientDataset/query_pc1andPc2.sparql.txt](https://flandersmake.sharepoint.com/:t:/s/unimaas.team/IQBLO6PqpprJRLzQRc0ub9oNAVl1Bzby2I0AEAbqR2sP1io?e=hDiVlG)
- copied in this repository at [demo/dataset_1/subgraph_pc1pc2_external.ttl](demo/dataset_1/subgraph_pc1pc2_external.ttl).
- completed with `sc:hasOutput statements`: lines 10 and 11
- loaded in provider fuseki
- provided as sparql based rdf dataset 
  - see postman collection, folders `5**`


#### Dataset 2

Provided by provider QNA, containing 'Internal data':
- file available in unimaas teams [General/Project Execution/WP4 Data-driven and Interoperable Manufacturing/AdientDataset/query_pc3andpc4.sparql.txt](https://flandersmake.sharepoint.com/:t:/s/unimaas.team/IQC-rgoXrsInQLGgj8BEWNNdAVmKEY_DPFm27xEc29th9rI?e=bWfgV8)
- copied in this repository [demo/dataset_2/subgraph_pc3pc4_internal.ttl](demo/dataset_2/subgraph_pc3pc4_internal.ttl).
- completed with `sc:hasInput statements`: lines 10 and 11
- provided as file based rdf dataset 
  - see postman collection, folders `4**`


### Preliminaries
- make those services are running
  - keycloak
  - provider fuseki
- start all the edc processes: `task ST99`
- do the seeding: task `ST50`
- run the postman folders `100`, `200`, `300`, `410`, `510`
  - check dataset 1 and 2 in cached catalog
  - check: get dataset 1 with htpp-proxy
  - check: det dataset 2 with htpp-proxy

### Run the digital thread agent
- make sure
  - consumer graphdb is started and flushed
  - consumer postgres is started and flushed
- start the digital thread agent: task `ST60`
  - check: 2 lines in posgres table 'inserted datasets'
  - check: 2 graphs in graphdb
  - check: inferred statement nextStep