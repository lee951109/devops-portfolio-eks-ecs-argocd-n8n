############################################
# EBS CSI Driver (Elastic Block Store Container Storage Interface Driver)
# - Purpose: PVC(PersistentVolumeClaim)가 EBS 볼륨을 자동 생성/Attach/Mount 하도록 함
############################################

# locals {
#   oidc_issuer_hostpath = replace(
#     data.aws_iam_openid_connect_provider.eks.url,
#     "https://",
#     ""
#   )
# }

# 1) IAM Role for ServiceAccount (IRSA: IAM Roles for Service Accounts)
#    - kube-system 네임스페이스의 ebs-csi-controller-sa ServiceAccount가 이 Role을 Assume
resource "aws_iam_role" "ebs_csi" {
  name = "${var.cluster_name}-ebs-csi-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"

      # OIDC Provider를 통해 WebIdentity로 Assume
      Principal = {
        Federated = data.aws_iam_openid_connect_provider.eks.arn
      }

      Action = "sts:AssumeRoleWithWebIdentity"

      # 특정 ServiceAccount만 Assume 가능하도록 제한(보안 핵심)
      Condition = {
        StringEquals = {
          "${local.oidc_issuer_hostpath}:sub" = "system:serviceaccount:kube-system:ebs-csi-controller-sa"
        }
      }
    }]
  })

  tags = merge(var.tags, {
    Name = "${var.cluster_name}-ebs-csi-role"
  })
}

# 2) AWS Managed Policy Attach
#    - EBS 볼륨 생성/삭제/Attach 등 권한을 AWS가 제공하는 표준 정책으로 부여
resource "aws_iam_role_policy_attachment" "ebs_csi_attach" {
  role       = aws_iam_role.ebs_csi.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
}

# 3) EKS Add-on 설치
#    - EKS가 관리형으로 aws-ebs-csi-driver를 설치/업데이트/운영
resource "aws_eks_addon" "ebs_csi" {
  cluster_name = data.aws_eks_cluster.this.name
  addon_name   = "aws-ebs-csi-driver"

  # IRSA 연결(여기가 핵심)
  service_account_role_arn = aws_iam_role.ebs_csi.arn

  # 충돌 발생 시 최신 상태를 우선(실습/포트폴리오에서 편함)
  resolve_conflicts_on_create = "OVERWRITE"
  resolve_conflicts_on_update = "OVERWRITE"

  depends_on = [
    aws_iam_role_policy_attachment.ebs_csi_attach
  ]

  tags = merge(var.tags, {
    Name = "${var.cluster_name}-aws-ebs-csi-driver"
  })
}
