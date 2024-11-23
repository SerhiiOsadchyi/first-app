# Create security group for the vpc
resource "aws_security_group" "myapp-sg" {
    name = "myapp-sg"
    vpc_id = var.vpc_id

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
    most_recent = true
    owners = ["amazon"]

    filter {
        name = "name"
        values = [var.image_name]
    }

    filter {
        name = "virtualization-type"
        values = ["hvm"]
    }
}

# Get public key
resource "aws_key_pair" "ssh-key" {
    key_name = "server-key"
    public_key = file(var.publc_key_location)
}

# Create instance 
resource "aws_instance" "myapp-server" {
    ami = data.aws_ami.latest-amazon-linux-image.id
    instance_type = var.instance_type

    subnet_id = var.subnet_id
    vpc_security_group_ids = [aws_security_group.myapp-sg.id]
    availability_zone = var.avail_zone
    associate_public_ip_address = true

    key_name = aws_key_pair.ssh-key.key_name

    user_data = file("entry-script.sh")

    tags = {
        Name = "${var.env_prefix}-server"
    }
}