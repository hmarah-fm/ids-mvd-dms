#!/usr/bin/env bash

GRAPHDB_URL="http://localhost:7200"
REPO_ID="centralKG"

curl -s \
  -X POST \
  -H "Content-Type: application/sparql-update" \
  --data-binary @- \
  "$GRAPHDB_URL/repositories/$REPO_ID/statements" <<'EOF'
DELETE {
  GRAPH ?g { ?s ?p ?o }
  ?s ?p ?o
}
WHERE {
  GRAPH ?g { ?s ?p ?o }
  UNION
  { ?s ?p ?o }
}
EOF

echo "All data deleted from repository: $REPO_ID"
