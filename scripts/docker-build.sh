#!/usr/bin/env bash
# Build all Docker images for Khulla Digital Library
set -euo pipefail

echo "Building Docker images..."
docker compose build "$@"
echo "Done."
