# Terraform이 "방금 만든 EKS"에 접속해서
# Kubernetes 리소스/Helm 설치를 수행할 수 있도록 연결 정보를 구성한다.

# EKS endpoint/CA 인증서 획득
data "aws_eks_cluster" "this" {
  name = module.eks.cluster_name
}

# EKS 접속 토큰 획득
data "aws_eks_cluster_auth" "this" {
  name = module.eks.cluster_name
}

# Terraform이 kubectl 처럼 클러스터에 리소스 생성 가능
provider "kubernetes" {
  host                   = data.aws_eks_cluster.this.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.this.certificate_authority[0].data)
  token                  = data.aws_eks_cluster_auth.this.token
}

# Terraform이 Helm 차트를 설치 가능
provider "helm" {
  # helm provider가 로컬/환경의 kubeconfig를 사용하도록 둠
  #   kubernetes {
  #     host                   = data.aws_eks_cluster.this.endpoint
  #     cluster_ca_certificate = base64decode(data.aws_eks_cluster.this.certificate_authority[0].data)
  #     token                  = data.aws_eks_cluster_auth.this.token
  #   }

  kubernetes {
    # Windows에서도 확실하게 읽히는 경로 표기
    config_path = "C:/Users/이지현/.kube/config"
  }
}