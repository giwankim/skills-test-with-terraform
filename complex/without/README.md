# AWS Terraform Module: VPC + ALB + ECS + RDS + S3

This repository provides a reusable Terraform module that provisions:

- Multi-AZ VPC with public and private subnets
- Internet-facing ALB routed to ECS service tasks in private subnets
- ECS cluster, task definition, and service
- RDS instance in private subnets with ECS-to-RDS network connectivity
- S3 bucket with exported identifiers

## Module Structure

- Root module: `./`
- Examples: `./examples/minimal`, `./examples/full`
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
| `availability_zones` | `list(string)` | `[`us-east-1a`,`us-east-1b`]` | AZs used by subnets. |
| `public_subnet_cidrs` | `list(string)` | `[`10.0.0.0/24`,`10.0.1.0/24`]` | Public subnet CIDRs. |
| `private_subnet_cidrs` | `list(string)` | `[`10.0.10.0/24`,`10.0.11.0/24`]` | Private subnet CIDRs. |
| `create_nat_gateway_per_az` | `bool` | `false` | Create one NAT per AZ when true. |
| `alb_ingress_cidr_blocks` | `list(string)` | `[`0.0.0.0/0`]` | CIDRs allowed to reach ALB listener. |
| `alb_listener_port` | `number` | `80` | ALB listener port. |
| `alb_listener_protocol` | `string` | `HTTP` | ALB listener protocol. |
| `health_check_path` | `string` | `/` | ALB target group health path. |
| `target_group_deregistration_delay` | `number` | `30` | Target group deregistration delay (seconds). |
| `container_image` | `string` | `public.ecr.aws/docker/library/nginx:stable` | ECS container image. |
| `container_port` | `number` | `80` | ECS container port. |
| `task_cpu` | `number` | `256` | ECS task CPU units. |
| `task_memory` | `number` | `512` | ECS task memory (MiB). |
| `desired_count` | `number` | `1` | ECS desired task count. |
| `assign_public_ip` | `bool` | `false` | Assign public IP to ECS tasks. |
| `ecs_enable_execute_command` | `bool` | `false` | Enable ECS Exec on service. |
| `ecs_force_new_deployment` | `bool` | `false` | Force new ECS deployment each apply. |
| `ecs_deployment_minimum_healthy_percent` | `number` | `50` | Deployment min healthy percent knob. |
| `ecs_deployment_maximum_percent` | `number` | `200` | Deployment max percent knob. |
| `ecs_health_check_grace_period_seconds` | `number` | `60` | Deployment health check grace knob. |
| `ecs_deployment_circuit_breaker_enable` | `bool` | `true` | Enable ECS deployment circuit breaker. |
| `ecs_deployment_circuit_breaker_rollback` | `bool` | `true` | Roll back failed ECS deployments. |
| `log_retention_days` | `number` | `7` | CloudWatch retention for ECS logs. |
| `rds_engine` | `string` | `postgres` | RDS engine. |
| `rds_engine_version` | `string` | `15.5` | RDS engine version. |
| `rds_instance_class` | `string` | `db.t3.micro` | RDS instance class. |
| `rds_allocated_storage` | `number` | `20` | RDS storage in GiB. |
| `rds_backup_retention_period` | `number` | `7` | RDS backup retention days. |
| `rds_apply_immediately` | `bool` | `true` | Apply RDS updates immediately. |
| `rds_skip_final_snapshot` | `bool` | `true` | Skip final snapshot on deletion. |
| `rds_multi_az` | `bool` | `false` | Enable RDS Multi-AZ. |
| `db_name` | `string` | `appdb` | Database name. |
| `db_username` | `string` | `appuser` | Database username. |
| `db_password` | `string` | `null` | Database password (generated when null). |
| `db_port` | `number` | `5432` | Database port. |
| `s3_bucket_force_destroy` | `bool` | `false` | Force delete bucket with objects. |
| `s3_versioning_enabled` | `bool` | `true` | Enable S3 versioning. |

## Outputs

| Name | Description |
|---|---|
| `vpc_id` | VPC ID. |
| `public_subnet_ids` | Public subnet IDs. |
| `private_subnet_ids` | Private subnet IDs. |
| `alb_arn` | ALB ARN. |
| `alb_dns_name` | ALB DNS name. |
| `alb_target_group_arn` | ALB target group ARN. |
| `ecs_cluster_arn` | ECS cluster ARN. |
| `ecs_service_name` | ECS service name. |
| `ecs_security_group_id` | ECS task security group ID. |
| `rds_endpoint` | RDS endpoint address. |
| `rds_port` | RDS port. |
| `rds_security_group_id` | RDS security group ID. |
| `db_name` | Database name. |
| `db_username` | Database username. |
| `s3_bucket_id` | S3 bucket ID. |
| `s3_bucket_name` | S3 bucket name. |
| `s3_bucket_arn` | S3 bucket ARN. |

## Examples

### Minimal

```bash
cd examples/minimal
terraform init
terraform plan
```

### Full

```bash
cd examples/full
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
