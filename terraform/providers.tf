provider "aws" {
  assume_role {
    role_arn = "arn:aws:iam::yourid:role/devops-role"
  }
}