variable "availability_zones" {
  description = "Availability zones used by the minimal example"
  type        = list(string)
  default     = ["us-east-1a", "us-east-1b"]
}

variable "aws_region" {
  description = "AWS region for the minimal example"
  type        = string
  default     = "us-east-1"
}

variable "name_prefix" {
  description = "Resource naming prefix for the minimal example"
  type        = string
  default     = "awss-min"
}

variable "private_subnet_cidrs" {
  description = "Private subnet CIDRs for the minimal example"
  type        = list(string)
  default     = ["10.42.10.0/24", "10.42.11.0/24"]
}

variable "public_subnet_cidrs" {
  description = "Public subnet CIDRs for the minimal example"
  type        = list(string)
  default     = ["10.42.0.0/24", "10.42.1.0/24"]
}

variable "rds_password" {
  description = "RDS password for the minimal example"
  type        = string
  default     = "ExamplePassword123!"
  sensitive   = true
}
