################################################
#
# Module to create subnet/gateway/rtb(default)
#
#################################################

## Subnet assign to VPC
resource "aws_subnet" "app-subnet-1" {
  vpc_id = var.vpc_id
  cidr_block = var.subnet_cidr_block
  availability_zone = var.avail_zone
  tags = {
    Name: "${var.env_prefix}-subnet-1"
  }
}

## Custom gateway
resource "aws_internet_gateway" "app-igw" {
  vpc_id = var.vpc_id
  tags = {
    Name: "${var.env_prefix}-igw"
  }
}

## Update Default RTB
resource "aws_default_route_table" "main-rtb" {
  default_route_table_id = var.default_route_table_id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.app-igw.id
  }
  tags = {
    Name: "${var.env_prefix}-main-rtb"
  }
}
