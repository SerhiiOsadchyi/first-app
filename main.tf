# Configure the AWS Provider
provider "aws" {
    region = "eu-west-3"
}

variable vpc_cidr_block {}
variable subnet_cidr_block {}
variable avail_zone {}
variable env_prefix {}
variable my_ips {}
variable instance_type {}
variable publc_key_location {}

# Create a VPC
resource "aws_vpc" "myapp-vpc" {
    cidr_block = var.vpc_cidr_block

    tags = {
        Name = "${var.env_prefix}-vpc"
    }
}

# Create subnet
resource "aws_subnet" "myapp-subnet" {
    vpc_id = aws_vpc.myapp-vpc.id
    cidr_block = var.subnet_cidr_block
    availability_zone = var.avail_zone

    tags = {
        Name = "${var.env_prefix}-subnet"
    }
}

# Create route table for the subnet
resource "aws_route_table" "myapp-rtb" {
    vpc_id = aws_vpc.myapp-vpc.id

    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.myapp-igw.id
    }
    
    tags = {
        Name = "${var.env_prefix}-rtb"
    }
}

resource "aws_internet_gateway" "myapp-igw" {
    vpc_id = aws_vpc.myapp-vpc.id

    tags = {
        Name = "${var.env_prefix}-igw"
    }
}

resource "aws_route_table_association" "a-rtb-subnet" {
    subnet_id = aws_subnet.myapp-subnet.id
    route_table_id = aws_route_table.myapp-rtb.id
}

# Create security group for the vpc
resource "aws_security_group" "myapp-sg" {
    name = "myapp-sg"
    vpc_id = aws_vpc.myapp-vpc.id

    ingress {
        cidr_blocks = [var.my_ips]
        from_port = 22        
        to_port = 22
        protocol = "tcp"
    }

    ingress {
        cidr_blocks = ["0.0.0.0/0"]
        from_port = 8080
        to_port = 8080
        protocol = "tcp"
    }

    egress {
        cidr_blocks = ["0.0.0.0/0"]
        from_port = 0
        to_port = 0
        protocol = "-1" # semantically equivalent to all ports
    }
}

# Get the most recent AMI for the instance
data "aws_ami" "latest-amazon-linux-image" {
    most_recent      = true
    owners = ["amazon"]

    filter {
        name = "name"
        values = ["amzn2-ami-*-x86_64-gp2"]
    }

    filter {
        name = "virtualization-type"
        values = ["hvm"]
    }
}

# Get public key
resource "aws_key_pair" "ssh-key" {
    key_name   = "server-key"
    public_key = file(var.publc_key_location)
}


# Create instance 
resource "aws_instance" "myapp-server" {
    ami = data.aws_ami.latest-amazon-linux-image.id
    instance_type = var.instance_type

    subnet_id = aws_subnet.myapp-subnet.id
    vpc_security_group_ids = [aws_security_group.myapp-sg.id]
    availability_zone = var.avail_zone
    associate_public_ip_address = true

    key_name = aws_key_pair.ssh-key.key_name

    user_data = file("entry-script.sh")

    tags = {
        Name = "${var.env_prefix}-server"
    }
}

output "myapp_vpc_id" {
    value = aws_vpc.myapp-vpc.id
}

output "myapp-subnet-1_id" {
    value = aws_subnet.myapp-subnet.id
}

output "instance_public_ip" {
    description = "Public IP address of the EC2 instance"
    value = aws_instance.myapp-server.public_ip
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

# # Create reference to default vpc
# data "aws_vpc" "existing_default_vpc" {
#     default = true
# }

# # Create subnet in default vpc
# resource "aws_subnet" "myapp-subnet-2" {
#     vpc_id = data.aws_vpc.existing_default_vpc.id
#     cidr_block = var.cidr_blocks[2].cidr_block
#     availability_zone = "eu-west-3a"
#     tags = {
#         Name: var.cidr_blocks[2].name
#     }
# }

# output "myapp-subnet-2_id" {
#     value = aws_subnet.myapp-subnet-2.id
# }