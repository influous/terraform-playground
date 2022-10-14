terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

provider "aws" {
  region     = "eu-central-1"
}

variable "cidr_blocks" {
  description = "cidr blocks and names for vpc and subnets"
  type        = list(object({ cidr_block = string, name = string }))
}

variable "vpc_cidr_block" {
  description = "vpc cidr block"
  default     = "10.0.0.0/16"
  type        = string # accepted value type, constraint
}

variable "environment" {
  description = "development environment"
}

resource "aws_vpc" "dev-vpc" {
  cidr_block = var.cidr_blocks[0].cidr_block
  tags = {
    Name : var.cidr_blocks[0].name
  }
}

resource "aws_subnet" "dev-subnet-1" {
  vpc_id            = aws_vpc.dev-vpc.id
  cidr_block        = var.cidr_blocks[1].cidr_block
  availability_zone = "eu-central-1a"
  tags = {
    Name : var.cidr_blocks[1].name
  }
}

data "aws_vpc" "existing-vpc" {
  default = true
}

# Add a new subnet alongside the existing default subnets in the region
resource "aws_subnet" "dev-subnet-2" {
  vpc_id            = data.aws_vpc.existing-vpc.id
  cidr_block        = "172.31.48.0/20"
  availability_zone = "eu-central-1a"
  tags = {
    Name : "subnet-1-default"
  }
}

output "dev-vpc-id" {
  value = aws_vpc.dev-vpc.id
}

output "dev-subnet-id" {
  value = aws_subnet.dev-subnet-1.id
}