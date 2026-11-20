# CI/CD Pipeline Integration

**Course:** CIS4930 - Computing Tools for Workforce

**Author:** Nafis Anwar

**Deployment environment:** Local Docker

## Overview

This project integrates GitHub, GitHub Actions, Terraform, and Docker
into an automated application build, deployment, and verification
pipeline. The application provides a deployment dashboard and a JSON
health endpoint that identifies the deployed Git revision.

## Architecture

- Python HTTP application container
- NGINX reverse proxy container
- Terraform-managed Docker bridge network
- Repository-level self-hosted GitHub Actions runner
- Persistent local Terraform state

The NGINX gateway publishes port 8088 on the local host. The Python
application communicates with the gateway through the Docker network
and does not expose a separate host port.

## Prerequisites

- Git and GitHub
- Ubuntu WSL 2
- Docker Desktop with WSL integration
- Terraform
- Python 3
- curl and jq
- Registered GitHub Actions runner with the local-docker label

## Deployment

Start Docker Desktop and activate the registered runner:

    cd ~/actions-runner-cis4930-assignment4
    ./run.sh

Commit and push application or infrastructure changes to main:

    git add .
    git commit -m "Update application"
    git push origin main

GitHub Actions automatically builds both Docker images, initializes
Terraform, creates a deployment plan, applies the plan, and verifies
the deployed application.

The workflow can also be executed manually from the Actions tab.

## Runtime verification

Open the application:

    http://127.0.0.1:8088

Check the health endpoint:

    curl http://127.0.0.1:8088/health

Inspect the running containers:

    docker ps --filter name=cis4930-

Run the complete verification script from the deployed revision:

    bash scripts/verify.sh "$(git rev-parse HEAD)"

## Infrastructure state

Terraform state is stored outside the repository at:

    ~/.local/state/cis4930-assignment4/terraform.tfstate

This allows successive workflow runs to manage existing infrastructure.
The Terraform dependency lock file is version controlled, while state
files, temporary plans, and credentials are excluded.

## Project structure

- app/: Python application and Dockerfile
- proxy/: NGINX configuration and Dockerfile
- terraform/: Infrastructure configuration
- scripts/: Runtime verification
- .github/workflows/: Automated CI/CD workflow
