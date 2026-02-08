output "alb_dns_name" {
  description = "ALB DNS name from the minimal example"
  value       = module.stack.alb_dns_name
}

output "rds_address" {
  description = "RDS endpoint from the minimal example"
  value       = module.stack.rds_address
}

output "s3_bucket_name" {
  description = "S3 bucket name from the minimal example"
  value       = module.stack.s3_bucket_name
}
