# data-eks.tf
# 목적:
# - Add-ons Root에서 "이미 존재하는" EKS(Elastic Kubernetes Service) 클러스터 정보를 조회한다.
# - Helm provider 또는 Add-on 설치(aws_eks_addon)에서 참조할 수 있게 한다.

# EKS 클러스터의 Endpoint, CA 인증서, OIDC issuer 등 메타 정보를 가져온다.
data "aws_eks_cluster" "this" {
  name = var.cluster_name
}

# EKS API 호출에 사용할 인증 토큰을 가져온다.
# (token은 짧은 TTL(Time To Live)을 가지므로, terraform 실행 시점에 동적으로 생성된다.)
data "aws_eks_cluster_auth" "this" {
  name = var.cluster_name
}
