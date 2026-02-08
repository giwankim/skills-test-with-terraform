output "alb_arn" {
  description = "ARN of the internet-facing ALB"
  value       = aws_lb.this.arn
}

output "alb_dns_name" {
  description = "Public DNS name of the internet-facing ALB"
  value       = aws_lb.this.dns_name
}

output "alb_security_group_id" {
  description = "Security group ID attached to the ALB"
  value       = aws_security_group.alb.id
}

output "alb_target_group_arn" {
  description = "ARN of the ALB target group for ECS tasks"
  value       = aws_lb_target_group.ecs.arn
}

output "ecs_cluster_arn" {
  description = "ARN of the ECS cluster"
  value       = aws_ecs_cluster.this.arn
}

output "ecs_cluster_name" {
  description = "Name of the ECS cluster"
  value       = aws_ecs_cluster.this.name
}

output "ecs_service_name" {
  description = "Name of the ECS service"
  value       = aws_ecs_service.this.name
}

output "ecs_task_definition_arn" {
  description = "ARN of the ECS task definition"
  value       = aws_ecs_task_definition.this.arn
}

output "ecs_to_rds_connectivity" {
  description = "Connection metadata showing ECS to RDS network wiring"
  value = {
    db_endpoint           = aws_db_instance.this.address
    db_port               = aws_db_instance.this.port
    ecs_security_group_id = aws_security_group.ecs.id
    rds_security_group_id = aws_security_group.rds.id
    rds_ingress_from_ecs  = true
    rds_subnet_group_name = aws_db_subnet_group.this.name
  }
}

output "private_subnet_ids" {
  description = "Private subnet IDs used by ECS and RDS"
  value       = [for subnet in aws_subnet.private : subnet.id]
}

output "public_subnet_ids" {
  description = "Public subnet IDs used by the ALB"
  value       = [for subnet in aws_subnet.public : subnet.id]
}

output "rds_address" {
  description = "RDS hostname for application connections"
  value       = aws_db_instance.this.address
}

output "rds_arn" {
  description = "ARN of the RDS instance"
  value       = aws_db_instance.this.arn
}

output "rds_db_name" {
  description = "Database name configured on RDS"
  value       = aws_db_instance.this.db_name
}

output "rds_port" {
  description = "RDS port exposed to ECS"
  value       = aws_db_instance.this.port
}

output "rds_security_group_id" {
  description = "Security group ID attached to RDS"
  value       = aws_security_group.rds.id
}

output "s3_bucket_arn" {
  description = "ARN of the S3 bucket"
  value       = aws_s3_bucket.this.arn
}

output "s3_bucket_id" {
  description = "ID of the S3 bucket"
  value       = aws_s3_bucket.this.id
}

output "s3_bucket_name" {
  description = "Name of the S3 bucket"
  value       = aws_s3_bucket.this.bucket
}

output "vpc_id" {
  description = "ID of the VPC"
  value       = aws_vpc.this.id
}
