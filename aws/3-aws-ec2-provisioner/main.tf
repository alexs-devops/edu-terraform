provider "aws" {}

variable "vpc_cidr_blocks" {}
variable "subnet_cidr_blocks" {}
variable "avail_zone" {}
variable "env_prefix" {}
variable "allowed_ip" {}
variable "instance_type" {}
#variable "public_key_location" {}
variable "public_key" {}
variable "private_key" {}

## Custom VPC
resource "aws_vpc" "app-vpc" {
  cidr_block = var.vpc_cidr_blocks
  tags = {
    Name: "${var.env_prefix}-vpc"
  }
}

## Subnet assigned to VPC
resource "aws_subnet" "app-subnet-1" {
  vpc_id = aws_vpc.app-vpc.id
  cidr_block = var.subnet_cidr_blocks
  availability_zone = var.avail_zone
  tags = {
    Name: "${var.env_prefix}-subnet-1"
  }
}

## To use default rtb:
resource "aws_default_route_table" "main-rtb" {
  default_route_table_id = aws_vpc.app-vpc.default_route_table_id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.app-igw.id
  }
  tags = {
    Name: "${var.env_prefix}-main-rtb"
  }
}

## Custom gateway
resource "aws_internet_gateway" "app-igw" {
  vpc_id = aws_vpc.app-vpc.id
  tags = {
    Name: "${var.env_prefix}-igw"
  }
}

## Modify default security group to open ports
resource "aws_default_security_group" "app-default-sg" {
  vpc_id = aws_vpc.app-vpc.id

  ingress {
    from_port = 22
    to_port = 22
    protocol = "TCP"
    cidr_blocks = [var.allowed_ip]
  }

  ingress {
    from_port = 8080
    to_port = 8080
    protocol = "TCP"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    prefix_list_ids = []
  }

  tags = {
    Name: "${var.env_prefix}-sg"
  }
}

data "aws_ami" "latest-aws-linux-image" {
  most_recent = true
  owners = ["amazon"]
  filter {
    name = "name"
    values = [ "al2023-ami-2023.5.2024*.0-kernel-6.1-x86_64" ]
  }
  filter {
    name = "virtualization-type"
    values = [ "hvm" ]
  }
}

## Check selected iamge id
output "aws_ami_id" {
  value = data.aws_ami.latest-aws-linux-image.id
}

## EC2 public IP output
## use terraform state show aws_instance.myapp-server
output "ec2_public_ip" {
  value = aws_instance.app-server.public_ip
}

# Add your public IP to creted EC2 instance
resource "aws_key_pair" "custom-ssh-key" {
  key_name = "custom-ssh-key"
  #public_key = file("var.public_key_location")
  public_key = var.public_key
}

resource "aws_instance" "app-server" {
  # mandatory
  #ami = "ami-00060fac2f8c42d30"
  ami = data.aws_ami.latest-aws-linux-image.id
  instance_type = var.instance_type

  #optional
  subnet_id = aws_subnet.app-subnet-1.id
  security_groups = [ aws_default_security_group.app-default-sg.id ]
  availability_zone = var.avail_zone

  associate_public_ip_address = true
  key_name = aws_key_pair.custom-ssh-key.key_name

  #user_data = file("entry-script.sh")
  
  ## Use provisioner
  connection {
    type = "ssh"
    host = self.public_ip
    user = "ec2-user"
    private_key = file(var.private_key)
  }

  # provisioner can have connect block inside
  provisioner "file" {
    source = "entry-script.sh"
    destination = "/home/ec2-user/entry-script.sh"
  }

  provisioner "remote-exec" {
    inline = [ "/home/ec2-user/entry-script.sh" ]
  }

  /*   ## OR  
  provisioner "remote-exec" {
    script = "entry-script.sh"
  }
 */
  /* ## if you need to execute local smth   
  provisioner "local-exec" {
    command = "echo ${self.public_ip} > output.txt"
  } */

  ## to avoid instance recreation
  user_data_replace_on_change = true

  tags = {
    Name: "${var.env_prefix}-server"
  }
}