# AWS Terraform Module: VPC + ALB + ECS + RDS

This repository provides a reusable Terraform module that provisions:

- Multi-AZ VPC with public and private subnets
- Internet-facing ALB routed to ECS service tasks in private subnets
- ECS cluster, task definition, and service
- RDS instance in private subnets with ECS-to-RDS network connectivity

## Module Structure

- Root module: `./`
- Examples: `./examples/minimal`
- Native Terraform tests: `./tests`
- CI workflow: `.github/workflows/ci.yml`

## Requirements

- Terraform `>= 1.7.0, < 2.0.0`
- AWS provider `>= 5.40.0`
- Random provider `>= 3.6.0`

## Usage

```hcl
provider "aws" {
  region = "us-east-1"
}

module "stack" {
  source = "./path-to-this-module"

  name                = "my-stack"
  availability_zones  = ["us-east-1a", "us-east-1b"]
  public_subnet_cidrs = ["10.0.0.0/24", "10.0.1.0/24"]
  private_subnet_cidrs = [
    "10.0.10.0/24",
    "10.0.11.0/24"
  ]

  desired_count = 1
}
```

## Inputs

| Name | Type | Default | Description |
|---|---|---|---|
| `name` | `string` | n/a | Name prefix used across all resources. |
| `tags` | `map(string)` | `{}` | Additional tags applied to all resources. |
| `vpc_cidr` | `string` | `10.0.0.0/16` | CIDR block for the VPC. |
| `availability_zones` | `list(string)` | `[`us-east-1a`,`us-east-1b`]` | Availability zones used by public/private subnets. |
| `public_subnet_cidrs` | `list(string)` | `[`10.0.0.0/24`,`10.0.1.0/24`]` | Public subnet CIDRs (must align with availability_zones). |
| `private_subnet_cidrs` | `list(string)` | `[`10.0.10.0/24`,`10.0.11.0/24`]` | Private subnet CIDRs (must align with availability_zones). |
| `create_nat_gateway_per_az` | `bool` | `false` | Create one NAT Gateway per AZ when true. |
| `alb_listener_port` | `number` | `80` | ALB listener port. |
| `alb_listener_protocol` | `string` | `HTTP` | ALB listener protocol. |
| `alb_ingress_cidrs` | `list(string)` | `[`0.0.0.0/0`]` | CIDRs allowed to access the ALB listener. |
| `health_check_path` | `string` | `/` | Target group health check path. |
| `health_check_interval` | `number` | `30` | Target group health check interval in seconds. |
| `deregistration_delay` | `number` | `30` | ALB target group deregistration delay in seconds. |
| `container_image` | `string` | `public.ecr.aws/docker/library/nginx:stable` | Container image for ECS task. |
| `container_port` | `number` | `80` | Container port exposed by the ECS task and ALB target group. |
| `task_cpu` | `number` | `256` | Fargate task CPU units. |
| `task_memory` | `number` | `512` | Fargate task memory in MiB. |
| `desired_count` | `number` | `1` | Desired ECS service task count. |
| `deployment_min_healthy_pct` | `number` | `50` | Lower bound (%), during deployment, on healthy tasks in the ECS service. |
| `deployment_max_pct` | `number` | `200` | Upper bound (%), during deployment, on running tasks in the ECS service. |
| `health_check_grace_period` | `number` | `60` | Grace period in seconds before ALB health checks affect ECS deployment health. |
| `enable_circuit_breaker` | `bool` | `true` | Enable ECS deployment circuit breaker with rollback. |
| `log_retention_days` | `number` | `7` | CloudWatch log retention days for ECS task logs. |
| `db_engine` | `string` | `postgres` | RDS engine. |
| `db_engine_version` | `string` | `15.5` | RDS engine version. |
| `db_instance_class` | `string` | `db.t3.micro` | RDS instance class. |
| `db_allocated_storage` | `number` | `20` | RDS allocated storage in GiB. |
| `db_name` | `string` | `appdb` | Database name. |
| `db_username` | `string` | `appuser` | Database username. |
| `db_password` | `string` | `null` | Database password. If null, Terraform generates one. |
| `db_port` | `number` | `5432` | Database port. |
| `db_backup_retention` | `number` | `7` | RDS automated backup retention (days). |
| `db_multi_az` | `bool` | `false` | Enable Multi-AZ for the RDS instance. |
| `db_storage_encrypted` | `bool` | `true` | Enable encryption at rest for the RDS instance. |
| `db_apply_immediately` | `bool` | `true` | Whether RDS modifications are applied immediately. |

## Outputs

| Name | Description |
|---|---|
| `vpc_id` | VPC ID. |
| `public_subnet_ids` | Public subnet IDs. |
| `private_subnet_ids` | Private subnet IDs. |
| `alb_arn` | ALB ARN. |
| `alb_dns_name` | ALB DNS name. |
| `ecs_cluster_arn` | ECS cluster ARN. |
| `ecs_service_name` | ECS service name. |
| `rds_endpoint` | RDS instance endpoint address. |
| `rds_port` | RDS port. |
| `alb_security_group_id` | Security group attached to ALB. |
| `ecs_security_group_id` | Security group attached to ECS tasks. |
| `rds_security_group_id` | Security group attached to RDS instance. |

## Examples

### Minimal

```bash
cd examples/minimal
terraform init
terraform plan
```

## Tests

Native Terraform tests are stored in `tests/`.

### Plan-mode test with provider mocking (no real infrastructure)

```bash
terraform test -filter=tests/plan_mock.tftest.hcl
```

### Apply-mode integration test (real AWS resources)

```bash
terraform test -filter=tests/integration_apply.tftest.hcl
```

## CI

GitHub Actions workflow (`.github/workflows/ci.yml`) runs on pull requests and pushes to `main` with:

1. `terraform fmt -check -recursive`
2. `terraform init -backend=false`
3. `terraform validate`
4. `terraform test` (plan/mock filter)
5. `tflint` (with setup action)
