locals {
  product_name = "a0demo"
  environment  = "dev"
}

provider "aws" {
  region = "ap-northeast-1"
}

module "terraform_state_backend" {
  source     = "cloudposse/tfstate-backend/aws"
  namespace  = local.product_name
  stage      = local.environment
  name       = "terraform"
  attributes = ["states"]

  terraform_backend_config_file_path = "."
  terraform_backend_config_file_name = "backend.tf"
  force_destroy                      = false
}

module "s3" {
  source = "../../modules/s3"

  bucket_name = "${local.environment}-${local.product_name}-frontend"
  environment = local.environment
  oai_arn     = module.cloudfront.oai_arn
}

module "lambda_edge" {
  source  = "../../modules/lambda_edge"
  app_name = local.product_name
}

module "cloudfront" {
  source = "../../modules/cloudfront"

  bucket_name        = module.s3.bucket_name
  bucket_domain_name = module.s3.bucket_domain_name
  environment        = local.environment
  app_name           = local.product_name
  lambda_edge_arn    = module.lambda_edge.lambda_edge_function_arn
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

# module "alb" {
#   source = "../../modules/alb"
#   app_name         = "nextjs-app-dev"
#   vpc_id           = module.vpc.vpc_id
#   subnet_ids       = module.vpc.subnet_ids
#   security_group_id = module.security_groups.alb_sg_id
# }
#
# module "vpc_endpoint" {
#   source = "../../modules/vpc_endpoint"
#   vpc_id           = module.vpc.vpc_id
#   subnet_ids       = module.vpc.subnet_ids
#   route_table_ids  = [module.vpc.route_table_id]
#   alb_sg_id        = module.security_groups.alb_sg_id
# }

module "iam" {
  source = "../../modules/iam"
  app_name = "nextjs-app-dev"
}

# module "logs" {
#   source = "../../modules/logs"
#   app_name = "nextjs-app-dev"
# }
#
# module "ecs" {
#   source = "../../modules/ecs"
#   app_name          = "nextjs-app-dev"
#   image             = "388450459156.dkr.ecr.ap-northeast-1.amazonaws.com/a0demo-frontend:6bbe4ff"
#   auth0_client_id   = var.auth0_client_id
#   auth0_client_secret = var.auth0_client_secret
#   auth0_domain      = var.auth0_domain
#   subnet_ids        = module.vpc.subnet_ids
#   security_group_id = module.security_groups.ecs_sg_id
#   target_group_arn  = module.alb.target_group_arn
#   execution_role_arn = module.iam.ecs_task_execution_role_arn
#   log_group_name    = module.logs.log_group_name
# }
