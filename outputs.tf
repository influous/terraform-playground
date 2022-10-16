output "aws_ami_id" {
  value = module.infx-server.ami.id
}

output "aws_ami_ip" {
  value = module.infx-server.instance.public_ip
}