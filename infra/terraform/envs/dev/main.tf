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
  aws_resion         = var.aws_resion
  tags               = local.tags
  enable_nat_gateway = true
}

# EKS 모듈
# module "eks" {
#   source = "../../modules/eks"

#   name       = local.name
#   aws_resion = var.aws_resion
#   vpc_id     = module.vpc.vpc_id
#   subent_ids = module.vpc.private_subent_ids
#   tags       = local.tags
# }