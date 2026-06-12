# Developer documentation

## Port numbers 

Port number conventions 8ABC
- C (units): role
- B (ten's): side (provider/consumer)
  - 8: consumer
  - 9: provider
- A (hundred's): application

### Connectors
  - consumer connector
    - 808*  connector
  - provider catalog connector 
    - 809*  connector
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

### Issuer service
- 9999: StatusList
- 10010: api
- 10011: sts
- 10012: issuance
- 10013: admin
- 10014: /.well-known/api
- 10015: identity
- 10100: did

## To discuss
See ids-mvd-dms/extensions/edc-rdf/data-plane-rdf/src/main/java/be/flandersmake/edc/dataplane/dataaddress/rdf/RDFServiceDataPlaneExtension.java:
- why you do not use @inject?
- I got a run-time error: service not found
  - I restored the inject and the error was gone


