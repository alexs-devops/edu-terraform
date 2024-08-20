variable "custom_ports" {
  description = "Custom ports to open on the security group."
  type        = map(any)

  default = {
    80   = ["0.0.0.0/0"]
    8081 = ["10.0.0.0/16"]
  }
}

resource "aws_security_group" "web" {
  name   = "allow-web-access"
  vpc_id = aws_vpc.main.id

  dynamic ingress {
    for_each = var.custom_ports

    content {
     from_port   = ingress.key
     to_port     = ingress.key
     protocol    = "tcp"
     cidr_blocks = ingress.value 
    }
  }
}
