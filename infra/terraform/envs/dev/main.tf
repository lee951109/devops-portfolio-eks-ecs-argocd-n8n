locals {
  name = "${var.project_name}-${var.env}"
  tags = {
    Project = var.project_name
    Env     = var.env
  }
}

# VPC Module
module "vpc" {
  source = "../../modules/vpc"

  name               = local.name
  aws_resion         = var.aws_region
  tags               = local.tags
  enable_nat_gateway = true
}

# EKS 모듈
module "eks" {
  source = "../../modules/eks"

  name       = local.name
  aws_region = var.aws_region
  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnet_ids
  tags       = local.tags
}