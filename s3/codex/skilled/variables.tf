variable "bucket_name" {
  description = "Name of the S3 bucket to create."
  type        = string

  validation {
    condition     = can(regex("^[a-z0-9][a-z0-9.-]{1,61}[a-z0-9]$", var.bucket_name))
    error_message = "bucket_name must be 3-63 characters, lower-case alphanumeric, dot, or hyphen."
  }

  nullable = false
}

variable "force_destroy" {
  description = "Whether to allow deletion of non-empty bucket contents when destroying the bucket."
  type        = bool
  default     = false

  nullable = false
}

variable "versioning_enabled" {
  description = "Whether to enable bucket object versioning."
  type        = bool
  default     = true

  nullable = false
}

variable "sse_algorithm" {
  description = "Default server-side encryption algorithm for bucket objects. Valid values: AES256 or aws:kms."
  type        = string
  default     = "AES256"

  validation {
    condition     = contains(["AES256", "aws:kms"], var.sse_algorithm)
    error_message = "sse_algorithm must be one of: AES256, aws:kms."
  }

  nullable = false
}

variable "kms_key_id" {
  description = "KMS key ID or ARN to use when sse_algorithm is aws:kms. Leave null for AES256."
  type        = string
  default     = null
}

variable "bucket_key_enabled" {
  description = "Whether to enable S3 Bucket Keys for KMS encryption cost optimization."
  type        = bool
  default     = true

  nullable = false
}

variable "object_ownership" {
  description = "Object ownership setting for the bucket."
  type        = string
  default     = "BucketOwnerEnforced"

  validation {
    condition = contains(
      ["BucketOwnerEnforced", "BucketOwnerPreferred", "ObjectWriter"],
      var.object_ownership
    )
    error_message = "object_ownership must be one of: BucketOwnerEnforced, BucketOwnerPreferred, ObjectWriter."
  }

  nullable = false
}

variable "block_public_acls" {
  description = "Whether Amazon S3 should block public ACLs for this bucket."
  type        = bool
  default     = true

  nullable = false
}

variable "block_public_policy" {
  description = "Whether Amazon S3 should block public bucket policies for this bucket."
  type        = bool
  default     = true

  nullable = false
}

variable "ignore_public_acls" {
  description = "Whether Amazon S3 should ignore public ACLs for this bucket."
  type        = bool
  default     = true

  nullable = false
}

variable "restrict_public_buckets" {
  description = "Whether Amazon S3 should restrict public bucket policies for this bucket."
  type        = bool
  default     = true

  nullable = false
}

variable "tags" {
  description = "Tags to apply to resources that support tags."
  type        = map(string)
  default     = {}

  nullable = false
}
