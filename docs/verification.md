# GitOps 동작 검증

본 본문에서는 GitOps 핵심 기능이 실제로 동작함을 검증한 내용을 정리한다.

## 1. Auto Sync 검증

- Git에서 Deployment의 replicas 값을 변경
- 별도의 Sync 버튼 클릭 없이 자동으로 클러스터에 반영됨

## 2. Self Heal 검증

- kubectl을 통해 클러스터에 replicas를 임의 변경
- Argo CD가 Git 상태로 자동 복구함을 확인

## 3. Prune 검증

- Git에서 리소스(configMap) 삭제
- 클러스터에서도 자동으로 리소스가 삭제됨을 확인

이를 통해 Git 선언이 항상 최종 상태를 결정함을 검증하였다.
