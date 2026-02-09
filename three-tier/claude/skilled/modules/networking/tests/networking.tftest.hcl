mock_provider "aws" {
  mock_resource "aws_vpc" {
    defaults = {
      arn        = "arn:aws:ec2:us-east-1:123456789012:vpc/vpc-12345678"
      cidr_block = "10.42.0.0/16"
      id         = "vpc-12345678"
    }
  }

  mock_resource "aws_subnet" {
    defaults = {
      id = "subnet-mocked"
    }
  }
}

# Test 1: VPC CIDR matches input
run "vpc_cidr_matches_input" {
  command = plan

  variables {
    name_prefix          = "net-test"
    availability_zones   = ["us-east-1a", "us-east-1b"]
    public_subnet_cidrs  = ["10.42.0.0/24", "10.42.1.0/24"]
    private_subnet_cidrs = ["10.42.10.0/24", "10.42.11.0/24"]
  }

  assert {
    condition     = aws_vpc.this.cidr_block == "10.42.0.0/16"
    error_message = "VPC CIDR should match the default value."
  }

  assert {
    condition     = aws_vpc.this.enable_dns_hostnames == true
    error_message = "VPC should have DNS hostnames enabled."
  }

  assert {
    condition     = aws_vpc.this.enable_dns_support == true
    error_message = "VPC should have DNS support enabled."
  }
}

# Test 2: Two public and two private subnets created
run "two_public_two_private_subnets" {
  command = plan

  variables {
    name_prefix          = "net-test"
    availability_zones   = ["us-east-1a", "us-east-1b"]
    public_subnet_cidrs  = ["10.42.0.0/24", "10.42.1.0/24"]
    private_subnet_cidrs = ["10.42.10.0/24", "10.42.11.0/24"]
  }

  assert {
    condition     = length(aws_subnet.public) == 2
    error_message = "Two public subnets should be planned."
  }

  assert {
    condition     = length(aws_subnet.private) == 2
    error_message = "Two private subnets should be planned."
  }
}

# Test 3: NAT gateway created by default
run "nat_gateway_created_by_default" {
  command = plan

  variables {
    name_prefix          = "net-test"
    availability_zones   = ["us-east-1a", "us-east-1b"]
    public_subnet_cidrs  = ["10.42.0.0/24", "10.42.1.0/24"]
    private_subnet_cidrs = ["10.42.10.0/24", "10.42.11.0/24"]
  }

  assert {
    condition     = length(aws_nat_gateway.this) == 1
    error_message = "NAT gateway should be created by default."
  }

  assert {
    condition     = length(aws_eip.nat) == 1
    error_message = "NAT EIP should be created by default."
  }
}

# Test 4: NAT gateway can be disabled
run "nat_gateway_disabled" {
  command = plan

  variables {
    name_prefix          = "net-test"
    availability_zones   = ["us-east-1a", "us-east-1b"]
    public_subnet_cidrs  = ["10.42.0.0/24", "10.42.1.0/24"]
    private_subnet_cidrs = ["10.42.10.0/24", "10.42.11.0/24"]
    create_nat_gateway   = false
  }

  assert {
    condition     = length(aws_nat_gateway.this) == 0
    error_message = "NAT gateway should not be created when disabled."
  }

  assert {
    condition     = length(aws_eip.nat) == 0
    error_message = "NAT EIP should not be created when disabled."
  }

  assert {
    condition     = length(aws_route.private_default) == 0
    error_message = "Private default routes should not be created without NAT."
  }
}

# Test 5: Tags propagated to VPC
run "tags_propagated" {
  command = plan

  variables {
    name_prefix          = "net-test"
    availability_zones   = ["us-east-1a", "us-east-1b"]
    public_subnet_cidrs  = ["10.42.0.0/24", "10.42.1.0/24"]
    private_subnet_cidrs = ["10.42.10.0/24", "10.42.11.0/24"]
    tags = {
      Environment = "test"
    }
  }

  assert {
    condition     = aws_vpc.this.tags["Environment"] == "test"
    error_message = "Environment tag should be propagated to VPC."
  }

  assert {
    condition     = aws_vpc.this.tags["ManagedBy"] == "terraform"
    error_message = "ManagedBy tag should be set on VPC."
  }
}

# Test 6: Invalid CIDR rejected
run "invalid_cidr_rejected" {
  command = plan

  variables {
    name_prefix          = "net-test"
    availability_zones   = ["us-east-1a", "us-east-1b"]
    public_subnet_cidrs  = ["10.42.0.0/24", "10.42.1.0/24"]
    private_subnet_cidrs = ["10.42.10.0/24", "10.42.11.0/24"]
    vpc_cidr             = "not-a-cidr"
  }

  expect_failures = [
    var.vpc_cidr,
  ]
}

# Test 7: Fewer than two AZs rejected
run "fewer_than_two_azs_rejected" {
  command = plan

  variables {
    name_prefix          = "net-test"
    availability_zones   = ["us-east-1a"]
    public_subnet_cidrs  = ["10.42.0.0/24"]
    private_subnet_cidrs = ["10.42.10.0/24"]
  }

  expect_failures = [
    var.availability_zones,
  ]
}

# Test 8: Invalid name_prefix rejected
run "invalid_name_prefix_rejected" {
  command = plan

  variables {
    name_prefix          = "INVALID_PREFIX!"
    availability_zones   = ["us-east-1a", "us-east-1b"]
    public_subnet_cidrs  = ["10.42.0.0/24", "10.42.1.0/24"]
    private_subnet_cidrs = ["10.42.10.0/24", "10.42.11.0/24"]
  }

  expect_failures = [
    var.name_prefix,
  ]
}

# Test 9: Custom VPC CIDR
run "custom_vpc_cidr" {
  command = plan

  variables {
    name_prefix          = "net-test"
    vpc_cidr             = "10.99.0.0/16"
    availability_zones   = ["us-east-1a", "us-east-1b"]
    public_subnet_cidrs  = ["10.99.0.0/24", "10.99.1.0/24"]
    private_subnet_cidrs = ["10.99.10.0/24", "10.99.11.0/24"]
  }

  assert {
    condition     = aws_vpc.this.cidr_block == "10.99.0.0/16"
    error_message = "VPC CIDR should match custom input."
  }
}
