provider "aws" {
  region = "ap-south-1"
}

resource "aws_instance" "demo-server" {
    ami = "ami-0fd05997b4dff7aac"
    instance_type = "t2.micro"
    subnet_id = "subnet-0b874c0b0a95dd503"
    key_name = "git-server-key"
}