provider "aws" {
  region = "us-east-1"
}

run "apply_minimal_stack" {
  command = apply

  variables {
    availability_zones   = ["us-east-1a", "us-east-1b"]
    name_prefix          = "integstack"
    private_subnet_cidrs = ["10.88.10.0/24", "10.88.11.0/24"]
    public_subnet_cidrs  = ["10.88.0.0/24", "10.88.1.0/24"]
    vpc_cidr             = "10.88.0.0/16"

    ecs_desired_count = 1

    rds_allocated_storage   = 20
    rds_apply_immediately   = true
    rds_instance_class      = "db.t3.micro"
    rds_skip_final_snapshot = true

    s3_force_destroy = true
  }

  assert {
    condition     = output.vpc_id != ""
    error_message = "VPC should be created and output vpc_id should be set."
  }

  assert {
    condition     = output.alb_dns_name != ""
    error_message = "ALB should be created and output alb_dns_name should be set."
  }

  assert {
    condition     = output.ecs_cluster_arn != ""
    error_message = "ECS cluster should be created and output ecs_cluster_arn should be set."
  }

  assert {
    condition     = output.rds_address != ""
    error_message = "RDS should be created and output rds_address should be set."
  }

  assert {
    condition     = output.s3_bucket_arn != ""
    error_message = "S3 bucket should be created and output s3_bucket_arn should be set."
  }
}
