variable "environment" {
  description = "Deployment environment name"
  type        = string
  default     = "staging"
}

variable "region" {
  description = "AWS region"
  type        = string
  default     = "us-west-2"
}
