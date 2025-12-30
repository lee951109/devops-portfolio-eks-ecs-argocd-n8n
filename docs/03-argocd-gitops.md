# Argo CD 기반 GitOps 배포 (Step 2-3)

## 1. 목적 (Goal)
이 단계의 목적은 Argo CD(Argo Continuous Delivery)를 사용하여 GitOps(Git-based Operations) 방식으로
Kubernetes 리소스(YAML Manifest)를 EKS(Elastic Kubernetes Service)에 자동 동기화(Sync)하는 흐름을 구성하는 것이다.

핵심은 아래 한 문장으로 요약된다.

- **Git 저장소의 상태가 정답(Source of Truth)이며**, Argo CD는 클러스터 상태를 Git과 동일하게 맞춘다.

---

## 2. GitOps 핵심 용어 정리

- **Desired State(원하는 상태)**  
  Git에 정의된 리소스 상태(Deployment/Service 등)가 “원하는 상태”이다.

- **Actual State(실제 상태)**  
  Kubernetes 클러스터에 현재 적용된 리소스 상태이다.

- **Drift(드리프트: 불일치)**  
  Desired State(Git)와 Actual State(클러스터)가 달라진 상태.
  예: 수동 kubectl apply로 리소스가 바뀌거나, 이미지 태그가 변경된 경우

- **Sync(동기화)**  
  Argo CD가 Git을 기준으로 클러스터를 변경하여 Drift를 해소하는 과정

---

## 3. 저장소 구조 (Repository Layout)

Argo CD는 특정 경로(Path)를 기준으로 매니페스트를 생성한다.
이 프로젝트는 base/overlay 구조를 사용한다.

- `k8s/base/` : 환경과 무관한 공통 리소스
- `k8s/envs/dev/` : dev 환경에만 적용되는 설정(이미지 태그, 환경변수, replica 등)

예시 구조:

```text
k8s/
  base/
    todo-api/
      deployment.yaml
      service.yaml
      configmap.yaml
      kustomization.yaml
  envs/
    dev/
      namespace.yaml
      kustomization.yaml
      todo-api-patch.yaml
```
---

## 4. Kustomize(커스터마이즈) 사용 이유
Kustomize(Kustomize: Kubernetes manifest customization tool)는
“base 리소스 + overlay 덮어쓰기” 방식을 제공한다.
- base에는 공통 구조를 정의한다.
- overlay에는 환경별 차이만 정의한다.
이 구조의 장점:
- dev/prod 환경 추가가 쉽다 (overlay만 추가)
- 공통 리소스 수정 시 base만 변경하면 된다
- GitOps에서 변경 지점이 명확해져 리뷰/추적이 쉬워진다

---

## 5. 이번 단계에서 겪은 오류와 해결
### 5.1 오류: Argo CD에서 Kustomize build 실패
Argo CD Application 생성 시 아래 유형의 오류가 발생할 수 있다.
- ```kustomize build ... failed```
- ```file is not in or below ...``` (경로 밖 참조 제한)
- ```file is not directory``` (resource로 파일을 직접 참조)

원인
- overlay(```k8s/envs/dev```)에서 base 파일을 ```../../base/.../deployment.yaml```처럼 파일 단위로 직접 참조하면
 Argo CD의 보안 정책/캐싱 경로 제한에 의해 실패할 수 있다.
- Kustomize는 base를 “디렉토리 단위”로 참조하는 것이 가장 안정적이다.

해결
- ```k8s/base/todo-api/kustomization.yaml```을 생성하여 base를 “빌드 가능한 디렉토리”로 만든다.
- overlay에서는 파일이 아니라 디렉토리를 참조한다.

---

## 6. Argo CD Application 설정(요약)
Argo CD Application은 다음 정보를 가진다.
- Source(소스)
 - Repository URL: (Git Repository)
 - Revision: main 또는 develop
 - Path: k8s/envs/dev
- Destination(대상)
 - Cluster: 대상 EKS 클러스터
 - Namespace: dev
- Sync Policy(동기화 정책)
 - Manual: 수동 Sync
 - Auto: Git 변경 시 자동 Sync (안정화 후 적용 권장)

 ---

 ## 7. 검증 방법 (Validation)
 ### 7.1 클러스터 리소스 확인
 ```bash
    kubectl get ns | grep dev
    kubectl get deploy,svc,pods -n dev
 ```

 ### 7.2 서비스 동작 확인 (Port Forwarding)
Service가 ClusterIP일 경우 외부에서 바로 접근이 어렵다.
포트 포워딩을 통해 로컬에서 확인한다.
```bash
    kubectl port-forward svc/todo-api -n dev 18080:80
    curl http://localhost:18080/healthz
    curl http://localhost:18080/ready
```
정상 응답이 오면 배포 성공이다.
