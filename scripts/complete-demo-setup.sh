#!/usr/bin/env bash
set -euo pipefail
set +x

cd "$(dirname "${BASH_SOURCE[0]}")/.."

property() {
    awk -v key="$2" 'index($0, key "=") == 1 { print substr($0, length(key) + 2); exit }' "$1"
}

request() {
    local method="$1" url="$2" key="$3" payload="${4:-}"
    local arguments=(--silent --show-error --max-time 30 --request "$method"
        --header "${5:-x-api-key}: $key" --header 'Content-Type: application/json')
    if [[ -n "$payload" ]]; then
        arguments+=(--data "$payload")
    fi
    local result
    result=$(curl "${arguments[@]}" --write-out $'\n%{http_code}' "$url")
    STATUS=${result##*$'\n'}
    RESPONSE=${result%$'\n'*}
}

expect_success() {
    if [[ "$STATUS" != 2?? ]]; then
        printf '%s failed: HTTP %s\n' "$1" "$STATUS" >&2
        return 1
    fi
    printf '%s: HTTP %s\n' "$1" "$STATUS"
}

store_secret() {
    local port="$1" alias="$2" secret="$3" envfile="$4"
    local payload key
    key=$(property "$envfile" web.http.management.auth.key)
    payload=$(jq -nc --arg alias "$alias" --arg secret "$secret" '{
        "@context":{"@vocab":"https://w3id.org/edc/v0.0.1/ns/"},
        "@type":"Secret", "@id":$alias, value:$secret}')
    request POST "http://localhost:$port/api/management/v3/secrets" "$key" "$payload"
    if [[ "$STATUS" == 409 ]]; then
        request PUT "http://localhost:$port/api/management/v3/secrets" "$key" "$payload"
    fi
    expect_success "Store STS secret on $port"
}

reset_identity() {
    local port="$1" did="$2" envfile="$3" credential_port="$4" connector_port="$5"
    local participant_path key payload secret public_key_file
    participant_path=$(printf '%s' "$did" | base64 -w0)
    public_key_file=deployment/assets/provider_public.pem
    if [[ "$port" == 7082 ]]; then public_key_file=deployment/assets/consumer_public.pem; fi
    key=$(property "$envfile" edc.ih.api.superuser.key)
    request GET "http://localhost:$port/api/identity/v1alpha/participants" "$key"
    expect_success "List demo contexts on $port"
    if jq -e --arg did "$did" 'any(.[]; .participantContextId == $did)' <<< "$RESPONSE" >/dev/null; then
        request DELETE "http://localhost:$port/api/identity/v1alpha/participants/$participant_path" "$key"
        expect_success "Remove old demo context $did"
    fi
    payload=$(jq -nc --arg did "$did" --arg path "$participant_path" \
        --rawfile public_key "$public_key_file" \
        --arg credential_port "$credential_port" --arg connector_port "$connector_port" '{
        roles:[], active:true, participantId:$did, did:$did,
        serviceEndpoints:[
            {type:"CredentialService", id:"demo-credentials",
             serviceEndpoint:("http://localhost:"+$credential_port+"/api/credentials/v1/participants/"+$path)},
            {type:"DataspaceConnector", id:"demo-dsp",
             serviceEndpoint:("http://localhost:"+$connector_port+"/api/dsp")}],
        key:{keyId:($did+"#key-1"),privateKeyAlias:"key-1",publicKeyPem:$public_key}}')
    request POST "http://localhost:$port/api/identity/v1alpha/participants/" "$key" "$payload"
    expect_success "Create demo context $did"
    secret=$(jq -er '.clientSecret | select(type == "string" and length > 0 and . != "null")' <<< "$RESPONSE")
    case "$port" in
        7082)
            store_secret 8081 'did:web:localhost%3A7083-sts-client-secret' "$secret" deployment/assets/env/consumer_connector.env
            store_secret 8181 'did:web:localhost%3A7083-sts-client-secret' "$secret" deployment/assets/env/standalone-catalog.env
            ;;
        7092) store_secret 8191 'did:web:localhost%3A7093-sts-client-secret' "$secret" deployment/assets/env/provider_connector_qna.env ;;
        7192) store_secret 8291 'did:web:localhost%3A7193-sts-client-secret' "$secret" deployment/assets/env/provider_connector_manufacturing.env ;;
    esac
}

