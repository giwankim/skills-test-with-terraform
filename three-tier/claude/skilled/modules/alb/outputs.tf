output "alb_arn" {
  description = "ARN of the internet-facing ALB"
  value       = aws_lb.this.arn
}

output "alb_dns_name" {
  description = "Public DNS name of the internet-facing ALB"
  value       = aws_lb.this.dns_name
}

output "target_group_arn" {
  description = "ARN of the ALB target group"
  value       = aws_lb_target_group.this.arn
}

output "security_group_id" {
  description = "Security group ID attached to the ALB"
  value       = aws_security_group.this.id
}

output "listener_arn" {
  description = "ARN of the HTTP listener"
  value       = aws_lb_listener.this.arn
}
