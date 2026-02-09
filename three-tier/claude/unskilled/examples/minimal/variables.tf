variable "aws_region" {
  description = "AWS region for the minimal example."
  type        = string
  default     = "us-east-1"
}

variable "name" {
  description = "Name prefix for resources in this example."
  type        = string
  default     = "three-tier-minimal"
}
