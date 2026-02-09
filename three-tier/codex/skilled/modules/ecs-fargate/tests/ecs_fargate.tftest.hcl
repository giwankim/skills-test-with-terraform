mock_provider "aws" {
  mock_resource "aws_ecs_cluster" {
    defaults = {
      arn  = "arn:aws:ecs:us-east-1:123456789012:cluster/mock-cluster"
      id   = "mock-cluster"
      name = "mock-cluster"
    }
  }

  mock_data "aws_region" {
    defaults = {
      name = "us-east-1"
    }
  }
}

# Test 1: ECS cluster created
run "ecs_cluster_created" {
  command = plan

  variables {
    name_prefix           = "ecs-test"
    vpc_id                = "vpc-12345678"
    subnet_ids            = ["subnet-aaa", "subnet-bbb"]
    alb_security_group_id = "sg-alb123"
    target_group_arn      = "arn:aws:elasticloadbalancing:us-east-1:123456789012:targetgroup/mock-tg/1234567890"
  }

  assert {
    condition     = aws_ecs_cluster.this.name == "ecs-test-cluster"
    error_message = "ECS cluster name should include name_prefix."
  }
}

# Test 2: Desired count matches input
run "desired_count_matches" {
  command = plan

  variables {
    name_prefix           = "ecs-test"
    vpc_id                = "vpc-12345678"
    subnet_ids            = ["subnet-aaa", "subnet-bbb"]
    alb_security_group_id = "sg-alb123"
    target_group_arn      = "arn:aws:elasticloadbalancing:us-east-1:123456789012:targetgroup/mock-tg/1234567890"
    desired_count         = 3
  }

  assert {
    condition     = aws_ecs_service.this.desired_count == 3
    error_message = "Desired count should match input."
  }
}

# Test 3: Launch type is FARGATE
run "launch_type_fargate" {
  command = plan

  variables {
    name_prefix           = "ecs-test"
    vpc_id                = "vpc-12345678"
    subnet_ids            = ["subnet-aaa", "subnet-bbb"]
    alb_security_group_id = "sg-alb123"
    target_group_arn      = "arn:aws:elasticloadbalancing:us-east-1:123456789012:targetgroup/mock-tg/1234567890"
  }

  assert {
    condition     = aws_ecs_service.this.launch_type == "FARGATE"
    error_message = "Launch type must be FARGATE."
  }
}

# Test 4: Network mode is awsvpc
run "network_mode_awsvpc" {
  command = plan

  variables {
    name_prefix           = "ecs-test"
    vpc_id                = "vpc-12345678"
    subnet_ids            = ["subnet-aaa", "subnet-bbb"]
    alb_security_group_id = "sg-alb123"
    target_group_arn      = "arn:aws:elasticloadbalancing:us-east-1:123456789012:targetgroup/mock-tg/1234567890"
  }

  assert {
    condition     = aws_ecs_task_definition.this.network_mode == "awsvpc"
    error_message = "Network mode must be awsvpc."
  }

  assert {
    condition     = contains(aws_ecs_task_definition.this.requires_compatibilities, "FARGATE")
    error_message = "Task definition must require FARGATE compatibility."
  }
}

# Test 5: Deployment knobs
run "deployment_knobs" {
  command = plan

  variables {
    name_prefix                        = "ecs-test"
    vpc_id                             = "vpc-12345678"
    subnet_ids                         = ["subnet-aaa", "subnet-bbb"]
    alb_security_group_id              = "sg-alb123"
    target_group_arn                   = "arn:aws:elasticloadbalancing:us-east-1:123456789012:targetgroup/mock-tg/1234567890"
    deployment_maximum_percent         = 250
    deployment_minimum_healthy_percent = 75
    force_new_deployment               = true
  }

  assert {
    condition     = aws_ecs_service.this.deployment_maximum_percent == 250
    error_message = "deployment_maximum_percent should reflect variable input."
  }

  assert {
    condition     = aws_ecs_service.this.deployment_minimum_healthy_percent == 75
    error_message = "deployment_minimum_healthy_percent should reflect variable input."
  }

  assert {
    condition     = aws_ecs_service.this.force_new_deployment == true
    error_message = "force_new_deployment should reflect variable input."
  }
}

# Test 6: Circuit breaker enabled by default
run "circuit_breaker_defaults" {
  command = plan

  variables {
    name_prefix           = "ecs-test"
    vpc_id                = "vpc-12345678"
    subnet_ids            = ["subnet-aaa", "subnet-bbb"]
    alb_security_group_id = "sg-alb123"
    target_group_arn      = "arn:aws:elasticloadbalancing:us-east-1:123456789012:targetgroup/mock-tg/1234567890"
  }

  assert {
    condition     = aws_ecs_service.this.deployment_circuit_breaker[0].enable == true
    error_message = "Circuit breaker should be enabled by default."
  }

  assert {
    condition     = aws_ecs_service.this.deployment_circuit_breaker[0].rollback == true
    error_message = "Circuit breaker rollback should be enabled by default."
  }
}

# Test 7: Invalid container port rejected
run "invalid_container_port_rejected" {
  command = plan

  variables {
    name_prefix           = "ecs-test"
    vpc_id                = "vpc-12345678"
    subnet_ids            = ["subnet-aaa", "subnet-bbb"]
    alb_security_group_id = "sg-alb123"
    target_group_arn      = "arn:aws:elasticloadbalancing:us-east-1:123456789012:targetgroup/mock-tg/1234567890"
    container_port        = 0
  }

  expect_failures = [
    var.container_port,
  ]
}

# Test 8: Tags propagated
run "tags_propagated" {
  command = plan

  variables {
    name_prefix           = "ecs-test"
    vpc_id                = "vpc-12345678"
    subnet_ids            = ["subnet-aaa", "subnet-bbb"]
    alb_security_group_id = "sg-alb123"
    target_group_arn      = "arn:aws:elasticloadbalancing:us-east-1:123456789012:targetgroup/mock-tg/1234567890"
    tags = {
      Environment = "test"
    }
  }

  assert {
    condition     = aws_ecs_cluster.this.tags["Environment"] == "test"
    error_message = "Environment tag should be propagated."
  }

  assert {
    condition     = aws_ecs_cluster.this.tags["ManagedBy"] == "terraform"
    error_message = "ManagedBy tag should be set."
  }
}
