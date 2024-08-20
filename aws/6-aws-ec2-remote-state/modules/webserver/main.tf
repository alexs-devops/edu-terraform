###########################################################
#
# Module to create EC2 instance
#
###########################################################

## Modify default security group to open ports
resource "aws_security_group" "app-sg" {
  vpc_id = var.vpc_id
  name = "app-sg"

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
    values = [ "${var.image_name}" ] # need ${} to parse var with asterisk * symbol
  }
  filter {
    name = "virtualization-type"
    values = [ "hvm" ]
  }
}

# Add your public IP to creted EC2 instance
resource "aws_key_pair" "custom-ssh-key" {
  key_name = "custom-ssh-key"
  public_key = file("${path.module}/${var.public_key}")
}

resource "aws_instance" "app-server" {
  # mandatory
  # ami = "ami-00060fac2f8c42d30"
  ami = data.aws_ami.latest-aws-linux-image.id
  instance_type = var.instance_type

  # optional
  subnet_id = var.subnet_id
  security_groups = [ aws_security_group.app-sg.id ]
  availability_zone = var.avail_zone

  associate_public_ip_address = true
  key_name = aws_key_pair.custom-ssh-key.key_name

  user_data = file("${path.module}/entry-script.sh")
  user_data_replace_on_change = true # to avoid instance recreation

  tags = {
    Name: "${var.env_prefix}-server"
  }
}