# --- Naming ---

variable "name" {
  description = "Name prefix used across all resources."
  type        = string

  validation {
    condition     = can(regex("^[a-z0-9-]+$", var.name))
    error_message = "name may only contain lowercase letters, numbers, and hyphens."
  }
}

variable "tags" {
  description = "Additional tags applied to all resources."
  type        = map(string)
  default     = {}
}

# --- VPC ---

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

# --- ALB ---

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

variable "alb_ingress_cidrs" {
  description = "CIDRs allowed to access the ALB listener."
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "health_check_path" {
  description = "Target group health check path."
  type        = string
  default     = "/"
}

variable "health_check_interval" {
  description = "Target group health check interval in seconds."
  type        = number
  default     = 30
}

variable "deregistration_delay" {
  description = "ALB target group deregistration delay in seconds."
  type        = number
  default     = 30
}

# --- ECS ---

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

variable "deployment_min_healthy_pct" {
  description = "Lower bound (%), during deployment, on healthy tasks in the ECS service."
  type        = number
  default     = 50
}

variable "deployment_max_pct" {
  description = "Upper bound (%), during deployment, on running tasks in the ECS service."
  type        = number
  default     = 200
}

variable "health_check_grace_period" {
  description = "Grace period in seconds before ALB health checks affect ECS deployment health."
  type        = number
  default     = 60
}

variable "enable_circuit_breaker" {
  description = "Enable ECS deployment circuit breaker with rollback."
  type        = bool
  default     = true
}

variable "log_retention_days" {
  description = "CloudWatch log retention days for ECS task logs."
  type        = number
  default     = 7
}

# --- RDS ---

variable "db_engine" {
  description = "RDS engine."
  type        = string
  default     = "postgres"
}

variable "db_engine_version" {
  description = "RDS engine version."
  type        = string
  default     = "15.5"
}

variable "db_instance_class" {
  description = "RDS instance class."
  type        = string
  default     = "db.t3.micro"
}

variable "db_allocated_storage" {
  description = "RDS allocated storage in GiB."
  type        = number
  default     = 20
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

variable "db_backup_retention" {
  description = "RDS automated backup retention (days)."
  type        = number
  default     = 7
}

variable "db_multi_az" {
  description = "Enable Multi-AZ for the RDS instance."
  type        = bool
  default     = false
}

variable "db_storage_encrypted" {
  description = "Enable encryption at rest for the RDS instance."
  type        = bool
  default     = true
}

variable "db_apply_immediately" {
  description = "Whether RDS modifications are applied immediately."
  type        = bool
  default     = true
}
