
terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.26.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.24.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = ">= 2.12.1"
    }
  }
}
provider "aws" {}
module "demo_vpc" {
  source   = "./modules/vpc"
  vpc_name = "dev-vpc"
  vpc_cidr = "10.0.0.0/16"
}
module "demo_eks" {
  source          = "./modules/eks"
  cluster_name    = "dev-cluster"
  cluster_version = "1.28"
  vpc_id          = module.demo_vpc.vpc_id
  private_subnets = module.demo_vpc.private_subnets
}
module "demo_irsa" {
  source            = "./modules/irsa"
  oidc_provider     = module.demo_eks.oidc_provider
  oidc_provider_arn = module.demo_eks.oidc_provider_arn
}
