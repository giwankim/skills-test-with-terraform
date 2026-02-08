# AWS ECS + ALB + RDS + S3 Terraform Module

This repository provides a reusable Terraform module that provisions an AWS application stack with:

- VPC with public/private subnets across multiple AZs
- Internet-facing ALB and listener/target group
- ECS Fargate cluster, task definition, and service wired to the ALB
- RDS instance in private subnets with ECS-to-RDS security group wiring
- S3 bucket with encryption, versioning, and public access blocking

## Repository Structure

```text
.
├── main.tf
├── variables.tf
├── outputs.tf
├── versions.tf
├── README.md
├── examples/
│   ├── minimal/
│   └── full/
├── tests/
│   ├── plan_mock.tftest.hcl
│   └── integration_apply.tftest.hcl
└── .github/workflows/ci.yml
```

## Usage

```hcl
module "stack" {
  source = "github.com/your-org/your-repo"

  name_prefix          = "appstack"
  availability_zones   = ["us-east-1a", "us-east-1b"]
  public_subnet_cidrs  = ["10.42.0.0/24", "10.42.1.0/24"]
  private_subnet_cidrs = ["10.42.10.0/24", "10.42.11.0/24"]

  rds_password = "ReplaceWithStrongPassword123!"
}
```

## Inputs

| Name | Type | Default | Description |
|------|------|---------|-------------|
| `alb_health_check_path` | `string` | `"/"` | HTTP path used by the ALB target group health check |
| `alb_listener_port` | `number` | `80` | Port exposed by the internet-facing ALB listener |
| `alb_target_group_port` | `number` | `80` | Port used by the ALB target group to reach ECS tasks |
| `alb_target_group_protocol` | `string` | `"HTTP"` | Protocol used by the ALB target group |
| `availability_zones` | `list(string)` | n/a | Availability zones used for both public and private subnets |
| `create_nat_gateway` | `bool` | `true` | Whether to create a NAT Gateway for private subnet internet egress |
| `ecs_container_cpu` | `number` | `256` | CPU units assigned to the ECS task definition |
| `ecs_container_environment` | `map(string)` | `{}` | Additional environment variables injected into the ECS container |
| `ecs_container_image` | `string` | `"public.ecr.aws/docker/library/nginx:stable"` | Container image used by the ECS task definition |
| `ecs_container_memory` | `number` | `512` | Memory (MiB) assigned to the ECS task definition |
| `ecs_container_name` | `string` | `"app"` | Container name referenced by the ECS service load balancer configuration |
| `ecs_container_port` | `number` | `80` | Container port exposed by the ECS task and target group |
| `ecs_deployment_circuit_breaker_enable` | `bool` | `true` | Deployment knob: enable ECS deployment circuit breaker |
| `ecs_deployment_circuit_breaker_rollback` | `bool` | `true` | Deployment knob: rollback failed deployments when circuit breaker is enabled |
| `ecs_deployment_maximum_percent` | `number` | `200` | Deployment knob: upper bound of tasks allowed during deployment |
| `ecs_deployment_minimum_healthy_percent` | `number` | `50` | Deployment knob: minimum healthy tasks maintained during deployment |
| `ecs_desired_count` | `number` | `1` | Desired number of ECS tasks in the service |
| `ecs_enable_execute_command` | `bool` | `false` | Whether ECS Exec is enabled for the service |
| `ecs_force_new_deployment` | `bool` | `false` | Deployment knob: force a new ECS deployment on each apply |
| `ecs_health_check_grace_period_seconds` | `number` | `60` | Deployment knob: grace period before ECS starts ALB health checks |
| `ecs_log_retention_in_days` | `number` | `14` | CloudWatch Logs retention period for ECS application logs |
| `ecs_wait_for_steady_state` | `bool` | `false` | Whether Terraform waits for ECS service steady state during apply |
| `name_prefix` | `string` | n/a | Lowercase prefix used when naming stack resources |
| `private_subnet_cidrs` | `list(string)` | n/a | CIDR blocks for private subnets (one per availability zone) |
| `public_subnet_cidrs` | `list(string)` | n/a | CIDR blocks for public subnets (one per availability zone) |
| `rds_allocated_storage` | `number` | `20` | Allocated storage (GiB) for the RDS instance |
| `rds_apply_immediately` | `bool` | `true` | Whether RDS modifications are applied immediately |
| `rds_backup_retention_period` | `number` | `7` | Backup retention period (days) for RDS |
| `rds_db_name` | `string` | `"appdb"` | Database name created in the RDS instance |
| `rds_deletion_protection` | `bool` | `false` | Whether deletion protection is enabled for RDS |
| `rds_engine` | `string` | `"postgres"` | RDS database engine |
| `rds_engine_version` | `string` | `null` | RDS engine version. Set to null to let AWS pick the default |
| `rds_instance_class` | `string` | `"db.t3.micro"` | Instance class for the RDS instance |
| `rds_multi_az` | `bool` | `false` | Whether to deploy RDS in Multi-AZ mode |
| `rds_password` | `string` | `null` | Master password for RDS. If null, Terraform generates one |
| `rds_port` | `number` | `5432` | Port used by the RDS engine |
| `rds_skip_final_snapshot` | `bool` | `true` | Whether to skip a final snapshot when destroying RDS |
| `rds_username` | `string` | `"appuser"` | Master username for RDS |
| `s3_bucket_name` | `string` | `null` | S3 bucket name. If null, Terraform generates a globally unique name |
| `s3_force_destroy` | `bool` | `false` | Whether Terraform can delete non-empty S3 buckets |
| `s3_versioning_enabled` | `bool` | `true` | Whether S3 bucket versioning is enabled |
| `tags` | `map(string)` | `{}` | Additional tags applied to all resources |
| `vpc_cidr` | `string` | `"10.42.0.0/16"` | Primary CIDR block for the VPC |

