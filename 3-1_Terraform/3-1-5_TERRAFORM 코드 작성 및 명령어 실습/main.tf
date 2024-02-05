terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.26.0"
    }
  }
}
provider "aws" {}
resource "aws_vpc" "demo_vpc" {
  cidr_block = "10.0.0.0/16"
}
output "vpc_id" {
  value = aws_vpc.demo_vpc.id
}
output "vpc_cidr" {
  value = aws_vpc.demo_vpc.cidr_block
}

# module "vpc" {
#   source = "terraform-aws-modules/vpc/aws"
#   name   = "my-vpc"
#   cidr   = "10.0.0.0/16"
# }
resource "aws_security_group" "demo_sg_0" {
  name        = "demo-sg"
  vpc_id      = aws_vpc.demo_vpc.id
  description = "Security Group for Demo"
  ingress {
    from_port   = 22
    to_port     = 22
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
# output "sg_name" {
#   value = aws_security_group.demo_sg.name
# }
# output "sg_id" {
#   value = aws_security_group.demo_sg.id
# }
