provider "aws" {
  region = var.aws_region
}

# Terraform이 kubectl 처럼 클러스터에 리소스 생성 가능
provider "kubernetes" {
  host                   = data.aws_eks_cluster.this.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.this.certificate_authority[0].data)
  token                  = data.aws_eks_cluster_auth.this.token
}


# Helm provider가 EKS API 서버에 직접 붙어서 Helm Chart를 설치한다.
# - host: EKS API endpoint
# - cluster_ca_certificate: EKS CA(인증서) - base64 decode 필요
# - token: EKS 인증 토큰 (aws_eks_cluster_auth)
provider "helm" {
  kubernetes = {
    host                   = data.aws_eks_cluster.this.endpoint
    cluster_ca_certificate = base64decode(data.aws_eks_cluster.this.certificate_authority[0].data)
    token                  = data.aws_eks_cluster_auth.this.token
  }

  #   확인용
  #   kubernetes {
  #     # Windows에서도 확실하게 읽히는 경로 표기
  #     config_path = "C:/Users/이지현/.kube/config"
  #   }
}