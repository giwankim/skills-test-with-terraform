resource "terraform_data" "input_validation" {
  input = var.name

  lifecycle {
    precondition {
      condition = (
        length(var.public_subnet_cidrs) >= 2 &&
        length(var.private_subnet_cidrs) >= 2 &&
        length(var.availability_zones) >= 2
      )
      error_message = "At least two public subnets, two private subnets, and two AZs are required for this multi-AZ stack."
    }

    precondition {
      condition = (
        length(var.public_subnet_cidrs) == length(var.private_subnet_cidrs) &&
        length(var.public_subnet_cidrs) == length(var.availability_zones)
      )
      error_message = "availability_zones, public_subnet_cidrs, and private_subnet_cidrs must have the same number of elements."
    }
  }
}
