# DevOps Portfolio
EKS · ECS · Argo CD · n8n · GitHub Actions

## 1. 프로젝트 목표
- ToDo 애플리케이션과 n8n(워크플로우 자동화 도구)을 컨테이너화
- AWS EKS(Elastic Kubernetes Service)에 GitOps 방식으로 배포
- 동일 서비스를 AWS ECS(Elastic Container Service)에도 배포하여 운영 관점 비교
- CI/CD, 자동화, 운영 관점까지 포함한 DevOps 포트폴리오 구성

## 2. 사용 기술
- Docker (Container)
- Kubernetes
- AWS EKS (Elastic Kubernetes Service)
- AWS ECS (Elastic Container Service)
- Argo CD (Argo Continuous Delivery)
- GitHub Actions (Continuous Integration)
- n8n (Workflow Automation Platform)
- Terraform (Infrastructure as Code)

## 3. 리포지토리 구조
- app/: 애플리케이션(ToDo App, n8n)
- infra/: 클라우드 인프라(EKS, ECS)
- k8s/: Kubernetes 리소스
- gitops/: Argo CD, GitOps 관련 리소스
- docs/: 설명 및 운영 문서

