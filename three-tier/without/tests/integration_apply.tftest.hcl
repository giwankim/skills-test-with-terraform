variables {
  aws_region = "us-east-1"
  name       = "tf-integration-three-tier"
}

run "apply_minimal_example" {
  command = apply

  module {
    source = "./examples/minimal"
  }

  variables {
    aws_region = var.aws_region
    name       = var.name
  }

  assert {
    condition     = output.vpc_id != ""
    error_message = "Expected non-empty vpc_id output after apply."
  }

  assert {
    condition     = output.alb_dns_name != ""
    error_message = "Expected non-empty alb_dns_name output after apply."
  }

  assert {
    condition     = output.rds_endpoint != ""
    error_message = "Expected non-empty rds_endpoint output after apply."
  }
}
