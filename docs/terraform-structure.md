# Terraform 구조 설계

Terraform 설정은 의도적으로 두 개의 Root로 분리하였다.

## Infra Root (`infra/terraform/dev`)
- VPC
- EKS Cluster
- Managed Node Group
- OIDC Provider

## Add-ons Root (`infra/terraform/addons/dev`)
- Argo CD (Helm)
- EBS CSI Driver
- IRSA (IAM Role for Service Account)

## Root 분리 이유

- 인프라와 애플리케이션 플랫폼 책임 분리
- 클러스터 재생성 시 Add-ons 재사용 확보
- destroy/recreate 시 안정성 확보
- 실무에서의 인프라 팀 / 플랫폼 팀 역할 분리를 반영
