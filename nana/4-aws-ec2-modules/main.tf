provider "aws" {}

## Custom VPC
resource "aws_vpc" "app-vpc" {
  cidr_block = var.vpc_cidr_block
  tags = {
    Name: "${var.env_prefix}-vpc"
  }
}

## Crearte cutom subnet/gateway/rtb(default)
module "app-subnet" {
  subnet_cidr_block = var.subnet_cidr_block
  avail_zone = var.avail_zone
  env_prefix = var.env_prefix
  vpc_id = aws_vpc.app-vpc.id
  default_route_table_id = aws_vpc.app-vpc.default_route_table_id
  #source = "C:/Github/edu-terraform/nana/4-aws-ec2-modules/modules/subnet"
  source = "./modules/subnet"
}

## Create EC2 with SSH key pair; define SG
module "app-server" {
  instance_type = var.instance_type
  avail_zone = var.avail_zone
  env_prefix = var.env_prefix
  vpc_id = aws_vpc.app-vpc.id
  image_name = var.image_name
  subnet_id = module.app-subnet.subnet.id
  allowed_ip = var.allowed_ip
  public_key = var.public_key
  source = "./modules/webserver"
}