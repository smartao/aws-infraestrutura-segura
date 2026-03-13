resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  lifecycle {
    precondition {
      condition     = length(var.public_subnet_cidrs) >= 2
      error_message = "VALIDATION: At least two public subnets must be provided."
    }

    precondition {
      condition     = length(var.private_subnet_cidrs) >= 2
      error_message = "VALIDATION: At least two private subnets must be provided."
    }

    precondition {
      condition     = length(var.azs) == length(var.public_subnet_cidrs)
      error_message = "VALIDATION: azs and public_subnet_cidrs must have the same number of entries."
    }

    precondition {
      condition     = length(var.azs) == length(var.private_subnet_cidrs)
      error_message = "VALIDATION: azs and private_subnet_cidrs must have the same number of entries."
    }

    precondition {
      condition     = length(distinct(var.azs)) == length(var.azs)
      error_message = "VALIDATION: azs must not contain duplicate Availability Zones."
    }
  }

  tags = merge(local.common_tags, {
    Name = "${var.name_prefix}-main-vpc"
  })
}

resource "aws_subnet" "public" {
  for_each                = local.public_subnets
  vpc_id                  = aws_vpc.main.id
  cidr_block              = each.value.cidr
  availability_zone       = each.value.az
  map_public_ip_on_launch = true

  tags = merge(local.common_tags, {
    Name = "${var.name_prefix}-public-subnet-${each.value.az}"
    Tier = "public"
  })
}

resource "aws_subnet" "private" {
  for_each                = local.private_subnets
  vpc_id                  = aws_vpc.main.id
  cidr_block              = each.value.cidr
  availability_zone       = each.value.az
  map_public_ip_on_launch = false

  tags = merge(local.common_tags, {
    Name = "${var.name_prefix}-private-subnet-${each.value.az}"
    Tier = "private"
  })
}

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = merge(local.common_tags, {
    Name = "${var.name_prefix}-main-igw"
  })
}

resource "aws_eip" "nat" {
  for_each   = local.public_subnets
  domain     = "vpc"
  depends_on = [aws_internet_gateway.main]

  tags = merge(local.common_tags, {
    Name = "${var.name_prefix}-nat-eip-${each.value.az}"
  })
}

resource "aws_nat_gateway" "main" {
  for_each      = local.public_subnets
  allocation_id = aws_eip.nat[each.key].id
  subnet_id     = aws_subnet.public[each.key].id

  tags = merge(local.common_tags, {
    Name = "${var.name_prefix}-main-nat-gateway-${each.value.az}"
  })
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  tags = merge(local.common_tags, {
    Name = "${var.name_prefix}-public-rt"
  })
}

resource "aws_route_table" "private" {
  for_each = local.private_subnets
  vpc_id   = aws_vpc.main.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.main[each.key].id
  }

  tags = merge(local.common_tags, {
    Name = "${var.name_prefix}-private-rt-${each.value.az}"
  })
}

resource "aws_route_table_association" "public" {
  for_each       = local.public_subnets
  subnet_id      = aws_subnet.public[each.key].id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "private" {
  for_each       = local.private_subnets
  subnet_id      = aws_subnet.private[each.key].id
  route_table_id = aws_route_table.private[each.key].id
}
