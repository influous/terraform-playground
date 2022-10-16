module "infx-subnet" {
  source = "./modules/subnet"
  default_route_table_id = aws_vpc.infx-vpc.default_route_table_id
  vpc_id = aws_vpc.infx-vpc.id
  subnet_cidr_block = var.subnet_cidr_block
  env_prefix = var.env_prefix
  avail_zone = var.avail_zone
}

module "infx-server" {
  source = "./modules/webserver"
  vpc_id = aws_vpc.infx-vpc.id
  allowed_ips = var.allowed_ips
  env_prefix = var.env_prefix
  image_name = var.image_name
  public_key_location = var.public_key_location
  instance_type = var.instance_type
  subnet_id = module.infx-subnet.subnet.id
  avail_zone = var.avail_zone
}

resource "aws_vpc" "infx-vpc" {
  cidr_block = var.vpc_cidr_block
  tags = {
    Name : "${var.env_prefix}-vpc"
  }
}