## Outputs

| Name | Description |
|------|-------------|
| `alb_arn` | ARN of the internet-facing ALB |
| `alb_dns_name` | Public DNS name of the internet-facing ALB |
| `alb_security_group_id` | Security group ID attached to the ALB |
| `alb_target_group_arn` | ARN of the ALB target group for ECS tasks |
| `ecs_cluster_arn` | ARN of the ECS cluster |
| `ecs_cluster_name` | Name of the ECS cluster |
| `ecs_service_name` | Name of the ECS service |
| `ecs_task_definition_arn` | ARN of the ECS task definition |
| `ecs_to_rds_connectivity` | Connection metadata showing ECS to RDS network wiring |
| `private_subnet_ids` | Private subnet IDs used by ECS and RDS |
| `public_subnet_ids` | Public subnet IDs used by the ALB |
| `rds_address` | RDS hostname for application connections |
| `rds_arn` | ARN of the RDS instance |
| `rds_db_name` | Database name configured on RDS |
| `rds_port` | RDS port exposed to ECS |
| `rds_security_group_id` | Security group ID attached to RDS |
| `s3_bucket_arn` | ARN of the S3 bucket |
| `s3_bucket_id` | ID of the S3 bucket |
| `s3_bucket_name` | Name of the S3 bucket |
| `vpc_id` | ID of the VPC |

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

## Testing

### Plan-mode tests with mocking (no real infrastructure)

```bash
terraform init
terraform test -filter=tests/plan_mock.tftest.hcl
```

### Apply-mode integration test (creates real infrastructure)

This test provisions and destroys real AWS resources.

```bash
terraform init
terraform test -filter=tests/integration_apply.tftest.hcl
```

## CI

GitHub Actions workflow (`.github/workflows/ci.yml`) runs on `pull_request` and `push` to `main` and executes:

1. `terraform fmt -check -recursive`
2. `terraform init -backend=false`
3. `terraform validate`
4. `terraform test -filter=tests/plan_mock.tftest.hcl`
5. `tflint --init` and `tflint --recursive`
