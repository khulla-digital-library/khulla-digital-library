# Khulla Digital Library

An open-source digital library management system.

## Overview

Khulla is a monorepo containing all services and packages that make up the Khulla Digital Library platform.

## Repository Structure

```
khulla-digital-library/
├── apps/
│   ├── api/          # Backend API service
│   └── web/          # Frontend web application
├── packages/         # Shared libraries and utilities
├── docs/             # Project documentation
│   ├── architecture/ # System design and ADRs
│   ├── api/          # API reference
│   └── contributing/ # Contribution guidelines
├── scripts/          # Developer and CI scripts
│   ├── docker-build.sh
│   ├── docker-up.sh
│   └── docker-down.sh
├── .github/
│   ├── workflows/    # GitHub Actions CI/CD pipelines
│   ├── ISSUE_TEMPLATE/
│   └── PULL_REQUEST_TEMPLATE.md
└── docker-compose.yml
```

## Getting Started

### Prerequisites

- [Docker](https://docs.docker.com/get-docker/) & Docker Compose

### Running Locally

```bash
# Build images
./scripts/docker-build.sh

# Start all services
./scripts/docker-up.sh

# Stop all services
./scripts/docker-down.sh
```

## Contributing

See [docs/contributing](./docs/contributing/) for guidelines on how to contribute to this project.

## License

[MIT](./LICENSE)
