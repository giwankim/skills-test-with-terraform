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

variable "vpc_cidr" {
  description = "Primary CIDR block for the VPC"
  type        = string
  default     = "10.42.0.0/16"

  validation {
    condition     = can(cidrnetmask(var.vpc_cidr))
    error_message = "vpc_cidr must be a valid IPv4 CIDR block."
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

variable "tags" {
  description = "Additional tags applied to all resources"
  type        = map(string)
  default     = {}
}
