output "bucket_id" {
  description = "The name of the bucket."
  value       = module.s3_bucket.bucket_id
}

output "bucket_arn" {
  description = "The ARN of the bucket."
  value       = module.s3_bucket.bucket_arn
}

output "log_bucket_id" {
  description = "The name of the log bucket."
  value       = module.log_bucket.bucket_id
}
