variable "aws_region" {
  type        = string
  description = "AWS Region"
  default     = "ap-northeast-2"
}

variable "project_name" {
  type        = string
  description = "프로젝트 이름"
  default     = "devops-portfolio"
}

variable "env" {
  type        = string
  description = "환경 이름 (dev/stage/prod)"
  default     = "dev"
}