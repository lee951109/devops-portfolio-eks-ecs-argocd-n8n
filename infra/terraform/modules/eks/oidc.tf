############################################
# OIDC Provider for IRSA (IAM Roles for Service Accounts)
# - EKS Add-on(예: aws-ebs-csi-driver)이 AWS API를 호출하기 위한 전제조건
############################################

# EKS가 발급하는 OIDC Issuer(발급자) URL의 인증서 지문(thumbprint)을 얻기 위해 TLS 인증서 정보를 조회
data "tls_certificate" "eks_oidc" {
  url = aws_eks_cluster.this.identity[0].oidc[0].issuer
}

# IAM OIDC Provider 생성
resource "aws_iam_openid_connect_provider" "eks" {
  url = aws_eks_cluster.this.identity[0].oidc[0].issuer

  client_id_list = [
    "sts.amazonaws.com"
  ]

  thumbprint_list = [
    data.tls_certificate.eks_oidc.certificates[0].sha1_fingerprint
  ]

  tags = merge(var.tags, {
    Name = "${var.name}-oidc-provider"
  })
}
