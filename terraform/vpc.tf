module "vpc" {
  source     = "./vpc"
  name       = "orbidi-assesment-${var.environment}"
  cidr_block = "10.232.0.0/16"
}