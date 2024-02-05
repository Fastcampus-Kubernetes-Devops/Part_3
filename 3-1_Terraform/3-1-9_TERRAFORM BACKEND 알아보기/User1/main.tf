terraform {
  backend "s3" {
    bucket         = "BUCKET_NAME"
    key            = "TERRAFORM_STATE"
    region         = "ap-northeast-2"
    dynamodb_table = "demo-terraform-lock"
  }
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
