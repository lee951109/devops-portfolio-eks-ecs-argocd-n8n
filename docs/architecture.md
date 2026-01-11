# 아티텍처 개요
본 프로젝트는 AWS EKS 기반의 Kubernetes 환경에서
Terraform과 Argo CD를 활용한 GitOps 중심 DevOps 아키텍처를 구성하고, 실제 운영 시나리오를 검증하는 것을 목표로 한다.

## 전체 흐름

1. Terraform으로 AWS 인프라(VPC, EKS, Node Group)를 구성한다.
2. Add-on 전용 Terraform Root에서 Argo CD 및 EKS Add-on을 설치한다.
3. Argo CD가 Git 저장소를 감시하며 애플리케이션을 배포한다.
4. 모든 배포 상태는 Git을 단일 진실 소스로 관리한다.
5. Git 변경 -> 자동 반영, 수동 변경 -> 자동 복구가 동작함을 검증한다.

## 주요 구성 요소

- AWS EKS: Kubernetes 클러스터
- Terraform: 인프라 및 애드온 구성
- Argo CD: GitOps 기반 배포 컨트롤러
- EBS CSI Driver: 영속 스토리지 관리
- 애플리케이션
  - todo-api (Node.js)
  - n8n (워크플로우 자동화 도구)
  