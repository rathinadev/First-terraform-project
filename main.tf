provider "aws" {
    region = "us-east-1"  
}

resource "aws_key_pair" "demo" {
    key_name = var.key_pair
    public_key = file("~/.ssh/id_rsa.pub")
}

resource "aws_vpc" "demo-vpc" {
    cidr_block = var.cidr-vpc 
}



resource "aws_subnet" "demo-subnet" {
    vpc_id = aws_vpc.demo-vpc.id
    cidr_block = var.cidr-subnet
    map_public_ip_on_launch = true
    availability_zone = "us-east-1a"
}

resource "aws_internet_gateway" "demo-gateway" {
    vpc_id = aws_vpc.demo-vpc.id
}

resource "aws_route_table" "demo-route-table" {
    vpc_id = aws_vpc.demo-vpc.id

    route {
        cidr_block= var.cidr
        gateway_id = aws_internet_gateway.demo-gateway.id
    }
  
}
resource "aws_route_table_association" "association" {
    subnet_id = aws_subnet.demo-subnet.id
    route_table_id = aws_route_table.demo-route-table.id
  
}
resource "aws_security_group" "demo-security-group" {
    name = "demo-security-group"
    description = "Allows inbound traffic."
    vpc_id = aws_vpc.demo-vpc.id
  
    ingress {
        description = "To allow HTTP from VPC"
        from_port = 80
        to_port = 80 
        protocol = "tcp"
        cidr_blocks = [var.cidr]
    }

    ingress {
        description = "To allow ssh inside the group."
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = [var.cidr]

    }
    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = [var.cidr]
    }
     tags = {
        Name = "demo"
    }
}

resource "aws_instance" "demo-instance" {
    ami = var.ami-value
    instance_type = "t2.micro"
    key_name = aws_key_pair.demo.key_name  
    vpc_security_group_ids = [aws_security_group.demo-security-group.id]
    subnet_id = aws_subnet.demo-subnet.id
    depends_on = [aws_route_table_association.association]

    connection {
      type = "ssh"
      user = "ubuntu"
      private_key = file("~/.ssh/id_rsa")
      host = self.public_ip
    }
   
   # Using a File provisioner to copy a file from local to remote instance
   provisioner "file" {
    source      = "app.py"  # Replace with the path to your local file
    destination = "/home/ubuntu/app.py"  # Replace with the path on the remote instance
  }

   provisioner "remote-exec" {
    inline = [ 
        "echo 'HElllo from terraform'",
        "sudo apt update -y",
        "sudo apt-get install -y python3-pip",  # Example package installation
        "cd /home/ubuntu",
        "sudo pip3 install flask",
        "sudo python3 app.py ",

     ]
     
   }


}