module "rds" {
  source               = "./rds"
  name                 = "orbidi-assesment-${var.environment}"
  database_name        = "orbidi"
  username             = "orbidimaster"
  vpc_id               = module.vpc.vpc_id
  db_subnet_group_name = module.vpc.db_subnet_group_name
  security_group_ids   = []
}