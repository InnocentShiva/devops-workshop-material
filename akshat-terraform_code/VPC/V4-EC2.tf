provider "aws" {
  region = "ap-south-1"
}

resource "aws_instance" "demo-server" {
    ami = "ami-053b12d3152c0cc71"
    instance_type = "t2.micro"
    subnet_id = aws_subnet.custom-demo-public-subnet-01.id
    key_name = "git-server-key"
    //security_groups = ["${aws_security_group.demo-sg.id}"]
    vpc_security_group_ids = [aws_security_group.demo-sg.id]
    for_each = toset(["jenkins-master", "build-slave", "ansible"])
      tags = {
        Name = "${each.key}"
      }         
}

resource "aws_security_group" "demo-sg" {
  name        = "demo-sg"
  description = "SSH and 8080 Access"
  vpc_id = aws_vpc.custom-demo-vpc.id

  tags = {
    Name = "ssh-port"
  }
}

resource "aws_vpc_security_group_ingress_rule" "demo-sg_ipv4" {
  security_group_id = aws_security_group.demo-sg.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 22
  ip_protocol       = "tcp"
  to_port           = 22
}

resource "aws_vpc_security_group_ingress_rule" "demo-sg_ipv4_8080" {
  security_group_id = aws_security_group.demo-sg.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 8080
  ip_protocol       = "tcp"
  to_port           = 8080
}

resource "aws_vpc_security_group_ingress_rule" "demo-sg_ipv6" {
  security_group_id = aws_security_group.demo-sg.id
  cidr_ipv6         = "::/0"
  from_port         = 22
  ip_protocol       = "tcp"
  to_port           = 22
}

resource "aws_vpc_security_group_egress_rule" "allow_all_traffic_ipv4" {
  security_group_id = aws_security_group.demo-sg.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1" # semantically equivalent to all ports
}

resource "aws_vpc_security_group_egress_rule" "allow_all_traffic_ipv6" {
  security_group_id = aws_security_group.demo-sg.id
  cidr_ipv6         = "::/0"
  ip_protocol       = "-1" # semantically equivalent to all ports
}

resource "aws_vpc" "custom-demo-vpc" {
  cidr_block = "10.1.0.0/16"
  tags = {
    Name = "custom-demo-vpc"
  }
}

resource "aws_subnet" "custom-demo-public-subnet-01" {
  vpc_id = aws_vpc.custom-demo-vpc.id
  cidr_block = "10.1.1.0/24"
  map_public_ip_on_launch = "true"
  availability_zone = "ap-south-1a"
  tags = {
    Name = "custom-demo-public-subnet-01"
  }
}

resource "aws_subnet" "custom-demo-public-subnet-02" {
  vpc_id = aws_vpc.custom-demo-vpc.id
  cidr_block = "10.1.2.0/24"
  map_public_ip_on_launch = "true"
  availability_zone = "ap-south-1b"
  tags = {
    Name = "custom-demo-public-subnet-02"
  }
}

resource "aws_internet_gateway" "custom-demo-igw" {
  vpc_id=aws_vpc.custom-demo-vpc.id
  tags = {
    Name = "custom-demo-igw"
  }
}

resource "aws_route_table" "custom-demo-public-rt" {
  vpc_id = aws_vpc.custom-demo-vpc.id
  route  {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.custom-demo-igw.id
  }
}

resource "aws_route_table_association" "custom-demo-rta-public-subnet-01" {
  subnet_id = aws_subnet.custom-demo-public-subnet-01.id
  route_table_id = aws_route_table.custom-demo-public-rt.id
}

resource "aws_route_table_association" "custom-demo-rta-public-subnet-02" {
  subnet_id = aws_subnet.custom-demo-public-subnet-02.id
  route_table_id = aws_route_table.custom-demo-public-rt.id
}

  module "sgs" {
    source = "../sg_eks"
    vpc_id     =     aws_vpc.custom-demo-vpc.id
 }

  module "eks" {
       source = "../eks"
       vpc_id     =     aws_vpc.custom-demo-vpc.id
       subnet_ids = [aws_subnet.custom-demo-public-subnet-01.id,aws_subnet.custom-demo-public-subnet-02.id]
       sg_ids = module.sgs.security_group_public
 }