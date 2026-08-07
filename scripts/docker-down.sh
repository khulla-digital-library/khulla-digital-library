#!/usr/bin/env bash
# Stop and remove all services for Khulla Digital Library
set -euo pipefail

echo "Stopping services..."
docker compose down "$@"
