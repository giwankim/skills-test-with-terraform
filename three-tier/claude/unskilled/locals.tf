locals {
  common_tags = merge(
    {
      ManagedBy = "terraform"
      Module    = "three-tier"
      Name      = var.name
    },
    var.tags
  )

  public_subnets = {
    for idx, cidr in var.public_subnet_cidrs : tostring(idx) => {
      cidr = cidr
      az   = try(var.availability_zones[idx], null)
    }
  }

  private_subnets = {
    for idx, cidr in var.private_subnet_cidrs : tostring(idx) => {
      cidr = cidr
      az   = try(var.availability_zones[idx], null)
    }
  }

  nat_gateway_subnet_keys = var.create_nat_gateway_per_az ? keys(local.public_subnets) : ["0"]

  effective_db_password = var.db_password != null ? var.db_password : random_password.db[0].result
}
