terraform {
  required_version = ">= 1.6"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }

  # Partial configuration: bucket, key and lock table are passed at init time
  #   terraform init -backend-config=backend.hcl
  # See backend.hcl.example.
  backend "s3" {}
}

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Project   = "aws-terraform-react-js"
      ManagedBy = "terraform"
    }
  }
}
