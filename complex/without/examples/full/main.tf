provider "aws" {
  region = var.aws_region
}

module "stack" {
  source = "../../"

  name = var.name

  availability_zones = [
    "${var.aws_region}a",
    "${var.aws_region}b",
    "${var.aws_region}c"
  ]

  vpc_cidr = "10.30.0.0/16"

  public_subnet_cidrs = [
    "10.30.0.0/24",
    "10.30.1.0/24",
    "10.30.2.0/24"
  ]

  private_subnet_cidrs = [
    "10.30.10.0/24",
    "10.30.11.0/24",
    "10.30.12.0/24"
  ]

  create_nat_gateway_per_az = true

  container_image = "public.ecr.aws/docker/library/httpd:2.4"
  container_port  = 80
  desired_count   = 2

  ecs_deployment_minimum_healthy_percent  = 75
  ecs_deployment_maximum_percent          = 150
  ecs_health_check_grace_period_seconds   = 120
  ecs_deployment_circuit_breaker_enable   = true
  ecs_deployment_circuit_breaker_rollback = true
  ecs_force_new_deployment                = false
  ecs_enable_execute_command              = true

  rds_instance_class          = "db.t3.small"
  rds_allocated_storage       = 30
  rds_backup_retention_period = 14
  rds_multi_az                = true
  db_name                     = "fullstackdb"
  db_username                 = "fullstackuser"

  s3_bucket_force_destroy = false
  s3_versioning_enabled   = true

  tags = {
    Environment = "full"
    Team        = "platform"
    Example     = "true"
  }
}
