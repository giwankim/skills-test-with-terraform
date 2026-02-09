variable "bucket_name" {
  description = "Explicit name for the S3 bucket. Mutually exclusive with bucket_prefix."
  type        = string
  default     = null
}

variable "bucket_prefix" {
  description = "Prefix for the S3 bucket name. Used when bucket_name is null."
  type        = string
  default     = null
}

variable "force_destroy" {
  description = "Allow destruction of non-empty bucket. Use for test environments only."
  type        = bool
  default     = false
}

variable "versioning_enabled" {
  description = "Enable versioning on the S3 bucket."
  type        = bool
  default     = true
}

variable "sse_algorithm" {
  description = "Server-side encryption algorithm. Must be AES256 or aws:kms."
  type        = string
  default     = "AES256"

  validation {
    condition     = contains(["AES256", "aws:kms"], var.sse_algorithm)
    error_message = "sse_algorithm must be AES256 or aws:kms."
  }
}

variable "kms_master_key_id" {
  description = "KMS key ID for SSE-KMS encryption."
  type        = string
  default     = null
}

variable "bucket_key_enabled" {
  description = "Enable S3 Bucket Key for SSE-KMS to reduce KMS costs."
  type        = bool
  default     = true
}

variable "block_public_access" {
  description = "Block all public access to the S3 bucket."
  type        = bool
  default     = true
}

variable "lifecycle_rules" {
  description = "List of lifecycle rules for the S3 bucket."
  type = list(object({
    id     = string
    status = optional(string, "Enabled")
    prefix = optional(string)
    transitions = optional(list(object({
      days          = number
      storage_class = string
    })), [])
    expiration_days = optional(number)
  }))
  default = []
}

variable "logging_target_bucket" {
  description = "Target bucket for access logging. Enables logging when set."
  type        = string
  default     = null
}

variable "logging_target_prefix" {
  description = "Prefix for log objects in the target bucket."
  type        = string
  default     = "logs/"
}

variable "tags" {
  description = "Tags to apply to the S3 bucket."
  type        = map(string)
  default     = {}
}
