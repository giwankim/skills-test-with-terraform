variable "name_prefix" {
  description = "Lowercase prefix used when naming stack resources"
  type        = string

  validation {
    condition     = can(regex("^[a-z0-9-]+$", var.name_prefix))
    error_message = "name_prefix must contain only lowercase letters, numbers, and hyphens."
  }

  validation {
    condition     = length(var.name_prefix) <= 20
    error_message = "name_prefix must be 20 characters or fewer."
  }
}

variable "availability_zones" {
  description = "Availability zones used for both public and private subnets"
  type        = list(string)

  validation {
    condition     = length(var.availability_zones) >= 2
    error_message = "availability_zones must include at least two AZs."
  }
}

variable "vpc_cidr" {
  description = "Primary CIDR block for the VPC"
  type        = string
  default     = "10.42.0.0/16"

  validation {
    condition     = can(cidrnetmask(var.vpc_cidr))
    error_message = "vpc_cidr must be a valid IPv4 CIDR block."
  }
}

variable "public_subnet_cidrs" {
  description = "CIDR blocks for public subnets (one per availability zone)"
  type        = list(string)

  validation {
    condition     = alltrue([for cidr in var.public_subnet_cidrs : can(cidrnetmask(cidr))])
    error_message = "Each public_subnet_cidrs value must be a valid IPv4 CIDR block."
  }
}

variable "private_subnet_cidrs" {
  description = "CIDR blocks for private subnets (one per availability zone)"
  type        = list(string)

  validation {
    condition     = alltrue([for cidr in var.private_subnet_cidrs : can(cidrnetmask(cidr))])
    error_message = "Each private_subnet_cidrs value must be a valid IPv4 CIDR block."
  }
}

variable "create_nat_gateway" {
  description = "Whether to create a NAT Gateway for private subnet internet egress"
  type        = bool
  default     = true
}

variable "alb_listener_port" {
  description = "Port exposed by the internet-facing ALB listener"
  type        = number
  default     = 80

  validation {
    condition     = var.alb_listener_port > 0 && var.alb_listener_port <= 65535
    error_message = "alb_listener_port must be between 1 and 65535."
  }
}

variable "alb_health_check_path" {
  description = "HTTP path used by the ALB target group health check"
  type        = string
  default     = "/"
}

variable "ecs_container_image" {
  description = "Container image used by the ECS task definition"
  type        = string
  default     = "public.ecr.aws/docker/library/nginx:stable"
}

variable "ecs_container_name" {
  description = "Container name referenced by the ECS service load balancer configuration"
  type        = string
  default     = "app"
}

variable "ecs_container_port" {
  description = "Container port exposed by the ECS task and target group"
  type        = number
  default     = 80

  validation {
    condition     = var.ecs_container_port > 0 && var.ecs_container_port <= 65535
    error_message = "ecs_container_port must be between 1 and 65535."
  }
}

variable "ecs_container_cpu" {
  description = "CPU units assigned to the ECS task definition"
  type        = number
  default     = 256
}

variable "ecs_container_memory" {
  description = "Memory (MiB) assigned to the ECS task definition"
  type        = number
  default     = 512
}

variable "ecs_container_environment" {
  description = "Additional environment variables injected into the ECS container"
  type        = map(string)
  default     = {}
}

variable "ecs_desired_count" {
  description = "Desired number of ECS tasks in the service"
  type        = number
  default     = 1
}

variable "rds_engine" {
  description = "RDS database engine"
  type        = string
  default     = "postgres"

  validation {
    condition     = contains(["postgres", "mysql", "mariadb"], var.rds_engine)
    error_message = "rds_engine must be one of postgres, mysql, or mariadb."
  }
}

variable "rds_engine_version" {
  description = "RDS engine version. Set to null to let AWS pick the default"
  type        = string
  default     = null
}

variable "rds_instance_class" {
  description = "Instance class for the RDS instance"
  type        = string
  default     = "db.t3.micro"
}

variable "rds_allocated_storage" {
  description = "Allocated storage (GiB) for the RDS instance"
  type        = number
  default     = 20
}

variable "rds_db_name" {
  description = "Database name created in the RDS instance"
  type        = string
  default     = "appdb"
}

variable "rds_username" {
  description = "Master username for RDS"
  type        = string
  default     = "appuser"
}

variable "rds_password" {
  description = "Master password for RDS. If null, Terraform generates one and passes it via write-only arguments in the RDS module"
  type        = string
  default     = null
  sensitive   = true
}

variable "rds_port" {
  description = "Port used by the RDS engine"
  type        = number
  default     = 5432
}

variable "rds_multi_az" {
  description = "Whether to deploy RDS in Multi-AZ mode"
  type        = bool
  default     = false
}

variable "rds_skip_final_snapshot" {
  description = "Whether to skip a final snapshot when destroying RDS"
  type        = bool
  default     = false
}

variable "tags" {
  description = "Additional tags applied to all resources"
  type        = map(string)
  default     = {}
}
