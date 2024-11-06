# Configure the AWS Provider
provider "aws" {
    region = "eu-west-3"
}

variable "cidr_blocks" {
    description = "names and cidr blocks vpc and subnets"
    type = list(object({
        cidr_block = string,
        name = string
    }))
}

# Create a VPC
resource "aws_vpc" "dev-vpc" {
    cidr_block = var.cidr_blocks[0].cidr_block
    tags = {
        Name: var.cidr_blocks[0].name
    }
}

# Create subnet
resource "aws_subnet" "dev-subnet-1" {
    vpc_id = aws_vpc.dev-vpc.id
    cidr_block = var.cidr_blocks[1].cidr_block
    availability_zone = "eu-west-3a"
    tags = {
        Name: var.cidr_blocks[1].name
    }
}

# Create reference to default vpc
data "aws_vpc" "existing_default_vpc" {
    default = true
}

# Create subnet in default vpc
resource "aws_subnet" "dev-subnet-2" {
    vpc_id = data.aws_vpc.existing_default_vpc.id
    cidr_block = var.cidr_blocks[2].cidr_block
    availability_zone = "eu-west-3a"
    tags = {
        Name: var.cidr_blocks[2].name
    }
}

output "dev_vpc_id" {
    value = aws_vpc.dev-vpc.id
}

output "dev-subnet-1_id" {
    value = aws_subnet.dev-subnet-1.id
}

output "dev-subnet-2_id" {
    value = aws_subnet.dev-subnet-2.id
}

// Old variants for train

# variable "vpc_cidr_block" {
#     description = "vpc cidr block"
# }

# variable "dev_subnet_1_cidr_block" {
#     description = "devevelopmet subnet 1 cidr block"
# }

# variable "dev_subnet_2_cidr_block" {
#     description = "devevelopmet subnet 2 cidr block"
# }