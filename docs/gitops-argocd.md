# Argo CD 기반 GitOps 구성

본 프로젝트는 Argo CD를 GitOps 컨트롤러로 사용한다.

## App of Apps 패턴

- apps-root Application이 최상위 컨트롤러 역할
- 하위 Application
  - todo-api-dev
  - n8n

이를 통해 여러 애플리케이션을 하나의 진입점에서 관리한다.

## 선언적 배포 원칙

- 모든 Application 설정은 Git에 선언
- Argo CD UI에서의 수동 설정은 사용하지 않음
- UI 변경은 Git 선언이 없을 경우 자동으로 원복됨

Git이 항상 배포 상태의 기준이 된다.