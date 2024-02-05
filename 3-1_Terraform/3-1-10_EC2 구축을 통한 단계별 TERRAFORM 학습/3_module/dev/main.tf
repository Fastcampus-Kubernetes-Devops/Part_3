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

module "demo_instance" {
  source    = "../modules"
  prefix    = "dev"
  vpc_id    = module.demo_vpc.vpc_id
  subnet_id = module.demo_vpc.public_subnets[0]
}

output "instance" {
  value     = module.demo_instance
  sensitive = true
}
