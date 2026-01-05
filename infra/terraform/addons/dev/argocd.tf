# Argo CD를 Helm Chart로 설치

resource "kubernetes_namespace" "argocd" {
  metadata {
    name = "argocd"

    # 공통 태그를 Kubernetes label로도 남기고 싶다면 아래처럼 확장 가능
    # labels = {
    #   project = var.project_name
    #   env     = var.env
    # }
  }
}

resource "helm_release" "argocd" {
  name       = "argocd"
  namespace  = kubernetes_namespace.argocd.metadata[0].name
  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argo-cd"
  version    = "7.6.12"

  # 설치 옵션: 우선 기본값으로
  # 운영에서는 values.yaml로 세부 설정(SSO, Ingress, RBAC 등)을 관리
  values = [
    yamlencode({
      server = {
        service = {
          type = "ClusterIP"
        }
      }
    })
  ]

  depends_on = [kubernetes_namespace.argocd]
}

