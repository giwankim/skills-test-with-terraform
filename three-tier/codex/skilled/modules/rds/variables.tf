variable "name_prefix" {
  description = "Lowercase prefix used when naming resources"
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

variable "vpc_id" {
  description = "VPC ID where the RDS instance and security group are created"
  type        = string
}

variable "subnet_ids" {
  description = "Private subnet IDs for the RDS subnet group"
  type        = list(string)
}

variable "ecs_security_group_id" {
  description = "Security group ID of the ECS service (used for ingress rules)"
  type        = string
}

variable "engine" {
  description = "RDS database engine"
  type        = string
  default     = "postgres"

  validation {
    condition     = contains(["postgres", "mysql", "mariadb"], var.engine)
    error_message = "engine must be one of postgres, mysql, or mariadb."
  }
}

variable "engine_version" {
  description = "RDS engine version. Set to null to let AWS pick the default"
  type        = string
  default     = null
}

variable "instance_class" {
  description = "Instance class for the RDS instance"
  type        = string
  default     = "db.t3.micro"
}

variable "allocated_storage" {
  description = "Allocated storage (GiB) for the RDS instance"
  type        = number
  default     = 20
}

variable "db_name" {
  description = "Database name created in the RDS instance"
  type        = string
  default     = "appdb"
}

variable "username" {
  description = "Master username for RDS"
  type        = string
  default     = "appuser"
}

variable "password" {
  description = "Master password for RDS. If null, Terraform generates one and sends it using write-only arguments"
  type        = string
  default     = null
  sensitive   = true
}

variable "password_wo_version" {
  description = "Version marker for write-only password updates. Increment to rotate the password."
  type        = number
  default     = 1
}

variable "port" {
  description = "Port used by the RDS engine"
  type        = number
  default     = 5432
}

variable "multi_az" {
  description = "Whether to deploy RDS in Multi-AZ mode"
  type        = bool
  default     = false
}

variable "backup_retention_period" {
  description = "Backup retention period (days) for RDS"
  type        = number
  default     = 7
}

# Production-safe defaults; override in dev/test when faster iteration is preferred.
variable "apply_immediately" {
  description = "Whether RDS modifications are applied immediately"
  type        = bool
  default     = false
}

variable "skip_final_snapshot" {
  description = "Whether to skip a final snapshot when destroying RDS"
  type        = bool
  default     = false
}

variable "deletion_protection" {
  description = "Whether deletion protection is enabled for RDS"
  type        = bool
  default     = true
}

variable "tags" {
  description = "Additional tags applied to all resources"
  type        = map(string)
  default     = {}
}
