#!/bin/bash
set -e

# --- Configuration ---
FUSEKI_URL="http://localhost:3031"
DATASET="consumer"
USERNAME="admin"
PASSWORD="mypassword"

# RDF file to load
FILE="$1"

if [ -z "$FILE" ]; then
  echo "Usage: $0 <file.ttl>"
  exit 1
fi

if [ ! -f "$FILE" ]; then
  echo "Error: File '$FILE' not found"
  exit 1
fi

echo "Loading $FILE into Fuseki dataset '$DATASET'..."

curl --fail --show-error -u "$USERNAME:$PASSWORD" \
     -X PUT \
     -H "Content-Type: text/turtle" \
     --data-binary @"$FILE" \
     "$FUSEKI_URL/$DATASET/data"

echo "Done."
