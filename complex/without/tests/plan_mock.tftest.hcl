mock_provider "aws" {}
mock_provider "random" {}

run "plan_with_mocked_providers" {
  command = plan

  module {
    source = "./"
  }

  variables {
    name                    = "tf-test-mock"
    availability_zones      = ["us-east-1a", "us-east-1b"]
    public_subnet_cidrs     = ["10.40.0.0/24", "10.40.1.0/24"]
    private_subnet_cidrs    = ["10.40.10.0/24", "10.40.11.0/24"]
    db_password             = "ExamplePassword123!"
    desired_count           = 1
    rds_skip_final_snapshot = true
  }

  assert {
    condition     = aws_lb.this.internal == false
    error_message = "ALB should be internet-facing."
  }

  assert {
    condition     = aws_ecs_service.this.desired_count == var.desired_count
    error_message = "ECS desired_count should match test input."
  }

  assert {
    condition     = aws_db_instance.this.publicly_accessible == false
    error_message = "RDS should be private (not publicly accessible)."
  }
}
