resource "aws_vpc_endpoint" "ecr_dkr" {
  vpc_id       = var.vpc_id
  service_name = "com.amazonaws.ap-northeast-1.ecr.dkr"
  vpc_endpoint_type = "Interface"
  private_dns_enabled = true
  subnet_ids   = var.subnet_ids
  security_group_ids = [var.alb_sg_id]
}

resource "aws_vpc_endpoint" "ecr_api" {
  vpc_id       = var.vpc_id
  service_name = "com.amazonaws.ap-northeast-1.ecr.api"
  vpc_endpoint_type = "Interface"
  private_dns_enabled = true
  subnet_ids   = var.subnet_ids
  security_group_ids = [var.alb_sg_id]
}

resource "aws_vpc_endpoint" "s3" {
  vpc_id       = var.vpc_id
  service_name = "com.amazonaws.ap-northeast-1.s3"
  vpc_endpoint_type = "Gateway"
  route_table_ids = var.route_table_ids
}

resource "aws_vpc_endpoint" "logs" {
  vpc_id       = var.vpc_id
  service_name = "com.amazonaws.ap-northeast-1.logs"
  vpc_endpoint_type = "Interface"
  private_dns_enabled = true
  subnet_ids   = var.subnet_ids
  security_group_ids = [var.alb_sg_id]
}