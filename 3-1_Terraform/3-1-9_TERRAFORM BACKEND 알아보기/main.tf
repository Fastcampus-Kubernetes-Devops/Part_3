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
resource "aws_s3_bucket" "demo_bucket" {
  bucket_prefix = "demo-terraform-state"
  force_destroy = true
}
resource "aws_s3_bucket_versioning" "demo_versioning" {
  bucket = aws_s3_bucket.demo_bucket.id
  versioning_configuration {
    status = "Enabled"
  }
}
resource "aws_dynamodb_table" "demo_table" {
  name         = "demo-terraform-lock"
  hash_key     = "LockID"
  billing_mode = "PAY_PER_REQUEST"
  attribute {
    name = "LockID"
    type = "S"
  }
}
