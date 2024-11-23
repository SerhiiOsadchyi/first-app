# Configure the AWS Provider
provider "aws" {
    region = "eu-west-3"
}

# Create a VPC
resource "aws_vpc" "myapp-vpc" {
    cidr_block = var.vpc_cidr_block

    tags = {
        Name = "${var.env_prefix}-vpc"
    }
}

module "myapp-subnet" {
    source = "./modules/subnet"
    avail_zone = var.avail_zone
    subnet_cidr_block = var.subnet_cidr_block
    env_prefix = var.env_prefix
    vpc_id = aws_vpc.myapp-vpc.id
}

module "myapp-server" {
    source = "./modules/webserver"
    avail_zone = var.avail_zone
    env_prefix = var.env_prefix
    subnet_id = module.myapp-subnet.subnet.id
    my_ips = var.my_ips
    instance_type = var.instance_type
    publc_key_location = var.publc_key_location
    image_name = var.image_name
    vpc_id = aws_vpc.myapp-vpc.id
}