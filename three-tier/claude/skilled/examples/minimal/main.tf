provider "aws" {
  region = "us-east-1"
}

module "three_tier" {
  source = "../../"

  name_prefix          = "minimal"
  availability_zones   = ["us-east-1a", "us-east-1b"]
  public_subnet_cidrs  = ["10.42.0.0/24", "10.42.1.0/24"]
  private_subnet_cidrs = ["10.42.10.0/24", "10.42.11.0/24"]

  tags = {
    Environment = "dev"
    Example     = "minimal"
  }
}