reset_identities() {
    local issuer='did:web:localhost%3A10100' key payload participant_path
    key=$(property deployment/assets/env/issuerservice.env edc.ih.api.superuser.key)
    participant_path=$(printf '%s' "$issuer" | base64 -w0)
    request GET "http://localhost:10015/api/identity/v1alpha/participants" "$key"
    expect_success 'List issuer contexts'
    if ! jq -e --arg did "$issuer" 'any(.[]; .participantContextId == $did)' <<< "$RESPONSE" >/dev/null; then
        payload=$(jq -nc --arg did "$issuer" --arg path "$participant_path" '{
            roles:["admin"],active:true,participantId:$did,did:$did,
            serviceEndpoints:[{type:"IssuerService",id:"issuer-service-1",
                serviceEndpoint:("http://localhost:10012/api/issuance/v1alpha/participants/"+$path)}],
            key:{keyId:($did+"#key-1"),privateKeyAlias:"key-1",keyGeneratorParams:{algorithm:"EdDSA"}}}')
        request POST http://localhost:10015/api/identity/v1alpha/participants/ "$key" "$payload"
    fi
    expect_success 'Initialize issuer context'
    reset_identity 7082 'did:web:localhost%3A7083:consumer' deployment/assets/env/consumer_identityhub.env 7081 8082
    reset_identity 7092 'did:web:localhost%3A7093:provider1' deployment/assets/env/provider_identityhub-qna.env 7091 8192
    reset_identity 7192 'did:web:localhost%3A7193:provider2' deployment/assets/env/provider_identityhub-ms.env 7191 8292
}

issue_credentials() {
    local collection=deployment/postman/EDC-Request-RDF-Service-local.postman_collection.json
    local variables issuer_key name template url payload identity port envfile request_name key
    variables=$(jq '[.variable[] | {key,value}] | from_entries' "$collection")
    variables=$(jq -c '. + {
        CONSUMER_ID:"did:web:localhost%3A7083:consumer",
        PROVIDER_QNA_ID:"did:web:localhost%3A7093:provider1",
        PROVIDER_MS_ID:"did:web:localhost%3A7193:provider2",
        PROVIDER_MS_NAME:"MVD Manufacturing Participant",
        PROVIDER_MS_IDENTITY_URL:"http://localhost:7192",
        CONSUMER_PARTICIPANT_ID_BASE64:("did:web:localhost%3A7083:consumer"|@base64),
        PROVIDER_QNA_PARTICIPANT_ID_BASE64:("did:web:localhost%3A7093:provider1"|@base64),
        PROVIDER_MS_PARTICIPANT_ID_BASE64:("did:web:localhost%3A7193:provider2"|@base64)
    }' <<< "$variables")
    issuer_key=$(property deployment/assets/env/issuerservice.env edc.ih.api.superuser.key)
    for name in '001-Create consumer participant' '001-Create provider QNA participant' \
        '001-Create provider MS participant' '003-Create attestation definitions' '005-Create credential definitions'; do
        template=$(jq -ec --arg name "$name" '.. | objects | select(.name? == $name) | .request' "$collection")
        url=$(jq -r --argjson variables "$variables" '.url.raw | gsub("\\{\\{(?<key>[^}]+)\\}\\}"; $variables[.key])' <<< "$template")
        payload=$(jq -er --argjson variables "$variables" '.body.raw | gsub("\\{\\{(?<key>[^}]+)\\}\\}"; $variables[.key]) | fromjson | tojson' <<< "$template")
        request POST "$url" "$issuer_key" "$payload"
        if [[ "$STATUS" != 409 ]]; then expect_success "$name"; fi
    done
    for identity in '7082 consumer_identityhub.env 102-Make Consumer Credential Request' \
        '7092 provider_identityhub-qna.env 104-Make Provider Qna Credential Request' \
        '7192 provider_identityhub-ms.env 106-Make Provider MS Credential Request'; do
        read -r port envfile request_name <<< "$identity"
        key=$(property "deployment/assets/env/$envfile" edc.ih.api.superuser.key)
        template=$(jq -ec --arg name "$request_name" '.. | objects | select(.name? == $name) | .request' "$collection")
        url=$(jq -r --argjson variables "$variables" '.url.raw | gsub("\\{\\{(?<key>[^}]+)\\}\\}"; $variables[.key])' <<< "$template")
        payload=$(jq -er --argjson variables "$variables" --arg pid "demo-recovery-$port-$(date +%s)" \
            '.body.raw | gsub("\\{\\{(?<key>[^}]+)\\}\\}"; $variables[.key]) | fromjson | .holderPid=$pid | tojson' <<< "$template")
        request POST "$url" "$key" "$payload"
        expect_success "$request_name"
    done
}

