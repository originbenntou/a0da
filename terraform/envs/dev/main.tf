locals {
  product = "a0demo"
  environment  = "dev"
}

provider "aws" {
  region = "ap-northeast-1"
}

module "terraform_state_backend" {
  source     = "cloudposse/tfstate-backend/aws"
  namespace  = local.product
  stage      = local.environment
  name       = "terraform"
  attributes = ["states"]

  terraform_backend_config_file_path = "."
  terraform_backend_config_file_name = "backend.tf"
  force_destroy                      = false
}

module "vpc" {
  source = "../../modules/vpc"

  vpc_cidr    = var.vpc_cidr
  subnet_cidr1 = var.subnet_cidr1
  subnet_cidr2 = var.subnet_cidr2
  az_a = "ap-northeast-1a"
  az_c = "ap-northeast-1c"
}

module "security_groups" {
  source = "../../modules/security_groups"
  vpc_id = module.vpc.vpc_id
}

module "alb" {
  source = "../../modules/alb"
  app_name         = "nextjs-app-dev"
  vpc_id           = module.vpc.vpc_id
  subnet_ids       = module.vpc.subnet_ids
  security_group_id = module.security_groups.alb_sg_id
}

module "ecs" {
  source = "../../modules/ecs"
  app_name          = "nextjs-app-dev"
  image             = "388450459156.dkr.ecr.ap-northeast-1.amazonaws.com/a0demo-frontend:a21cb22"
  auth0_client_id   = var.auth0_client_id
  auth0_client_secret = var.auth0_client_secret
  auth0_domain      = var.auth0_domain
  subnet_ids        = module.vpc.subnet_ids
  security_group_id = module.security_groups.alb_sg_id
  target_group_arn  = module.alb.target_group_arn
}
