provider "aws" {
  region = var.aws_region
}

module "stack" {
  source = "../../"

  name = var.name

  availability_zones  = ["${var.aws_region}a", "${var.aws_region}b"]
  public_subnet_cidrs = ["10.20.0.0/24", "10.20.1.0/24"]
  private_subnet_cidrs = [
    "10.20.10.0/24",
    "10.20.11.0/24"
  ]

  desired_count = 1

  tags = {
    Environment = "minimal"
    Example     = "true"
  }
}
