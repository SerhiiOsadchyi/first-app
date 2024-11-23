# Create subnet
resource "aws_subnet" "myapp-subnet" {
    vpc_id = var.vpc_id
    cidr_block = var.subnet_cidr_block
    availability_zone = var.avail_zone

    tags = {
        Name = "${var.env_prefix}-subnet"
    }
}

# Create route table for the subnet
resource "aws_route_table" "myapp-rtb" {
    vpc_id = var.vpc_id

    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.myapp-igw.id
    }
    
    tags = {
        Name = "${var.env_prefix}-rtb"
    }
}

resource "aws_internet_gateway" "myapp-igw" {
    vpc_id = var.vpc_id

    tags = {
        Name = "${var.env_prefix}-igw"
    }
}

resource "aws_route_table_association" "a-rtb-subnet" {
    subnet_id = aws_subnet.myapp-subnet.id
    route_table_id = aws_route_table.myapp-rtb.id
}