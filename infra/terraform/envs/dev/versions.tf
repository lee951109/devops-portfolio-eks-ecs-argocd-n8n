terraform {
  required_version = ">= 1.5.0"

  # AWS Provider(클라우드 API를 Terraform이 호출하도록 하는 플러그인) 버전 고정
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }

    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.30"
    }

    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.13"
    }
  }
}

provider "aws" {
  region = var.aws_region
}