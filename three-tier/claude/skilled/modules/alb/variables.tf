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
  description = "VPC ID where the ALB and security group are created"
  type        = string
}

variable "subnet_ids" {
  description = "Public subnet IDs for the ALB"
  type        = list(string)
}

variable "listener_port" {
  description = "Port exposed by the internet-facing ALB listener"
  type        = number
  default     = 80

  validation {
    condition     = var.listener_port > 0 && var.listener_port <= 65535
    error_message = "listener_port must be between 1 and 65535."
  }
}

variable "target_group_port" {
  description = "Port used by the ALB target group to reach backend targets"
  type        = number
  default     = 80

  validation {
    condition     = var.target_group_port > 0 && var.target_group_port <= 65535
    error_message = "target_group_port must be between 1 and 65535."
  }
}

variable "target_group_protocol" {
  description = "Protocol used by the ALB target group"
  type        = string
  default     = "HTTP"

  validation {
    condition     = contains(["HTTP", "HTTPS"], var.target_group_protocol)
    error_message = "target_group_protocol must be HTTP or HTTPS."
  }
}

variable "health_check_path" {
  description = "HTTP path used by the ALB target group health check"
  type        = string
  default     = "/"
}

variable "ingress_cidr_blocks" {
  description = "CIDR blocks allowed to reach the ALB"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "tags" {
  description = "Additional tags applied to all resources"
  type        = map(string)
  default     = {}
}
