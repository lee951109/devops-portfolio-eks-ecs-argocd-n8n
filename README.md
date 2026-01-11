# DevOps Portfolio  
EKS · ECS · Argo CD · n8n · GitHub Actions · Terraform · GitOps

---

## 1. 프로젝트 목표

본 프로젝트는 AWS 환경에서 **GitOps 기반 DevOps 아키텍처를 직접 설계·구현·검증**하는 것을 목표로 한다.

주요 목표는 다음과 같다.

- ToDo 애플리케이션과 n8n(워크플로우 자동화 도구)을 컨테이너화
- AWS EKS(Elastic Kubernetes Service)에 **Argo CD 기반 GitOps 방식으로 배포**
- Git 변경 → 자동 반영, 수동 변경 → 자동 복구가 동작함을 실제로 검증
- 동일 애플리케이션을 AWS ECS(Elastic Container Service) 기준으로도 배포하여
  **EKS와 ECS의 운영 관점 차이를 비교**
- CI/CD, 인프라 자동화, 운영 안정성까지 포함한 DevOps 포트폴리오 구성

---

## 2. 사용 기술

### Container / Orchestration
- Docker (컨테이너 이미지 빌드)
- Kubernetes

### Cloud (AWS)
- AWS EKS (Elastic Kubernetes Service)
- AWS ECS (Elastic Container Service)
- Amazon EBS + EBS CSI Driver (스토리지)

### GitOps / CI·CD
- Argo CD (Argo Continuous Delivery)
- GitHub Actions (Continuous Integration)

### Infrastructure as Code
- Terraform

### Application
- ToDo API (Node.js)
- n8n (Workflow Automation Platform)

---

## 3. 리포지토리 구조

```text
.
├─ app/                 # 애플리케이션 소스 (ToDo API, n8n)
├─ infra/               # Terraform 인프라 코드
│  └─ terraform/
│     ├─ envs/dev       # Infra Root (VPC, EKS, Node Group)
│     └─ addons/dev     # Add-ons Root (Argo CD, EBS CSI, IRSA)
├─ k8s/                 # Kubernetes 리소스(manifest)
│  └─ envs/dev          # dev 환경 Deployment, Service 등
├─ gitops/              # Argo CD GitOps 리소스
│  └─ argocd/
│     ├─ bootstrap      # apps-root Application
│     └─ apps           # todo-api-dev, n8n Application
├─ docs/                # 아키텍처 및 운영 문서
└─ README.md
