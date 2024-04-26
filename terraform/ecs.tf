module "ecs" {
  source                = "./ecs"
  name                  = "orbidi-${var.environment}"
  environment_variables = []
  environment_secrets   = []
  containerPort         = 8000
  hostPort              = 8000
  image                 = ""
  alb_subnets           = module.vpc.public_subnet_ids
  listener_certificate  = ""
  vpc_id                = module.vpc.vpc_id
}