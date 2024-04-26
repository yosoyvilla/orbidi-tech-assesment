module "ecr_repository" {
  source              = "./ecr"
  ecr_repository_name = "orbidi-assesment-${var.environment}"
}