provider "aws" {
  region = "eu-central-1"
}

variable "cidr_blocks" {
  description = "CIDR blocks for VPC and Subnets"
  #default = "10.0.10.0/24"
  type = list(object({
    cidr_block = string
    name = string
  }))
}

/* variable "environment" {
  description = "Environment"
  type = string
} */

resource "aws_vpc" "development-vpc" {
  cidr_block = var.cidr_blocks[0].cidr_block
  tags = {
    Name: var.cidr_blocks[0].name
  }
}

resource "aws_subnet" "dev-subnet-1" {
  vpc_id = aws_vpc.development-vpc.id
  cidr_block = var.cidr_blocks[1].cidr_block
  availability_zone = "eu-central-1a"
  tags = {
    Name: var.cidr_blocks[1].name
  }
}

/* data "aws_vpc" "existing_vpc" {
  default = true
}

resource "aws_subnet" "dev-subnet-2-default" {
  vpc_id = aws_vpc.existing_vpc.id
  cidr_block = "10.0.10.0/24"
  availability_zone = "eu-central-1a"
  tags = {
    Name: "dev-subnet-2-default"
  }
} */

output "dev-vpc-id" {
  value = aws_vpc.development-vpc.id
}

output "dev-subnet-id" {
  value = aws_subnet.dev-subnet-1.id
}