register_assets() {
    local provider port envfile asset kind key payload policy_kind policy_id
    for provider in '8191 provider_connector_qna.env dms-smoke-file file' \
        '8291 provider_connector_manufacturing.env dms-smoke-sparql sparqlendpoint'; do
        read -r port envfile asset kind <<< "$provider"
        key=$(property "deployment/assets/env/$envfile" web.http.management.auth.key)
        payload=$(jq -nc --arg asset "$asset" --arg kind "$kind" '{
            "@context":["https://w3id.org/edc/connector/management/v0.0.1",{
                msc_dms:"http://www.w3.org/ns/msc_dms#",
                edc_rdf:"https://ontology.flandersmake.be/edc_rdf/ontology#"}],
            "@id":$asset,"@type":"Asset",
            properties:{"msc_dms:name":$asset,"msc_dms:aboutProcess":"true"},
            dataAddress:{"@type":"DataAddress",type:"RDFService",
                "edc_rdf:serialization":"TTL","edc_rdf:serviceType":$kind}
        }')
        if [[ "$kind" == file ]]; then
            payload=$(jq -c '.dataAddress += {"edc_rdf:filePath":"fuseki/provider/example_provider_data.ttl","edc_rdf:encoding":"UTF-8"}' <<< "$payload")
        else
            local source_user source_password
            source_user=$(property deployment/assets/env/digital_thread.env DMS_SPARQL_USERNAME)
            source_password=$(property deployment/assets/env/digital_thread.env DMS_SPARQL_PASSWORD)
            payload=$(jq -c --arg user "$source_user" --arg password "$source_password" '.dataAddress += {
                "edc_rdf:sparqlEndpoint":"http://localhost:3032/provider/query",
                "edc_rdf:sparqlQuery":"CONSTRUCT { ?s ?p ?o } WHERE { ?s ?p ?o }",
                "edc_rdf:username":$user,"edc_rdf:password":$password}' <<< "$payload")
        fi
        request POST "http://localhost:$port/api/management/v3/assets" "$key" "$payload"
        if [[ "$STATUS" != 409 ]]; then expect_success "Register $asset"; fi
        for policy_kind in permission obligation; do
            policy_id="$asset-$policy_kind"
            payload=$(jq -nc --arg id "$policy_id" --arg kind "$policy_kind" '{
                "@context":["https://w3id.org/edc/connector/management/v0.0.1"],
                "@type":"PolicyDefinition","@id":$id,
                policy:{"@type":"Set",($kind):[{action:"use",constraint:{
                    leftOperand:"MembershipCredential",operator:"eq",rightOperand:"active"}}]}}')
            request POST "http://localhost:$port/api/management/v3/policydefinitions" "$key" "$payload"
            if [[ "$STATUS" != 409 ]]; then expect_success "Register $policy_id"; fi
        done
        payload=$(jq -nc --arg asset "$asset" '{
            "@context":["https://w3id.org/edc/connector/management/v0.0.1"],
            "@type":"ContractDefinition","@id":($asset+"-contract"),
            accessPolicyId:($asset+"-permission"),contractPolicyId:($asset+"-obligation"),
            assetsSelector:{"@type":"Criterion",operandLeft:"https://w3id.org/edc/v0.0.1/ns/id",
                operator:"=",operandRight:$asset}}')
        request POST "http://localhost:$port/api/management/v3/contractdefinitions" "$key" "$payload"
        if [[ "$STATUS" != 409 ]]; then expect_success "Register contract for $asset"; fi
    done
}

