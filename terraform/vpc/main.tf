locals {
  number_of_azs = 2
}

resource "aws_vpc" "vpc" {
  cidr_block           = var.cidr_block
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = var.name

  }
}

resource "aws_internet_gateway" "internet_gateway" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = var.name

  }
}

resource "random_shuffle" "availability_zones" {
  input        = data.aws_availability_zones.az.names
  result_count = local.number_of_azs
}

resource "aws_subnet" "public" {
  count = local.number_of_azs

  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = cidrsubnet(aws_vpc.vpc.cidr_block, 6, count.index)
  availability_zone       = random_shuffle.availability_zones.result[count.index]
  map_public_ip_on_launch = true

  tags = {
    Name = "${var.name}-public-${random_shuffle.availability_zones.result[count.index]}"
  }
}

resource "aws_subnet" "private" {
  count = local.number_of_azs

  vpc_id            = aws_vpc.vpc.id
  cidr_block        = cidrsubnet(aws_vpc.vpc.cidr_block, 2, 1 + count.index)
  availability_zone = random_shuffle.availability_zones.result[count.index]

  tags = {
    Name = "${var.name}-private-${random_shuffle.availability_zones.result[count.index]}"
  }
}

resource "aws_eip" "nat_gw" {
  count = local.number_of_azs

  tags = {
    Name = "${var.name}-natgw-${count.index}"
  }

  depends_on = [aws_internet_gateway.internet_gateway]
}

resource "aws_nat_gateway" "nat_gw" {
  count = local.number_of_azs

  allocation_id = aws_eip.nat_gw[count.index].id
  subnet_id     = aws_subnet.public[count.index].id

  tags = {
    Name = "${var.name}-natgw-${aws_subnet.public[count.index].availability_zone}"
  }

  depends_on = [aws_internet_gateway.internet_gateway]
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "${var.name}-public"
  }
}

resource "aws_route" "public" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.internet_gateway.id
}

resource "aws_route_table_association" "public" {
  count = local.number_of_azs

  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table" "private" {
  count = local.number_of_azs

  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "${var.name}-private-${aws_subnet.private[count.index].availability_zone}"
  }
}

resource "aws_route" "private" {
  count = local.number_of_azs

  route_table_id         = aws_route_table.private[count.index].id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.nat_gw[count.index].id
}

resource "aws_route_table_association" "private" {
  count = local.number_of_azs

  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private[count.index].id
}

resource "aws_db_subnet_group" "db_subnet_group" {
  name        = "${var.name}-db"
  description = "${var.name} DB subnet group"
  subnet_ids  = aws_subnet.private[*].id

  tags = {
    Name = "${var.name}-db"
  }
}