## EC2 public IP output
# use terraform state show aws_instance.myapp-server
output "ec2_instance" {
  value = aws_instance.app-server
}