mock_provider "aws" {
  mock_resource "aws_db_instance" {
    defaults = {
      address = "mock-db.abcdefghijkl.us-east-1.rds.amazonaws.com"
      arn     = "arn:aws:rds:us-east-1:123456789012:db:mock-db"
      id      = "mock-db"
      port    = 5432
    }
  }

  mock_resource "aws_ecs_cluster" {
    defaults = {
      arn  = "arn:aws:ecs:us-east-1:123456789012:cluster/mock-cluster"
      id   = "mock-cluster"
      name = "mock-cluster"
    }
  }

  mock_resource "aws_lb" {
    defaults = {
      arn      = "arn:aws:elasticloadbalancing:us-east-1:123456789012:loadbalancer/app/mock-alb/1234567890"
      dns_name = "mock-alb-123456.us-east-1.elb.amazonaws.com"
      id       = "arn:aws:elasticloadbalancing:us-east-1:123456789012:loadbalancer/app/mock-alb/1234567890"
      zone_id  = "Z35SXDOTRQ7X7K"
    }
  }

  mock_resource "aws_lb_target_group" {
    defaults = {
      arn = "arn:aws:elasticloadbalancing:us-east-1:123456789012:targetgroup/mock-tg/1234567890"
      id  = "arn:aws:elasticloadbalancing:us-east-1:123456789012:targetgroup/mock-tg/1234567890"
    }
  }

  mock_resource "aws_s3_bucket" {
    defaults = {
      arn    = "arn:aws:s3:::module-test-bucket"
      bucket = "module-test-bucket"
      id     = "module-test-bucket"
    }
  }

  mock_resource "aws_subnet" {
    defaults = {
      id = "subnet-mocked"
    }
  }

  mock_resource "aws_vpc" {
    defaults = {
      arn        = "arn:aws:ec2:us-east-1:123456789012:vpc/vpc-12345678"
      cidr_block = "10.99.0.0/16"
      id         = "vpc-12345678"
    }
  }
}

run "plan_with_mocked_provider" {
  command = plan

  variables {
    availability_zones   = ["us-east-1a", "us-east-1b"]
    name_prefix          = "mocked"
    private_subnet_cidrs = ["10.99.10.0/24", "10.99.11.0/24"]
    public_subnet_cidrs  = ["10.99.0.0/24", "10.99.1.0/24"]

    ecs_deployment_maximum_percent         = 250
    ecs_deployment_minimum_healthy_percent = 75
    ecs_force_new_deployment               = true
    rds_password                           = "MockPassword123!"
    s3_bucket_name                         = "module-test-bucket"
  }

  assert {
    condition     = aws_lb.this.internal == false
    error_message = "ALB must be internet-facing."
  }

  assert {
    condition     = length(aws_subnet.private) == 2
    error_message = "Two private subnets should be planned."
  }

  assert {
    condition     = length(aws_subnet.public) == 2
    error_message = "Two public subnets should be planned."
  }

  assert {
    condition     = aws_ecs_service.this.deployment_maximum_percent == 250
    error_message = "ECS deployment_maximum_percent should reflect variable input."
  }

  assert {
    condition     = aws_ecs_service.this.deployment_minimum_healthy_percent == 75
    error_message = "ECS deployment_minimum_healthy_percent should reflect variable input."
  }

  assert {
    condition     = aws_ecs_service.this.force_new_deployment == true
    error_message = "ECS force_new_deployment should reflect variable input."
  }

  assert {
    condition     = aws_lb_listener.http.port == 80
    error_message = "ALB listener must be configured on port 80."
  }

  assert {
    condition     = aws_db_instance.this.port == 5432
    error_message = "RDS port should be configured to 5432."
  }

  assert {
    condition     = aws_s3_bucket.this.bucket == "module-test-bucket"
    error_message = "S3 bucket name should match the configured bucket name."
  }
}
