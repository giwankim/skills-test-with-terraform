check "public_subnet_count_matches_azs" {
  assert {
    condition     = length(var.public_subnet_cidrs) == length(var.availability_zones)
    error_message = "public_subnet_cidrs must match availability_zones length."
  }
}

check "private_subnet_count_matches_azs" {
  assert {
    condition     = length(var.private_subnet_cidrs) == length(var.availability_zones)
    error_message = "private_subnet_cidrs must match availability_zones length."
  }
}

locals {
  name_prefix = lower(var.name_prefix)

  common_tags = merge(
    {
      ManagedBy = "terraform"
      Project   = local.name_prefix
    },
    var.tags
  )

  public_subnets = {
    for index, az in var.availability_zones : az => {
      availability_zone = az
      cidr_block        = try(var.public_subnet_cidrs[index], null)
    }
  }

  private_subnets = {
    for index, az in var.availability_zones : az => {
      availability_zone = az
      cidr_block        = try(var.private_subnet_cidrs[index], null)
    }
  }
}

resource "aws_vpc" "this" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-vpc"
  })
}

resource "aws_internet_gateway" "this" {
  vpc_id = aws_vpc.this.id

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-igw"
  })
}

resource "aws_subnet" "public" {
  for_each = local.public_subnets

  availability_zone       = each.value.availability_zone
  cidr_block              = each.value.cidr_block
  map_public_ip_on_launch = true
  vpc_id                  = aws_vpc.this.id

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-public-${each.value.availability_zone}"
    Tier = "public"
  })
}

resource "aws_subnet" "private" {
  for_each = local.private_subnets

  availability_zone       = each.value.availability_zone
  cidr_block              = each.value.cidr_block
  map_public_ip_on_launch = false
  vpc_id                  = aws_vpc.this.id

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-private-${each.value.availability_zone}"
    Tier = "private"
  })
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.this.id

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-public-rt"
  })
}

resource "aws_route" "public_default" {
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.this.id
  route_table_id         = aws_route_table.public.id
}

resource "aws_route_table_association" "public" {
  for_each = aws_subnet.public

  route_table_id = aws_route_table.public.id
  subnet_id      = each.value.id
}

resource "aws_eip" "nat" {
  count = var.create_nat_gateway ? 1 : 0

  domain = "vpc"

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-nat-eip"
  })
}

resource "aws_nat_gateway" "this" {
  count = var.create_nat_gateway ? 1 : 0

  allocation_id = aws_eip.nat[0].id
  subnet_id     = aws_subnet.public[var.availability_zones[0]].id

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-nat"
  })

  depends_on = [aws_internet_gateway.this]
}

resource "aws_route_table" "private" {
  for_each = aws_subnet.private

  vpc_id = aws_vpc.this.id

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-private-rt-${each.key}"
  })
}

resource "aws_route" "private_default" {
  for_each = var.create_nat_gateway ? aws_route_table.private : {}

  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.this[0].id
  route_table_id         = each.value.id
}

resource "aws_route_table_association" "private" {
  for_each = aws_subnet.private

  route_table_id = aws_route_table.private[each.key].id
  subnet_id      = each.value.id
}
