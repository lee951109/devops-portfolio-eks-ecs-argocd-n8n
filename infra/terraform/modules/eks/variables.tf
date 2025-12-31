variable "name" {
  type        = string
  description = "EKS 클러스터 이름 prefix"
}

variable "aws_region" {
  type        = string
  description = "AWS Region"
}

variable "vpc_id" {
  type        = string
  description = "EKS가 생성될 VPC ID"
}

variable "subnet_ids" {
  type        = list(string)
  description = "EKS 노드가 배치될 서브넷 ID 목록(보통 private subnet)"
}

variable "node_instance_type" {
  type        = string
  description = "Worker Node EC2 instance type"
  default     = "t3.medium"
}

# Auto Scaling Group 크기 설정
variable "desired_size" {
  type        = number
  description = "Node Group desired size"
  default     = 2
}

variable "min_size" {
  type        = number
  description = "Node Group minimum size"
  default     = 1
}

variable "max_size" {
  type        = number
  description = "Node Group maximum size"
  default     = 3
}

####################

variable "tags" {
  type        = map(string)
  description = "공통 태그"
  default     = {}
}