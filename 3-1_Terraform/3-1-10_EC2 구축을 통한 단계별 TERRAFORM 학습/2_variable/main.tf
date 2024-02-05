terraform {
  required_version = ">=1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.26.0"
    }
  }
}
provider "aws" {}
module "demo_vpc" {
  source = "terraform-aws-modules/vpc/aws"
  name   = "demo-vpc"
  cidr   = "10.0.0.0/16"

  azs            = ["ap-northeast-2a"]
  public_subnets = ["10.0.1.0/24"]

  enable_nat_gateway = false
}
resource "aws_security_group" "demo_sg" {
  name        = var.security_group_name
  description = "demo-sg"
  vpc_id      = module.demo_vpc.vpc_id

  ingress {
    from_port   = var.ingress_port
    to_port     = var.ingress_port
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
module "demo_key_pair" {
  source             = "terraform-aws-modules/key-pair/aws"
  version            = "2.0.2"
  key_name           = var.key_pair_name
  create_private_key = true
}
resource "aws_instance" "demo_instance" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = var.instance_type

  subnet_id                   = module.demo_vpc.public_subnets[0]
  associate_public_ip_address = true

  key_name               = module.demo_key_pair.key_pair_name
  vpc_security_group_ids = [aws_security_group.demo_sg.id]

  root_block_device {
    volume_type = var.root_block_device_volume_type
    volume_size = var.root_block_device_volume_size
  }
}
data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"]

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-*"]
  }
}
output "public_ip" {
  value = aws_instance.demo_instance.public_ip
}
output "private_key" {
  value     = module.demo_key_pair.private_key_pem
  sensitive = true
}
