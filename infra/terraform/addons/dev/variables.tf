variable "aws_region" {
  type = string
  description = "AWS Region (예: ap-northeast-2)"
}

variable "cluster_name" {
  type = string
  description = "EKS Cluster name (예: devops-portfolio-dev)"
}

variable "tags" {
  type = map(string)
  description = "공통 태그"
  default = {}
}