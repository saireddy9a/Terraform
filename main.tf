### data call for availability zones
data "aws_availability_zones" "available" {
  state = "available"
}

### VPC Creation
resource "aws_vpc" "Sample-VPC" {
  cidr_block       = "10.0.0.0/16"

  tags = {
    Name = "SampleVPC"
  }
}

### Public Subnet Creation
resource "aws_subnet" "Sample-Public-subnet" {
  vpc_id     = aws_vpc.Sample-VPC.id
  cidr_block = "10.0.1.0/24"
  availability_zone = data.aws_availability_zones.available.names[0]

  tags = {
    Name = "Sample-Public"
  }
}

resource "aws_subnet" "Sample-Public-subnet1" {
  vpc_id     = aws_vpc.Sample-VPC.id
  cidr_block = "10.0.3.0/24"
  availability_zone = data.aws_availability_zones.available.names[1]

  tags = {
    Name = "Sample-Public1"
  }
}

resource "aws_subnet" "Sample-Public-subnet2" {
  vpc_id     = aws_vpc.Sample-VPC.id
  cidr_block = "10.0.4.0/24"
  availability_zone = data.aws_availability_zones.available.names[2]

  tags = {
    Name = "Sample-Public2"
  }
}

### Private Subnet Creation
resource "aws_subnet" "Sample-private-subnet" {
  vpc_id     = aws_vpc.Sample-VPC.id
  cidr_block = "10.0.2.0/24"
  availability_zone = data.aws_availability_zones.available.names[0]

  tags = {
    Name = "Sample-Private"
  }
}

### Internet Gateway Creation
resource "aws_internet_gateway" "Sample-IGW" {
  vpc_id = aws_vpc.Sample-VPC.id

  tags = {
    Name = "Sample-main"
  }
}

### Route Table Creation
resource "aws_route_table" "Sample-Public-RT" {
  vpc_id = "${aws_vpc.Sample-VPC.id}"
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.Sample-IGW.id}"
  }
  tags = {
    Name        = "Sample-PublicRT"
  }
}

### Route Table association
resource "aws_route_table_association" "Sample-Public-RT-association" {
  route_table_id = "${aws_route_table.Sample-Public-RT.id}"
  subnet_id      = "${aws_subnet.Sample-Public-subnet.id}"
}

resource "aws_route_table_association" "Sample-Public-RT-association-subnet1" {
  route_table_id = "${aws_route_table.Sample-Public-RT.id}"
  subnet_id      = "${aws_subnet.Sample-Public-subnet1.id}"
}

resource "aws_route_table_association" "Sample-Public-RT-association-subnet2" {
  route_table_id = "${aws_route_table.Sample-Public-RT.id}"
  subnet_id      = "${aws_subnet.Sample-Public-subnet2.id}"
}

### Elastic IP
resource "aws_eip" "Sample-Nat-Gateway-EIP" {
  depends_on = [
    aws_route_table_association.Sample-Public-RT-association
  ]
  vpc = true
}

### NAT Gateway
resource "aws_nat_gateway" "Sample-NAT_GATEWAY" {
  depends_on = [
    aws_eip.Sample-Nat-Gateway-EIP
  ]
  allocation_id = aws_eip.Sample-Nat-Gateway-EIP.id
  subnet_id = aws_subnet.Sample-Public-subnet.id
  tags = {
    Name = "Sample-Nat-Gateway_Project"
  }
}

resource "aws_route_table" "Sample-NAT-Gateway-RT" {
  depends_on = [
    aws_nat_gateway.Sample-NAT_GATEWAY
  ]
  vpc_id = aws_vpc.Sample-VPC.id
  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.Sample-NAT_GATEWAY.id
  }
  tags = {
    Name = "Sample-Route Table for NAT Gateway"
  }

}

resource "aws_route_table_association" "Sample-Nat-Gateway-RT-Association" {
  depends_on = [
    aws_route_table.Sample-NAT-Gateway-RT
  ]
  subnet_id      = aws_subnet.Sample-private-subnet.id
  route_table_id = aws_route_table.Sample-NAT-Gateway-RT.id
}

### Security Group Creation
resource "aws_security_group" "Sample-Sg" {
  name        = "Sample-SG"
  description = "Allow TLS inbound traffic"
  vpc_id      = aws_vpc.Sample-VPC.id

  ingress {
    description      = "TLS from VPC"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
     # need to provide the IP address 55.55.55.55
    cidr_blocks      = ["55.55.55.55/32"]
  }
  ingress {
    description      = "TLS from VPC"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
     # need to provide the IP address 55.55.55.55
    cidr_blocks      = ["55.55.55.55/32"]
  }
  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "Sample-Sg"
  }
}

### EC2 Creation
resource "aws_instance" "Web-Server" {
  ami           = "ami-042e8287309f5df03"
  instance_type = "t2.micro"
  subnet_id      = "${aws_subnet.Sample-private-subnet.id}"
  vlc_security_group_ids = [aws_security_group.Sample-Sg.id]
  
  user_data = <<-EOF
    #!/bin/bash
    apt-get update -y
    apt-get upgrade -y
    apt-get install apache2 -y
    service apache2 enable
    service apache2 start
    echo "Hello , I am $(hostname -f) hosted by Sai in terraform Created by " > /var/www/html/index.html
  EOF
  key_name = "web"
  private_ip = "10.0.2.101"
  tags = {
    Name = "Apache"
  }
}
resource "aws_security_group" "Sample-LB-Sg1" {
  name        = "Sample-LB-SG1"
  description = "Allow TLS inbound traffic"
  vpc_id      = aws_vpc.Sample-VPC.id


  ingress {
    description      = "TLS from VPC"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
     # need to provide your IP address to access
    cidr_blocks      = ["55.55.55.55/32"]
  }
  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "Sample-Sg"
  }
}

resource "aws_lb" "Sample-load-balancer" {
  name               = "Sample-load-balancer"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.Sample-LB-Sg1.id]
  subnets            = [aws_subnet.Sample-Public-subnet.id,aws_subnet.Sample-Public-subnet1.id,aws_subnet.Sample-Public-subnet2.id]
  enable_deletion_protection = false
  tags = {
    Environment = "Test"
  }
}

resource "aws_lb_target_group" "Sample-Target-Group" {
  name     = "Sample-Target-Group"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.Sample-VPC.id
}

resource "aws_lb_target_group_attachment" "Sample-lb-targetgroup-association" {
  target_group_arn = aws_lb_target_group.Sample-Target-Group.arn
  target_id        = aws_instance.Web-Server.id
  port             = 80
}

resource "aws_lb_listener" "Sample-LB-Listner" {
  load_balancer_arn = aws_lb.Sample-load-balancer.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.Sample-Target-Group.arn
  }
}

