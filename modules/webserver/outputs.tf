output "ami" {
    value = data.aws_ami.latest-amz-image
}

output "instance" {
    value = aws_instance.infx-server
}