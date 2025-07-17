# JWT Issuer

## Overview

This repository provides a secure, AWS-native solution for issuing and validating JSON Web Tokens (JWTs) for use with Snowflake and other services. It leverages AWS Lambda, API Gateway, ECR, Secrets Manager, and other AWS services to provide a robust, scalable, and auditable token issuance platform.

## Features

- **JWT Issuance**: Securely issues JWTs for Snowflake and other consumers, using keys managed in AWS Secrets Manager.
- **JWKS Endpoint**: Serves a public JWKS (JSON Web Key Set) endpoint for token validation.
- **AWS IAM Integration**: Restricts API access to authenticated AWS IAM principals within your AWS Organization.
- **Infrastructure as Code**: All infrastructure is provisioned using OpenTofu/Terraform modules.
- **Key Rotation**: Supports key rotation via infrastructure changes.
- **Extensible**: Modular design for easy extension to other identity providers or consumers.

## Architecture

```
+-------------------+      +-------------------+      +-------------------+
|                   |      |                   |      |                   |
|   AWS API Gateway +----->+   Lambda:         +----->+   AWS Secrets      |
|                   |      |   jwt-issuer      |      |   Manager (Keys)   |
+-------------------+      +-------------------+      +-------------------+
         |
         |
         |                +-------------------+      +-------------------+
         |                |                   |      |                   |
         +--------------->+   Lambda:         +----->+   SSM Parameter   |
                          |   jwks            |      |   Store (JWKS)    |
                          +-------------------+      +-------------------+
```

- **jwt-issuer Lambda**: Issues JWTs for authenticated AWS IAM users/roles, signing them with a private key from Secrets Manager.
- **jwks Lambda**: Serves the public JWKS for token validation, reading from SSM Parameter Store.
- **API Gateway**: Secures endpoints, requiring AWS_IAM authentication and AWS Organization membership.
- **ECR**: Stores Docker images for Lambda functions.
- **Secrets Manager**: Stores private keys for JWT signing.
- **SSM Parameter Store**: Stores public JWKS for token validation.

## Infrastructure

All infrastructure is defined in the `infrastructure/` directory using OpenTofu/Terraform. Key modules include:

- `api/`: API Gateway configuration
- `certificate/`: ACM certificate management
- `ecr/`: ECR repositories for Lambda images
- `keys/`: Key pair generation and storage in Secrets Manager
- `lambda/`: Lambda function deployment
- `snowflake_oauth/`: (Optional) Snowflake OAuth integration
- `waf/`: Web Application Firewall configuration

See `infrastructure/main.tf` for the root module and how these components are wired together.

## Lambda Functions

### jwt-issuer

- Issues JWTs for Snowflake and other consumers.
- Authenticates the caller using AWS IAM.
- Extracts the Snowflake username from the IAM principal (SSO or workload role).
- Signs the JWT with a private RSA key from Secrets Manager.
- Returns the JWT in a JSON response.

### jwks

- Serves the public JWKS (JSON Web Key Set) for token validation.
- Reads the JWKS from SSM Parameter Store.
- Returns the JWKS as a JSON response.

## Getting Started

### Prerequisites

- AWS account with appropriate permissions
- [OpenTofu](https://opentofu.org/) or [Terraform](https://www.terraform.io/)
- [Go](https://golang.org/) 1.24+
- Docker (for building Lambda images)

### Quick Start

1. **Clone the repository:**

   ```sh
   git clone https://github.com/jreslock/jwt-issuer.git
   cd jwt-issuer
   ```

2. **Configure infrastructure variables:**
   - Copy and edit example tfvars in `infrastructure/vars/` as needed.
3. **Deploy infrastructure:**

   ```sh
   cd infrastructure
   rm -fr .terraform
   tofu init -backend-config=./vars/dev.backend.tfvars
   tofu plan -var-file=vars/dev.tfvars
   tofu apply -var-file=vars/dev.tfvars
   ```

4. **Build and publish Lambda images:**

   ```sh
   task build
   task publish_container_images
   ```

5. **Test the endpoints:**
   - Use AWS credentials to call the API Gateway endpoint for JWT issuance.
   - Fetch the JWKS from the `.well-known/jwks.json` endpoint.

## Development

- Use `Taskfile.yml` for common development tasks: build, test, lint, etc.
- Lambda source code is in `lambda/jwt-issuer/` and `lambda/jwks/`.
- Infrastructure code is in `infrastructure/`.
- Pre-commit hooks and CI/CD are configured for code quality and releases.

### Using the Devcontainer

This repository includes a [devcontainer](https://containers.dev/) configuration for a fully pre-configured development environment. This is the recommended way to get started for local development:

1. **Open in VS Code**
   - Install the [Dev Containers extension](https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.remote-containers) if you haven't already.
   - Open the project folder in VS Code.
   - When prompted, "Reopen in Container". VS Code will build and start the devcontainer automatically.

2. **What's Included**
   - All required tools: Go, Docker CLI, OpenTofu/Terraform, AWS CLI, pre-commit, and more.
   - Useful VS Code extensions for AWS, OpenTofu, Docker, YAML, and more.
   - Pre-commit hooks and a virtual environment for Python cryptography (for key conversion scripts).
   - Automatic mounting of your local AWS credentials, GitHub CLI config, and Docker socket for seamless cloud and container workflows.

3. **Tips**
   - Your local `~/.aws` credentials/config are mounted into the container for AWS CLI and SDK access.
   - Docker-in-Docker is enabled, so you can build and run containers inside the devcontainer.
   - The `postStartCommand` automatically installs pre-commit hooks and sets up the Python environment.
   - Use the integrated terminal (Zsh) for all development commands.

4. **Common Tasks**
   - Run `task` to see available development commands.
   - Use `task build`, `task test`, `task lint`, etc. as you would outside the container.

For advanced configuration, see `.devcontainer/devcontainer.json` and `.devcontainer/Dockerfile`.

## License

This project is licensed under the MIT License. See [LICENSE](LICENSE) for details.
