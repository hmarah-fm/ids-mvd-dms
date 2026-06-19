#!/bin/bash

#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "Stopping GraphDB..."
docker compose -f "$SCRIPT_DIR/docker-compose.yml" down