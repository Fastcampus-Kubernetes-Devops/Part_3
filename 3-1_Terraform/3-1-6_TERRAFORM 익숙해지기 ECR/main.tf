
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

locals {
  demo_repositories = [
    "demo-0",
    "demo-a",
    "demo-b",
    "demo-c",
    "demo-d"
  ]
}

resource "aws_ecr_repository" "demo_repository" {
  for_each             = toset(local.demo_repositories)
  name                 = each.key
  image_tag_mutability = "IMMUTABLE"

  encryption_configuration {
    encryption_type = "KMS"
  }

  image_scanning_configuration {
    scan_on_push = true
  }
}

resource "aws_ecr_lifecycle_policy" "demo_lifecycle_policy" {
  for_each   = aws_ecr_repository.demo_repository
  repository = each.value.name
  policy     = <<EOF
{
  "rules": [
    {
      "rulePriority": 1,
      "description": "demo lifecycle",
      "selection": {
        "tagStatus": "any",
        "countType": "imageCountMoreThan",
        "countNumber": 3
      },
      "action": {
        "type": "expire"
      }
    }
  ]
}
EOF
}
