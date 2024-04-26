provider "aws" {
  assume_role {
    role_arn = "arn:aws:iam::475829581689:role/devops-role"
  }
}