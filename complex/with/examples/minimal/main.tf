terraform {
  required_version = ">= 1.7.0, < 2.0.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

module "stack" {
  source = "../.."

  availability_zones   = var.availability_zones
  name_prefix          = var.name_prefix
  private_subnet_cidrs = var.private_subnet_cidrs
  public_subnet_cidrs  = var.public_subnet_cidrs
  rds_password         = var.rds_password

  tags = {
    Environment = "minimal"
    Example     = "minimal"
  }
}
