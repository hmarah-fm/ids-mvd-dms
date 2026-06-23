#!/bin/bash
set -e

ADMIN_USER="admin"
ADMIN_PASS="mypassword"
REPO_ID="centralKG"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_CONFIG="$SCRIPT_DIR/config/repo-config.ttl"

echo $REPO_CONFIG

echo "Starting GraphDB..."
docker compose -f "$SCRIPT_DIR/docker-compose.yml" up -d

echo "Waiting for GraphDB..."

until curl -sf http://localhost:7200/rest/repositories >/dev/null; do
    sleep 2
done

echo "GraphDB is ready."

if [ ! -f "$REPO_CONFIG" ]; then
    echo "Repository config not found:"
    echo "$REPO_CONFIG"
    exit 1
fi

echo "Creating repository..."

ls -l "$REPO_CONFIG"

curl -v \
     -u "$ADMIN_USER:$ADMIN_PASS" \
     -F "config=@${REPO_CONFIG}" \
     http://localhost:7200/rest/repositories

echo "Repository created."