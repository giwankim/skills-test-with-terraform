variable "name" {
  description = "Name prefix used across all resources."
  type        = string

  validation {
    condition     = can(regex("^[a-zA-Z0-9-]+$", var.name))
    error_message = "name may only contain letters, numbers, and hyphens."
  }
}

variable "tags" {
  description = "Additional tags applied to all resources."
  type        = map(string)
  default     = {}
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC."
  type        = string
  default     = "10.0.0.0/16"
}

variable "availability_zones" {
  description = "Availability zones used by public/private subnets."
  type        = list(string)
  default     = ["us-east-1a", "us-east-1b"]
}

variable "public_subnet_cidrs" {
  description = "Public subnet CIDRs (must align with availability_zones)."
  type        = list(string)
  default     = ["10.0.0.0/24", "10.0.1.0/24"]
}

variable "private_subnet_cidrs" {
  description = "Private subnet CIDRs (must align with availability_zones)."
  type        = list(string)
  default     = ["10.0.10.0/24", "10.0.11.0/24"]
}

variable "create_nat_gateway_per_az" {
  description = "If true, create one NAT Gateway per AZ; otherwise create a single NAT Gateway."
  type        = bool
  default     = false
}

variable "alb_ingress_cidr_blocks" {
  description = "CIDRs allowed to access the ALB listener."
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "alb_listener_port" {
  description = "ALB listener port."
  type        = number
  default     = 80
}

variable "alb_listener_protocol" {
  description = "ALB listener protocol."
  type        = string
  default     = "HTTP"
}

variable "health_check_path" {
  description = "Target group health check path."
  type        = string
  default     = "/"
}

variable "target_group_deregistration_delay" {
  description = "ALB target group deregistration delay in seconds."
  type        = number
  default     = 30
}

variable "container_image" {
  description = "Container image for ECS task."
  type        = string
  default     = "public.ecr.aws/docker/library/nginx:stable"
}

variable "container_port" {
  description = "Container port exposed by the ECS task and ALB target group."
  type        = number
  default     = 80
}

variable "task_cpu" {
  description = "Fargate task CPU units."
  type        = number
  default     = 256
}

variable "task_memory" {
  description = "Fargate task memory in MiB."
  type        = number
  default     = 512
}

variable "desired_count" {
  description = "Desired ECS service task count."
  type        = number
  default     = 1
}

variable "assign_public_ip" {
  description = "Whether to assign public IPs to ECS tasks."
  type        = bool
  default     = false
}

variable "ecs_enable_execute_command" {
  description = "Enable ECS Exec on the ECS service."
  type        = bool
  default     = false
}

variable "ecs_force_new_deployment" {
  description = "Force a new ECS service deployment on every apply."
  type        = bool
  default     = false
}

variable "ecs_deployment_minimum_healthy_percent" {
  description = "Lower bound (%), during deployment, on healthy tasks in the ECS service."
  type        = number
  default     = 50
}

variable "ecs_deployment_maximum_percent" {
  description = "Upper bound (%), during deployment, on running tasks in the ECS service."
  type        = number
  default     = 200
}

variable "ecs_health_check_grace_period_seconds" {
  description = "Grace period before ALB health checks affect ECS deployment health."
  type        = number
  default     = 60
}

variable "ecs_deployment_circuit_breaker_enable" {
  description = "Enable ECS deployment circuit breaker."
  type        = bool
  default     = true
}

variable "ecs_deployment_circuit_breaker_rollback" {
  description = "Automatically rollback failed ECS deployments when circuit breaker is enabled."
  type        = bool
  default     = true
}

variable "log_retention_days" {
  description = "CloudWatch log retention days for ECS task logs."
  type        = number
  default     = 7
}

variable "rds_engine" {
  description = "RDS engine."
  type        = string
  default     = "postgres"
}

variable "rds_engine_version" {
  description = "RDS engine version."
  type        = string
  default     = "15.5"
}

variable "rds_instance_class" {
  description = "RDS instance class."
  type        = string
  default     = "db.t3.micro"
}

variable "rds_allocated_storage" {
  description = "RDS allocated storage in GiB."
  type        = number
  default     = 20
}

variable "rds_backup_retention_period" {
  description = "RDS automated backup retention (days)."
  type        = number
  default     = 7
}

variable "rds_apply_immediately" {
  description = "Whether RDS modifications are applied immediately."
  type        = bool
  default     = true
}

variable "rds_skip_final_snapshot" {
  description = "Skip final snapshot on RDS deletion."
  type        = bool
  default     = true
}

variable "rds_multi_az" {
  description = "Enable Multi-AZ for the RDS instance."
  type        = bool
  default     = false
}

variable "db_name" {
  description = "Database name."
  type        = string
  default     = "appdb"
}

variable "db_username" {
  description = "Database username."
  type        = string
  default     = "appuser"
}

variable "db_password" {
  description = "Database password. If null, Terraform generates one."
  type        = string
  sensitive   = true
  default     = null
}

variable "db_port" {
  description = "Database port."
  type        = number
  default     = 5432
}

variable "s3_bucket_force_destroy" {
  description = "Allow force deletion of the S3 bucket with objects."
  type        = bool
  default     = false
}

variable "s3_versioning_enabled" {
  description = "Enable versioning on the S3 bucket."
  type        = bool
  default     = true
}
