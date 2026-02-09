mock_provider "aws" {
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
}

# Test 1: ALB is internet-facing
run "alb_internet_facing" {
  command = plan

  variables {
    name_prefix = "alb-test"
    vpc_id      = "vpc-12345678"
    subnet_ids  = ["subnet-aaa", "subnet-bbb"]
  }

  assert {
    condition     = aws_lb.this.internal == false
    error_message = "ALB must be internet-facing."
  }

  assert {
    condition     = aws_lb.this.load_balancer_type == "application"
    error_message = "ALB must be an application load balancer."
  }
}

# Test 2: Default listener port is 80
run "default_listener_port" {
  command = plan

  variables {
    name_prefix = "alb-test"
    vpc_id      = "vpc-12345678"
    subnet_ids  = ["subnet-aaa", "subnet-bbb"]
  }

  assert {
    condition     = aws_lb_listener.this.port == 80
    error_message = "Default listener port should be 80."
  }

  assert {
    condition     = aws_lb_listener.this.protocol == "HTTP"
    error_message = "Default listener protocol should be HTTP."
  }
}

# Test 3: Target group uses IP target type for Fargate
run "target_group_ip_type" {
  command = plan

  variables {
    name_prefix = "alb-test"
    vpc_id      = "vpc-12345678"
    subnet_ids  = ["subnet-aaa", "subnet-bbb"]
  }

  assert {
    condition     = aws_lb_target_group.this.target_type == "ip"
    error_message = "Target group must use ip target type for Fargate."
  }
}

# Test 4: Security group allows ingress on listener port
run "security_group_ingress" {
  command = plan

  variables {
    name_prefix = "alb-test"
    vpc_id      = "vpc-12345678"
    subnet_ids  = ["subnet-aaa", "subnet-bbb"]
  }

  assert {
    condition     = aws_security_group.this.ingress != null
    error_message = "Security group should have ingress rules."
  }
}

# Test 5: Custom health check path
run "custom_health_check_path" {
  command = plan

  variables {
    name_prefix       = "alb-test"
    vpc_id            = "vpc-12345678"
    subnet_ids        = ["subnet-aaa", "subnet-bbb"]
    health_check_path = "/healthz"
  }

  assert {
    condition     = aws_lb_target_group.this.health_check[0].path == "/healthz"
    error_message = "Health check path should match input."
  }
}

# Test 6: Custom listener port
run "custom_listener_port" {
  command = plan

  variables {
    name_prefix   = "alb-test"
    vpc_id        = "vpc-12345678"
    subnet_ids    = ["subnet-aaa", "subnet-bbb"]
    listener_port = 8080
  }

  assert {
    condition     = aws_lb_listener.this.port == 8080
    error_message = "Listener port should match custom input."
  }
}

# Test 7: Invalid listener port rejected
run "invalid_listener_port_rejected" {
  command = plan

  variables {
    name_prefix   = "alb-test"
    vpc_id        = "vpc-12345678"
    subnet_ids    = ["subnet-aaa", "subnet-bbb"]
    listener_port = 0
  }

  expect_failures = [
    var.listener_port,
  ]
}

# Test 8: Invalid protocol rejected
run "invalid_protocol_rejected" {
  command = plan

  variables {
    name_prefix           = "alb-test"
    vpc_id                = "vpc-12345678"
    subnet_ids            = ["subnet-aaa", "subnet-bbb"]
    target_group_protocol = "TCP"
  }

  expect_failures = [
    var.target_group_protocol,
  ]
}

# Test 9: Tags propagated
run "tags_propagated" {
  command = plan

  variables {
    name_prefix = "alb-test"
    vpc_id      = "vpc-12345678"
    subnet_ids  = ["subnet-aaa", "subnet-bbb"]
    tags = {
      Environment = "test"
    }
  }

  assert {
    condition     = aws_lb.this.tags["Environment"] == "test"
    error_message = "Environment tag should be propagated to ALB."
  }

  assert {
    condition     = aws_lb.this.tags["ManagedBy"] == "terraform"
    error_message = "ManagedBy tag should be set on ALB."
  }
}
