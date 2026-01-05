# data-oidc.tf
# 목적:
# - IRSA(IAM Roles for Service Accounts)를 위해 OIDC(OpenID Connect) Provider를 조회한다.
# - EBS CSI Driver 같은 Controller가 AWS API를 호출할 수 있도록 IAM Role trust policy를 만들 때 사용한다.

# EKS 클러스터가 사용하는 OIDC issuer URL을 기반으로,
# AWS에 등록된 OIDC Provider 리소스를 조회한다.
data "aws_iam_openid_connect_provider" "eks" {
  # data.aws_eks_cluster.this.identity[0].oidc[0].issuer 는 보통 "https://oidc.eks...." 형태
  url = data.aws_eks_cluster.this.identity[0].oidc[0].issuer
}

# issuer URL에서 "https://"를 제거한 문자열.
# trust policy에서 condition key를 만들 때 필요하다.
locals {
  oidc_issuer_hostpath = replace(data.aws_iam_openid_connect_provider.eks.url, "https://", "")
}
