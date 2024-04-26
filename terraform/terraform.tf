terraform {
  required_version = "~> 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
  backend "s3" {
    region         = "us-east-1"
    bucket         = "orbidi-assesment-terraform-state"
    key            = "terraform.tfstate"
    dynamodb_table = "orbidi-assesment-terraform-lock"
  }
}