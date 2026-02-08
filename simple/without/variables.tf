variable "name_prefix" {
  description = "Lowercase prefix used when naming module resources"
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

variable "bucket_name" {
  description = "S3 bucket name. If null, Terraform generates a globally unique name"
  type        = string
  default     = null
}

variable "force_destroy" {
  description = "Whether Terraform can delete non-empty S3 buckets"
  type        = bool
  default     = false
}

variable "versioning_enabled" {
  description = "Whether S3 bucket versioning is enabled"
  type        = bool
  default     = true
}

variable "sse_algorithm" {
  description = "Server-side encryption algorithm for the S3 bucket"
  type        = string
  default     = "AES256"

  validation {
    condition     = contains(["AES256", "aws:kms"], var.sse_algorithm)
    error_message = "sse_algorithm must be AES256 or aws:kms."
  }
}

variable "kms_key_arn" {
  description = "ARN of the KMS key for SSE-KMS encryption"
  type        = string
  default     = null
}

variable "noncurrent_version_expiration_days" {
  description = "Days before noncurrent object versions expire. Set to null to disable the lifecycle rule"
  type        = number
  default     = 90
}

variable "tags" {
  description = "Additional tags applied to all resources"
  type        = map(string)
  default     = {}
}
