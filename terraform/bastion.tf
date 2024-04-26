module "bastion" {
  source    = "./bastion"
  name      = "orbidi-assesment-${var.environment}"
  vpc_id    = module.vpc.vpc_id
  subnet_id = module.vpc.public_subnet_ids[0]
}