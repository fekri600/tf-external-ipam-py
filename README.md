# Terraform Infrastructure Redesign Automation

This repository contains a fully automated Terraform setup to deploy and manage AWS infrastructure for multiple environments (`staging` and `production`). The solution uses workspaces, modular Terraform code, and GitHub Actions for CI/CD automation.

---

## 📐 Architecture Overview

The infrastructure is organized into modular components for scalability and maintainability:

- **Bootstrap**: Initializes backend components (S3, DynamoDB) and OIDC GitHub trust setup.
- **Network Module**: Provisions VPC, subnets, security groups, internet/NAT gateways, route tables, and ALB.
- **Environment Module**: Deploys EC2 instances via Auto Scaling Group, RDS, Redis, and necessary IAM roles and user data scripts.
- **CloudWatch Module**: Configures metrics, alarms, log groups, filters, and dashboards for EC2, RDS, and Redis.
- **Policies & Scripts**: Includes all IAM policies and helper shell scripts (connectivity checks, provider generation, etc.)

---

## 🚀 Usage Instructions

### 1. 🔧 Bootstrap Initialization

Before running the pipeline, you **must bootstrap** the Terraform backend and trust relationship setup for GitHub OIDC:

```bash
make bootstrap
```

This will:
- Create the S3 bucket and DynamoDB table for remote state
- Output backend values into the `outputs/` directory
- Set up the GitHub OIDC trust role and permissions
- Generate `providers.tf` dynamically for authenticated GitHub Actions runs

To clean up bootstrap resources:

```bash
make delete-bootstrap
```

---

### 2. 🌍 Environment Deployment via Workspaces

Each environment (`staging`, `production`) is mapped to a Terraform **workspace** and has its own `.auto.tfvars` file:
- `staging.auto.tfvars`
- `production.auto.tfvars`

This allows isolated deployments using a shared codebase but environment-specific configurations.

---

## ⚙️ GitHub Actions Pipeline

The file `.github/workflows/main.yml` defines the deployment workflow.

### 🏁 Trigger Options:

When manually triggered via GitHub UI:
- **Environment choice**: `staging`, `production`, or `both`
- **Action type**: `apply` or `destroy`

### ✅ What the pipeline does:

1. Sets up Terraform with the appropriate version
2. Configures AWS credentials using GitHub OIDC and the assumed IAM role
3. Selects or creates the corresponding workspace
4. Initializes the backend
5. Validates and formats Terraform files
6. Applies or destroys the infrastructure using the matching `.auto.tfvars` file

---

## 🔌 Connectivity Test Output

After deployment, a connectivity test validates access between components (EC2 to RDS/Redis), IAM authentication, and internet access:

```
-------------------2025-05-28 02:53:20-----------------------
== START CONNECTIVITY TEST ==

SSM Shell Environment Diagnostics:
User: root
Home:

MySQL Defaults:
mysql would have been started with the following arguments:

Testing RDS Port...
✅ RDS port 3306 is reachable

Testing Redis Port...
✅ Redis port 6379 is reachable

Ensuring IAM Auth Plugin is configured...
mysql: [Warning] Using a password on the command line interface can be insecure.
ERROR 1045 (28000): Access denied for user 'staging_user'@'10.0.12.36' (using password: YES)

Generating RDS IAM Auth Token...
Testing IAM Authentication...
mysql: [Warning] Using a password on the command line interface can be insecure.
NOW()
2025-05-28 02:53:20
✅ IAM RDS auth succeeded

Testing internet access...
✅ EC2 instance has internet access

== END CONNECTIVITY TEST ==
```

---

## 🧰 Scripts

Available helper scripts:
- `scripts/fetch_ssm_test_logs.sh`: Fetch logs from EC2 instances via SSM
- `scripts/generate_provider_file.sh`: Generates provider configuration based on bootstrap outputs

---

## 📂 Complete Directory Structure

```
infra_redesign_auto/
├── .github/
│   └── workflows/
│       └── main.yml
├── bootstrap/
│   ├── backend_setup/
│   │   ├── main.tf
│   │   ├── outputs.tf
│   │   └── variables.tf
│   ├── oidc/
│   │   ├── main.tf
│   │   ├── outputs.tf
│   │   ├── variables.tf
│   │   └── policies/
│   │       ├── permission-policy.json
│   │       └── trust-policy.json
├── modules/
│   ├── cloudwatch/
│   │   ├── alarms.tf
│   │   ├── dashboards.tf
│   │   ├── locals.tf
│   │   ├── logs.tf
│   │   └── variables.tf
│   ├── environment/
│   │   ├── asg-ec2.tf
│   │   ├── outputs.tf
│   │   ├── rds.tf
│   │   ├── redis.tf
│   │   └── variables.tf
│   └── network/
│       ├── alb.tf
│       ├── outputs.tf
│       ├── sg.tf
│       ├── variables.tf
│       └── vpc.tf
├── policies/
│   ├── ec2_assume_role_policy.json
│   └── rds_connect_policy.json
├── scripts/
│   ├── connectivity-test.sh
│   ├── fetch_ssm_test_logs.sh
│   ├── generate_provider_file.sh
│   └── user_data.sh.tmpl
├── production.auto.tfvars
├── staging.auto.tfvars
├── providers.tf
├── outputs.tf
├── variables.tf
├── locals.tf
├── main.tf
└── Makefile
```

---

## 👨‍💻 Maintainer

**your name**  
your posation 