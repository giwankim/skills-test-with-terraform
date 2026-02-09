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

  mock_resource "aws_subnet" {
    defaults = {
      id = "subnet-mocked"
    }
  }

  mock_resource "aws_vpc" {
    defaults = {
      arn        = "arn:aws:ec2:us-east-1:123456789012:vpc/vpc-12345678"
      cidr_block = "10.42.0.0/16"
      id         = "vpc-12345678"
    }
  }

  mock_data "aws_region" {
    defaults = {
      name = "us-east-1"
    }
  }
}

mock_provider "random" {}

# Test: Full-stack wiring with plan
run "full_stack_wiring" {
  command = plan

  variables {
    name_prefix          = "integration"
    availability_zones   = ["us-east-1a", "us-east-1b"]
    public_subnet_cidrs  = ["10.42.0.0/24", "10.42.1.0/24"]
    private_subnet_cidrs = ["10.42.10.0/24", "10.42.11.0/24"]
    rds_password         = "MockPassword123!"
  }

  # Networking: two public and two private subnets
  assert {
    condition     = length(module.networking.public_subnet_ids) == 2
    error_message = "Should have 2 public subnet IDs."
  }

  assert {
    condition     = length(module.networking.private_subnet_ids) == 2
    error_message = "Should have 2 private subnet IDs."
  }

  # ECS: cluster name reflects prefix
  assert {
    condition     = module.ecs_fargate.cluster_name == "integration-cluster"
    error_message = "ECS cluster name should include the name prefix."
  }

  # ECS service name
  assert {
    condition     = module.ecs_fargate.service_name == "integration-service"
    error_message = "ECS service name should include the name prefix."
  }

  # RDS: default database name
  assert {
    condition     = module.rds.db_name == "appdb"
    error_message = "RDS database name should be appdb."
  }

  # RDS: default username
  assert {
    condition     = module.rds.username == "appuser"
    error_message = "RDS username should be appuser."
  }
}
