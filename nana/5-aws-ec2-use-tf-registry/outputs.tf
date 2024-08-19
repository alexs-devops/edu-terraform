## EC2 public IP output
## use terraform state show aws_instance.myapp-server
output "ec2_public_ip" {
  value = module.app-server.ec2_instance.public_ip
}