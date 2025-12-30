variable "name" {
  type        = string
  description = "리소스 네이밍 prefix"
}

variable "aws_resion" {
  type        = string
  description = "AWS Region"
}

variable "vpc_cidr" {
  type        = string
  description = "VPC CIDR (Classless Inter-Domain Routing)"
  default     = "10.0.0.0/16"
}

variable "az_count" {
  type        = number
  description = "사용할 Availavility Zone 개수"
  default     = 2
}

variable "enable_nat_gateway" {
  type        = bool
  description = "NAT Gateway 생성 여부"
  default     = true
}

variable "tags" {
  type        = map(string)
  description = "공통 태그"
  default     = {}
}