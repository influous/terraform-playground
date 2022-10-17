terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

provider "aws" {
  region = var.region
}

resource "aws_vpc" "infx-vpc" {
  cidr_block = var.vpc_cidr_block
  tags = {
    Name : "${var.env_prefix}-vpc"
  }
}

resource "aws_subnet" "infx-subnet-1" {
  vpc_id            = aws_vpc.infx-vpc.id
  cidr_block        = var.subnet_cidr_block
  availability_zone = var.avail_zone
  tags = {
    Name : "${var.env_prefix}-subnet-1"
  }
}

resource "aws_internet_gateway" "infx-igw" {
  vpc_id = aws_vpc.infx-vpc.id
  tags = {
    Name : "${var.env_prefix}-igw"
  }
}

data "aws_ami" "latest-amz-image" {
  most_recent = true
  owners      = ["amazon"]
  filter {
    name   = "name"
    values = ["amzn2-ami-kernel-5.10-hvm-*-x86_64-gp2"]
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

resource "aws_instance" "infx-server" {
  ami           = data.aws_ami.latest-amz-image.id
  instance_type = var.instance_type

  subnet_id              = aws_subnet.infx-subnet-1.id
  vpc_security_group_ids = [aws_security_group.infx-sg.id]
  availability_zone      = var.avail_zone

  associate_public_ip_address = true
  key_name                    = "devops-maven"

  user_data = file("entry-script.sh")

  tags = {
    Name = "${var.env_prefix}-server"
  }

}

resource "aws_route_table" "infx-route-table" {
  vpc_id = aws_vpc.infx-vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.infx-igw.id
  }
  tags = {
    Name : "${var.env_prefix}-rtb"
  }
}

resource "aws_route_table_association" "a-rtb-subnet" {
  subnet_id      = aws_subnet.infx-subnet-1.id
  route_table_id = aws_route_table.infx-route-table.id
}

resource "aws_security_group" "infx-sg" {
  name   = "infx-sg"
  vpc_id = aws_vpc.infx-vpc.id

  ingress { # can also be a range, from_port=0 to_port=200
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.allowed_ips]
  }

  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress { # outgoing requests on any port, any protocol
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name : "${var.env_prefix}-sg"
  }
}