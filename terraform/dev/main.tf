provider "aws" {
  region = "us-west-2"
}

module "vpc" {
  source = "../modules/vpc"

  vpc_cidr    = "10.32.0.0/16"
  subnet_cidr = "10.32.1.0/24"
}

module "security_groups" {
  source = "../modules/security_groups"
  vpc_id = module.vpc.vpc_id
}

module "alb" {
  source = "../modules/alb"
  app_name         = "nextjs-app-dev"
  vpc_id           = module.vpc.vpc_id
  subnet_ids       = module.vpc.subnet_ids
  security_group_id = module.security_groups.alb_sg_id
}

module "ecs" {
  source = "../modules/ecs"
  app_name          = "nextjs-app-dev"
  image             = "your-dockerhub-username/your-nextjs-app:latest"
  auth0_client_id   = var.auth0_client_id
  auth0_client_secret = var.auth0_client_secret
  auth0_domain      = var.auth0_domain
  subnet_ids        = module.vpc.subnet_ids
  security_group_id = module.security_groups.alb_sg_id
  target_group_arn  = module.alb.target_group_arn
}
