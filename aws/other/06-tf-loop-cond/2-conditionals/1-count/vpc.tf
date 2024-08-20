module "vpcs" {
  source = "../../modules/vpc"

  enable_database_vpc = true
}

/* resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "main"
  } 
}

variable "enable_database_vpc" {
  default = true
}

resource "aws_vpc" "db" {
  count = var.enable_database_vpc ? 1 : 0

  cidr_block = "10.1.0.0/16"

  tags = {
    Name = "db"
  }
} */