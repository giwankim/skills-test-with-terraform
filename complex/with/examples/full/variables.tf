variable "availability_zones" {
  description = "Availability zones used by the full example"
  type        = list(string)
  default     = ["us-east-1a", "us-east-1b", "us-east-1c"]
}

variable "aws_region" {
  description = "AWS region for the full example"
  type        = string
  default     = "us-east-1"
}

variable "name_prefix" {
  description = "Resource naming prefix for the full example"
  type        = string
  default     = "awss-full"
}

variable "private_subnet_cidrs" {
  description = "Private subnet CIDRs for the full example"
  type        = list(string)
  default     = ["10.50.10.0/24", "10.50.11.0/24", "10.50.12.0/24"]
}

variable "public_subnet_cidrs" {
  description = "Public subnet CIDRs for the full example"
  type        = list(string)
  default     = ["10.50.0.0/24", "10.50.1.0/24", "10.50.2.0/24"]
}

variable "rds_password" {
  description = "RDS password for the full example"
  type        = string
  default     = "ExamplePassword123!"
  sensitive   = true
}

variable "vpc_cidr" {
  description = "VPC CIDR for the full example"
  type        = string
  default     = "10.50.0.0/16"
}
