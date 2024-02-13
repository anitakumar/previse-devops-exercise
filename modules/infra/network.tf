# provider "aws" {
#   region = var.region
# }

terraform {
  required_providers {
    aws = {
      source                = "hashicorp/aws"
      version               = ">= 0.14.0"
      configuration_aliases = [aws.region]
    }
  }
}


data "aws_region" "this" {
  provider = aws.region
}



resource "aws_vpc" "vpc" {
  cidr_block           = var.vpc-cidr
  enable_dns_hostnames = true
}

resource "aws_subnet" "subnet-a" {
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = var.subnet-cidr-a
  availability_zone = "${data.aws_region.this.name}a"
  depends_on        = [aws_vpc.vpc]
}

resource "aws_subnet" "subnet-b" {
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = var.subnet-cidr-b
  availability_zone = "${data.aws_region.this.name}b"
  depends_on        = [aws_vpc.vpc]

}

resource "aws_subnet" "subnet-c" {
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = var.subnet-cidr-c
  availability_zone = "${data.aws_region.this.name}c"
  depends_on        = [aws_vpc.vpc]
}

resource "aws_subnet" "subnet-d" {
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = var.subnet-cidr-d
  availability_zone = "${data.aws_region.this.name}c"
  depends_on        = [aws_vpc.vpc]
}

resource "aws_route_table" "subnet-route-table" {
  vpc_id = aws_vpc.vpc.id
}

resource "aws_route_table" "subnet-route-table-public" {
  vpc_id = aws_vpc.vpc.id
}
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id
}

resource "aws_route" "subnet-route" {
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.this.id
  route_table_id         = aws_route_table.subnet-route-table.id
}

resource "aws_route" "subnet-route-ublic" {
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw.id
  route_table_id         = aws_route_table.subnet-route-table.id
}
resource "aws_route_table_association" "subnet-a-route-table-association" {
  subnet_id      = aws_subnet.subnet-a.id
  route_table_id = aws_route_table.subnet-route-table.id
}

resource "aws_route_table_association" "subnet-b-route-table-association" {
  subnet_id      = aws_subnet.subnet-b.id
  route_table_id = aws_route_table.subnet-route-table.id
}

resource "aws_route_table_association" "subnet-c-route-table-association" {
  subnet_id      = aws_subnet.subnet-c.id
  route_table_id = aws_route_table.subnet-route-table.id
}

# nat gw
resource "aws_eip" "this" {
  domain = "vpc"
}

resource "aws_nat_gateway" "this" {
  allocation_id = aws_eip.this.id
  subnet_id     = aws_subnet.subnet-a.id
  depends_on    = [aws_internet_gateway.igw]
}

resource "aws_route_table_association" "subnet-d-route-table-association" {
  subnet_id      = aws_subnet.subnet-d.id
  route_table_id = aws_route_table.subnet-route-table-public.id
}

