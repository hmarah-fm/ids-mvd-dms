# User Guide

Use the [end-to-end DMS demo guide](./demo.md) for the complete startup order, component roles, configuration, Postman flows, data checks, and troubleshooting. It covers the current standalone GraphDB/Postgres startup path and calls out which WP4 datasets are not included in this checkout.

## Common User Flow

1. Build the services and start the local dependencies as described in the [demo guide](./demo.md#run-the-demo).
2. Import [`EDC-Request-RDF-Service-local`](../deployment/postman/EDC-Request-RDF-Service-local.postman_collection.json) into Postman and configure local endpoint and participant variables.
3. Run the identity/credential steps, then the file-based and SPARQL-based provider/consumer asset flows.
4. Query the standalone federated catalog and confirm the expected provider assets are visible.
5. Start the digital thread and verify transferred assets in Postgres and RDF in GraphDB.

The checked-in provider example is for local smoke testing. The Adient pilot datasets must be obtained from their authorized project source; they are not included here. Never use or share credentials copied from old documentation. Generate local secrets and keep them out of source control and Postman exports.

## Postman Flow

The collection is organized into these high-level steps:

- `000 Seed Standalone Federated Catalog` and `000-Issuer-Credential Service`
- `100-Make-IDHub-VerifiableCredential`
- `400-Request-RDF-Service-Flow (File Asset)`
- `500-Request-RDF-Service-Flow (Sparql Endpoint Asset)`
- `600-Standalone-Federated-Catalog-Server`
- `700-Check`

Run provider requests before their corresponding consumer requests. The full request names and expected checks are in the imported collection; use the exact DIDs and endpoints from the local configuration files.


