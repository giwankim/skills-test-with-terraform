variable "bucket_name" {
  description = "Globally unique name for the S3 bucket."
  type        = string

  validation {
    condition     = can(regex("^[a-z0-9][a-z0-9.-]{1,61}[a-z0-9]$", var.bucket_name))
    error_message = "bucket_name must be 3-63 characters and contain only lowercase letters, numbers, dots, and hyphens."
  }
}

variable "force_destroy" {
  description = "Delete all objects in the bucket when destroying this resource."
  type        = bool
  default     = false
}

variable "versioning_enabled" {
  description = "Whether to enable S3 object versioning."
  type        = bool
  default     = true
}

variable "block_public_access" {
  description = "Whether to block all forms of public access for this bucket."
  type        = bool
  default     = true
}

variable "sse_algorithm" {
  description = "Server-side encryption algorithm. Valid values: AES256, aws:kms."
  type        = string
  default     = "AES256"

  validation {
    condition     = contains(["AES256", "aws:kms"], var.sse_algorithm)
    error_message = "sse_algorithm must be either AES256 or aws:kms."
  }
}

variable "kms_key_arn" {
  description = "KMS key ARN used when sse_algorithm is aws:kms."
  type        = string
  default     = null
  nullable    = true
}

variable "tags" {
  description = "Tags to apply to all resources."
  type        = map(string)
  default     = {}
}
