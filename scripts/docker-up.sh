#!/usr/bin/env bash
# Start all services for Khulla Digital Library
set -euo pipefail

echo "Starting services..."
docker compose up "$@"
