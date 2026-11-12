#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
COMPOSE_FILE="$SCRIPT_DIR/docker-compose.yml"
REALM_FILE="$SCRIPT_DIR/realm-import/unimaas-realm.json"
KEYCLOAK_URL="${KEYCLOAK_URL:-http://localhost:5080}"
KEYCLOAK_ADMIN="${KEYCLOAK_ADMIN:-admin}"

fail() {
  printf 'Keycloak setup failed: %s\n' "$1" >&2
  exit 1
}

for command in docker curl jq; do
  command -v "$command" >/dev/null 2>&1 || fail "required command not found: $command"
done

[[ -f "$REALM_FILE" ]] || fail "realm definition not found: $REALM_FILE"

if [[ -z "${KEYCLOAK_ADMIN_PASSWORD:-}" ]]; then
  if docker container inspect keycloak >/dev/null 2>&1; then
    KEYCLOAK_ADMIN_PASSWORD=$(docker inspect \
      --format '{{range .Config.Env}}{{println .}}{{end}}' keycloak \
      | sed -n 's/^KEYCLOAK_ADMIN_PASSWORD=//p' | head -n 1)
  fi
fi

if [[ -z "${KEYCLOAK_ADMIN_PASSWORD:-}" ]]; then
  [[ -t 0 ]] || fail 'set KEYCLOAK_ADMIN_PASSWORD or run this script from an interactive terminal'
  read -rsp 'Keycloak admin password: ' KEYCLOAK_ADMIN_PASSWORD
  printf '\n'
fi
export KEYCLOAK_ADMIN KEYCLOAK_ADMIN_PASSWORD

cleanup() {
  unset admin_token token_response KEYCLOAK_ADMIN_PASSWORD
}
trap cleanup EXIT

docker network inspect edc-network >/dev/null 2>&1 || docker network create edc-network >/dev/null
docker compose --project-directory "$SCRIPT_DIR" -f "$COMPOSE_FILE" up -d keycloak

ready=false
for ((attempt = 0; attempt < 60; attempt++)); do
  if curl -fsS --max-time 2 "$KEYCLOAK_URL/realms/master/.well-known/openid-configuration" >/dev/null; then
    ready=true
    break
  fi
  sleep 1
done
[[ "$ready" == true ]] || fail "Keycloak did not become ready at $KEYCLOAK_URL"

token_response=$(curl -fsS --max-time 10 \
  -X POST "$KEYCLOAK_URL/realms/master/protocol/openid-connect/token" \
  -H 'Content-Type: application/x-www-form-urlencoded' \
  --data-urlencode 'grant_type=password' \
  --data-urlencode 'client_id=admin-cli' \
  --data-urlencode "username=$KEYCLOAK_ADMIN" \
  --data-urlencode "password=$KEYCLOAK_ADMIN_PASSWORD") || fail 'admin authentication failed; use the password for the existing Keycloak data volume'
admin_token=$(printf '%s' "$token_response" | jq -er '.access_token') || fail 'Keycloak did not return an admin access token'
unset token_response

auth_header="Authorization: Bearer $admin_token"
admin_api="$KEYCLOAK_URL/admin/realms"
realm_name=$(jq -er '.realm' "$REALM_FILE")
realm_status=$(curl -sS --max-time 10 -o /dev/null -w '%{http_code}' \
  -H "$auth_header" "$admin_api/$realm_name") || fail 'could not query the realm admin API'

if [[ "$realm_status" == 404 ]]; then
  realm_body=$(jq -c '{realm, enabled, sslRequired}' "$REALM_FILE")
  curl -fsS --max-time 10 -X POST "$admin_api" \
    -H "$auth_header" -H 'Content-Type: application/json' \
    --data "$realm_body" >/dev/null || fail "could not create realm $realm_name"
elif [[ "$realm_status" != 200 ]]; then
  fail "unexpected response checking realm $realm_name: HTTP $realm_status"
fi

clients_api="$admin_api/$realm_name/clients"
while IFS= read -r client_id; do
  [[ -n "$client_id" ]] || continue
  client_body=$(jq -c --arg client_id "$client_id" \
    '.clients[] | select(.clientId == $client_id)' "$REALM_FILE")
  client_list=$(curl -fsS --max-time 10 --get \
    --data-urlencode "clientId=$client_id" \
    -H "$auth_header" "$clients_api") || fail "could not query client $client_id"
  client_uuid=$(printf '%s' "$client_list" | jq -r --arg client_id "$client_id" \
    '[.[] | select(.clientId == $client_id)][0].id // empty')

  if [[ -z "$client_uuid" && "$client_id" == *:provider[12] ]]; then
    legacy_client_id="${client_id%:provider?}"
    client_list=$(curl -fsS --max-time 10 --get \
      --data-urlencode "clientId=$legacy_client_id" \
      -H "$auth_header" "$clients_api") || fail "could not query legacy client $legacy_client_id"
    client_uuid=$(printf '%s' "$client_list" | jq -r --arg client_id "$legacy_client_id" \
      '[.[] | select(.clientId == $client_id)][0].id // empty')
  fi

  if [[ -z "$client_uuid" ]]; then
    curl -fsS --max-time 10 -X POST "$clients_api" \
      -H "$auth_header" -H 'Content-Type: application/json' \
      --data "$client_body" >/dev/null || fail "could not create client $client_id"
    client_list=$(curl -fsS --max-time 10 --get \
      --data-urlencode "clientId=$client_id" \
      -H "$auth_header" "$clients_api") || fail "could not verify client $client_id"
    client_uuid=$(printf '%s' "$client_list" | jq -r --arg client_id "$client_id" \
      '[.[] | select(.clientId == $client_id)][0].id // empty')
    printf 'Created client: %s\n' "$client_id"
  else
    current_client=$(curl -fsS --max-time 10 \
      -H "$auth_header" "$clients_api/$client_uuid") || fail "could not read client $client_id"
    updated_client=$(jq -c --argjson desired "$client_body" '. * $desired' <<<"$current_client")
    curl -fsS --max-time 10 -X PUT "$clients_api/$client_uuid" \
      -H "$auth_header" -H 'Content-Type: application/json' \
      --data "$updated_client" >/dev/null || fail "could not configure client $client_id"
    printf 'Configured client: %s\n' "$client_id"
  fi

  [[ -n "$client_uuid" ]] || fail "client $client_id was not created"
  secret_exists=$(curl -fsS --max-time 10 \
    -H "$auth_header" "$clients_api/$client_uuid/client-secret" \
    | jq -r '(.value // "") | length > 0') || fail "could not verify client secret for $client_id"
  [[ "$secret_exists" == true ]] || fail "Keycloak has no generated secret for $client_id"
done < <(jq -r '.clients[].clientId' "$REALM_FILE")

curl -fsS --max-time 10 "$KEYCLOAK_URL/realms/$realm_name/.well-known/openid-configuration" >/dev/null \
  || fail "realm $realm_name is not responding after setup"

unset admin_token
printf 'Keycloak demo setup is ready: %s (%s provider clients)\n' \
  "$realm_name" "$(jq '.clients | length' "$REALM_FILE")"
