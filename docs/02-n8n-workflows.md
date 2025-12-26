### 1. 개요 (Overview) ###

이 단계에서는 ToDo API에서 발생한 이벤트를 n8n(Webhook 기반 자동화 도구) 로 전달하고,
n8n에서 이를 조건 분기(IF) 및 데이터 가공(Set) 을 통해 처리하는 자동화 파이프라인을 구성한다.

본 단계의 목적은 단순한 연동을 넘어서,

- 애플리케이션 이벤트를
- 자동화 워크플로우로 수신하고
- 조건에 따라 처리 흐름을 제어하며
- 실행 이력을 추적 가능하게 만드는 것
이다.

### 2. 전체 흐름 아키텍처 ###
```
[Todo API]
   └─ POST /todos
        └─ Webhook POST
             ↓
        [n8n Webhook Trigger]
             ↓
        [IF Node]
          ├─ true  → [Set Node] → [Respond to Webhook]
          └─ false → [Respond to Webhook]
```
구성 요소 설명
- Webhook Trigger
 외부 시스템(Todo API)에서 발생한 이벤트를 HTTP POST 방식으로 수신
- IF(조건 분기)
 이벤트 타입에 따라 워크플로우 처리 여부 결정
- Set(데이터 가공)
 원본 JSON 데이터를 사람이 읽기 쉬운 형태로 변환
- Respond to Webhook
 호출자(Todo API)에게 처리 결과를 HTTP 응답으로 반환

 ### 3. Webhook 입력 데이터 구조 ###
 Todo API에서 n8n으로 전달되는 JSON payload 구조는 다음과 같다.
  {
  "eventType": "todo.created",
  "data": {
    "id": "uuid",
    "title": "deploy: argocd sync test",
    "done": false,
    "createAt": "...",
    "updateAt": "..."
  },
  "sentAt": "2025-12-26T08:32:00Z"
}
주요 필드 설명
- eventType
 이벤트 종류(예: todo.created)
- data
 실제 도메인 데이터 (ToDo 객체)
- sentAt
 이벤트 발생 시각

### 4. IF 노드 - 조건 분기 설계 ###
조건 설정
{{$json.eventType}} is equal to "todo.created"

설계 의도
- Todo 생성 이벤트만 자동화 대상으로 처리
- 추후 todo.updated, todo.deleted 이벤트가 추가되더라도
 동일한 워크플로우에서 확장 가능하도록 설계

### 5. Set노드 - 데이터 가공 ###
IF 노드의 true 브랜치에서 Set 노드를 사용하여 데이터를 가공한다.

생성 필드 예시
| 필드명      | 설명               |
| -------- | ---------------- |
| message  | 사람이 읽기 쉬운 로그 메시지 |
| severity | 이벤트 중요도 (info)   |

message 필드 예시(Expression)
```ToDo Created: {{$json.data.title}} (id: {{$json.data.id}}) at {{$json.sentAt}}```

설계의도 
- 원본 JSON은 구조적이지만 사람이 즉시 이해하기 어렵기 때문에
- 자동화 로그 / 알림 / 감사(Audit) 용도로 활용 가능한 형태로 변환

### 6. Respond to Webhook — 처리 결과 응답 ###
ture
```
{
  "received": true,
  "processed": true,
  "message": "{{가공된 메시지}}"
}
```

false
```
{
  "received": true,
  "processed": false,
  "reason": "filtered"
}
```


<img width="1715" height="510" alt="image" src="https://github.com/user-attachments/assets/e4d8bcdc-8911-4543-9d56-5682dac95d74" />

