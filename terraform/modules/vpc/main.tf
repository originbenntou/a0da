resource "aws_vpc" "main" {
  cidr_block = var.vpc_cidr
  enable_dns_hostnames = true
  tags = {
    Name = "test"
  }
}

resource "aws_subnet" "subnet1" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.subnet_cidr1
  availability_zone = var.az_a
}

resource "aws_subnet" "subnet2" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.subnet_cidr2
  availability_zone = var.az_c
}

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id
}

resource "aws_route_table" "main" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }
}

resource "aws_route_table_association" "subnet1" {
  subnet_id      = aws_subnet.subnet1.id
  route_table_id = aws_route_table.main.id
}

resource "aws_route_table_association" "subnet2" {
  subnet_id      = aws_subnet.subnet2.id
  route_table_id = aws_route_table.main.id
}