prune_credentials() {
    local identity port envfile did key participant_path stale credential_id
    for identity in '7082 consumer_identityhub.env did:web:localhost%3A7083:consumer' \
        '7092 provider_identityhub-qna.env did:web:localhost%3A7093:provider1' \
        '7192 provider_identityhub-ms.env did:web:localhost%3A7193:provider2'; do
        read -r port envfile did <<< "$identity"
        key=$(property "deployment/assets/env/$envfile" edc.ih.api.superuser.key)
        participant_path=$(printf '%s' "$did" | base64 -w0)
        request GET "http://localhost:$port/api/identity/v1alpha/credentials" "$key"
        expect_success "List credentials on $port"
        stale=$(jq -r --arg did "$did" '[.[] | select(.participantContextId == $did)] | sort_by(.timestamp) |
            if length > 1 and .[-1].state == 500 then .[0:-1][].id else empty end' <<< "$RESPONSE")
        while IFS= read -r credential_id; do
            if [[ -n "$credential_id" ]]; then
                request DELETE "http://localhost:$port/api/identity/v1alpha/participants/$participant_path/credentials/$credential_id" "$key"
                expect_success "Remove stale demo credential on $port"
            fi
        done <<< "$stale"
    done
}

configure_directory() {
    local envfile=deployment/assets/env/standalone-catalog.env
    local user password token clients definition did client_id payload
    user=$(property "$envfile" keycloak_admin_user)
    password=$(property "$envfile" keycloak_admin_password)
    token=$(curl --fail --silent --show-error --max-time 15 \
        --data-urlencode "username=$user" --data-urlencode "password=$password" \
        --data client_id=admin-cli --data grant_type=password \
        http://localhost:5080/realms/master/protocol/openid-connect/token | jq -er '.access_token')
    request GET http://localhost:5080/admin/realms/unimaas/clients "Bearer $token" '' Authorization
    expect_success 'Read participant directory'
    clients=$RESPONSE
    while IFS= read -r definition; do
        did=$(jq -r '.clientId' <<< "$definition")
        client_id=$(jq -r --arg did "$did" '[.[] | select(.clientId == $did or .clientId == ($did | sub(":provider[12]$"; "")))][0].id // empty' <<< "$clients")
        if [[ -n "$client_id" ]]; then
            request GET "http://localhost:5080/admin/realms/unimaas/clients/$client_id" "Bearer $token" '' Authorization
            expect_success "Read directory entry $did"
            payload=$(jq -c --argjson desired "$definition" '. * $desired' <<< "$RESPONSE")
            request PUT "http://localhost:5080/admin/realms/unimaas/clients/$client_id" "Bearer $token" "$payload" Authorization
        else
            request POST http://localhost:5080/admin/realms/unimaas/clients "Bearer $token" "$definition" Authorization
        fi
        expect_success "Configure directory entry $did"
    done < <(jq -c '.clients[]' keycloak/realm-import/unimaas-realm.json)
}

verify_demo() {
    local key count user password query graphs
    key=$(property deployment/assets/env/standalone-catalog.env web.http.management.auth.key)
    request POST http://localhost:8184/api/catalog/v1alpha/catalog/query "$key" \
        '{"@context":{"@vocab":"https://w3id.org/edc/v0.0.1/ns/"},"@type":"QuerySpec"}'
    expect_success 'Query federated catalog'
    jq -e '[.. | strings | select(. == "dms-smoke-file" or . == "dms-smoke-sparql")] | unique | length == 2' <<< "$RESPONSE" >/dev/null
    printf 'Federated catalog: both smoke assets present\n'
    user=$(property deployment/assets/env/digital_thread.env POSTGRES_USER)
    count=$(docker exec central-platform-postgres psql -At -v ON_ERROR_STOP=1 -U "$user" -d postgrescp -c \
        "SELECT COUNT(DISTINCT asset_id) FROM inserted_assets WHERE asset_id IN ('dms-smoke-file','dms-smoke-sparql') AND transfer_id IS NOT NULL AND negotiation_id IS NOT NULL AND agreement_id IS NOT NULL;")
    [[ "$count" == 2 ]]
    printf 'Postgres: both smoke assets tracked with transfer, negotiation, and agreement IDs\n'
    user=$(property deployment/assets/env/digital_thread.env DMS_SPARQL_USERNAME)
    password=$(property deployment/assets/env/digital_thread.env DMS_SPARQL_PASSWORD)
    query='SELECT ?graph (COUNT(*) AS ?triples) WHERE { GRAPH ?graph { ?s ?p ?o } VALUES ?graph { <http://data.local/graph/dms-smoke-file> <http://data.local/graph/dms-smoke-sparql> } } GROUP BY ?graph'
    graphs=$(curl --fail --silent --show-error --max-time 20 -u "$user:$password" \
        -H 'Accept: application/sparql-results+json' --get --data-urlencode "query=$query" \
        http://localhost:7200/repositories/centralKG)
    jq -e '.results.bindings | length == 2 and all(.[]; (.triples.value | tonumber) > 0)' <<< "$graphs" >/dev/null
    jq -r '.results.bindings[] | "GraphDB: \(.graph.value), \(.triples.value) triples"' <<< "$graphs"
}

case "${1:-}" in
    --reset-identities) reset_identities ;;
    --issue-credentials) issue_credentials ;;
    --register-assets) register_assets ;;
    --prune-credentials) prune_credentials ;;
    --configure-directory) configure_directory ;;
    --reset-consumer) reset_identity 7082 'did:web:localhost%3A7083:consumer' deployment/assets/env/consumer_identityhub.env 7081 8082 ;;
    --verify) verify_demo ;;
    *) printf 'Usage: bash scripts/complete-demo-setup.sh --reset-identities|--reset-consumer|--issue-credentials|--prune-credentials|--register-assets|--configure-directory|--verify\n' >&2; exit 2 ;;
esac