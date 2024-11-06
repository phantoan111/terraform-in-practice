provider "aws" {
  region = "ap-southeast-1"
}

data "aws_ami" "ami_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-*"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

resource "aws_instance" "hello" {
  count         = 5
  ami           = data.aws_ami.ami_linux.id
  instance_type = var.instance_type
}



output "EC2" {
  value = { for i,v in aws_instance.hello : format("public_ip%d",i+1) => v.public_ip }
}
