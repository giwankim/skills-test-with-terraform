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
  description = "VPC ID where the ECS service and security group are created"
  type        = string
}

variable "subnet_ids" {
  description = "Private subnet IDs for the ECS service"
  type        = list(string)
}

variable "alb_security_group_id" {
  description = "Security group ID of the ALB (used for ingress rules)"
  type        = string
}

variable "target_group_arn" {
  description = "ARN of the ALB target group"
  type        = string
}

variable "container_image" {
  description = "Container image used by the ECS task definition"
  type        = string
  default     = "public.ecr.aws/docker/library/nginx:stable"
}

variable "container_name" {
  description = "Container name referenced by the ECS service load balancer configuration"
  type        = string
  default     = "app"
}

variable "container_port" {
  description = "Container port exposed by the ECS task"
  type        = number
  default     = 80

  validation {
    condition     = var.container_port > 0 && var.container_port <= 65535
    error_message = "container_port must be between 1 and 65535."
  }
}

variable "container_cpu" {
  description = "CPU units assigned to the ECS task definition"
  type        = number
  default     = 256
}

variable "container_memory" {
  description = "Memory (MiB) assigned to the ECS task definition"
  type        = number
  default     = 512
}

variable "container_environment" {
  description = "Environment variables injected into the ECS container"
  type        = map(string)
  default     = {}
}

variable "desired_count" {
  description = "Desired number of ECS tasks in the service"
  type        = number
  default     = 1
}

variable "deployment_maximum_percent" {
  description = "Deployment knob: upper bound of tasks allowed during deployment"
  type        = number
  default     = 200
}

variable "deployment_minimum_healthy_percent" {
  description = "Deployment knob: minimum healthy tasks maintained during deployment"
  type        = number
  default     = 50
}

variable "deployment_circuit_breaker_enable" {
  description = "Deployment knob: enable ECS deployment circuit breaker"
  type        = bool
  default     = true
}

variable "deployment_circuit_breaker_rollback" {
  description = "Deployment knob: rollback failed deployments when circuit breaker is enabled"
  type        = bool
  default     = true
}

variable "force_new_deployment" {
  description = "Deployment knob: force a new ECS deployment on each apply"
  type        = bool
  default     = false
}

variable "enable_execute_command" {
  description = "Whether ECS Exec is enabled for the service"
  type        = bool
  default     = false
}

variable "health_check_grace_period_seconds" {
  description = "Deployment knob: grace period before ECS starts ALB health checks"
  type        = number
  default     = 60
}

variable "wait_for_steady_state" {
  description = "Whether Terraform waits for ECS service steady state during apply"
  type        = bool
  default     = false
}

variable "log_retention_in_days" {
  description = "CloudWatch Logs retention period for ECS application logs"
  type        = number
  default     = 14
}

variable "tags" {
  description = "Additional tags applied to all resources"
  type        = map(string)
  default     = {}
}
