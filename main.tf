# Configure the AWS Provider
provider "aws" {
    region = "eu-west-3"
}

# Create a VPC from Terraform repository
module "vpc" {
    source = "terraform-aws-modules/vpc/aws"

    name = "myapp-vpc"
    cidr = var.vpc_cidr_block

    azs             = [var.avail_zone]
    public_subnets  = [var.subnet_cidr_block]
    public_subnet_tags = {Name = "${var.env_prefix}-subnet"}

    tags = {
        Name = "${var.env_prefix}-vpc"
    }
}

module "myapp-server" {
    source = "./modules/webserver"
    avail_zone = var.avail_zone
    env_prefix = var.env_prefix
    subnet_id = module.vpc.public_subnets[0]
    my_ips = var.my_ips
    instance_type = var.instance_type
    publc_key_location = var.publc_key_location
    image_name = var.image_name
    vpc_id = module.vpc.vpc_id
}