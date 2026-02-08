output "vpc_id" {
  value = module.stack.vpc_id
}

output "alb_dns_name" {
  value = module.stack.alb_dns_name
}

output "ecs_service_name" {
  value = module.stack.ecs_service_name
}

output "rds_endpoint" {
  value = module.stack.rds_endpoint
}

output "s3_bucket_name" {
  value = module.stack.s3_bucket_name
}
