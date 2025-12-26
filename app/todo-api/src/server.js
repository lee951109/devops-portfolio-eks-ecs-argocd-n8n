// src/server.js
// Express 기반 HTTP API 서버
// Kubernetes에서 사용할 Health Check(/healthz, /ready)와 ToDo CRUD를 제공

import express from "express";
import {
  createTodo,
  listTodos,
  getTodo,
  patchTodo,
  deleteTodo,
} from "./store.js";

const app = express();

// JSON Body 파싱 미들웨어(Middleware: 요청/응답 사이에 끼어드는 처리 로직)
app.use(express.json());

// 포트는 환경변수(PORT)로 받되, 없으면 8080을 사용
// (컨테이너/쿠버네티스 환경에서 포트 설정을 외부에서 주입하기 쉽다.)
const PORT = process.env.PORT ? Number(process.env.PORT) : 8080;

/**
 * Liveness Probe(라이브니스 프로브)용 엔드포인트
 * - 목적: 프로세스가 살아있는지 확인
 */
app.get("/healthz", (req, res) => {
  res.status(200).json({ status: "ok" });
});

/**
 * Readiness Probe(레디니스 프로브)용 엔드포인트
 * - 목적: 트래픽을 받아도 되는 상태인지 확인
 * - Step 1-2에서 DB 연결이 추가되면 여기서 DB 연결 상태 체크
 */
app.get("/ready", (req, res) => {
  res.status(200).json({ status: "ready" });
});

/**
 * ToDo 목록 조회
 */
app.get("/todos", (req, res) => {
  res.status(200).json({ items: listTodos() });
});

/**
 * ToDo 생성
 * Body 예시: { "title": "buy milk" }
 */
app.post("/todos", async (req, res) => {
  const { title } = req.body ?? {};
  if (!title || typeof title !== "string") {
    return res.status(400).json({
      error: "Invalid title. 'title' must be a non-empty string.",
    });
  }

  const todo = createTodo(title);

  // n8n(Webhook Trigger)로 이벤트 푸시
  // - N8N_WEBHOOK_URL(환경변수)로 n8n Production Webhook 엔드포인트를 주입
  // - 외부 자동화(n8n) 장애가 ToDo 생성 자체를 막지 않도록 "best-effort"로 전송
  const n8nWebhookUrl = process.env.N8N_WEBHOOK_URL;

  if (n8nWebhookUrl) {
    try {
      const resp = await fetch(n8nWebhookUrl, {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({
          eventType: "todo.created",
          data: todo,
          sentAt: new Date().toISOString(),
        }),
      });

      // fetch는 4xx/5xx에서 throw하지 않으므로 상태코드를 직접 확인해야 함
      if (!resp.ok) {
        const text = await resp.text().catch(() => "");
        console.error(
          `[WARN] n8n webhook failed: status=${resp.status} body=${text}`
        );
      }
    } catch (err) {
      // 네트워크/DNS 등의 진짜 예외는 여기로 옴
      console.error("[WARN] Failed to notify n8n webhook:", err?.message ?? err);
    }
  } else {
    console.warn("[WARN] N8N_WEBHOOK_URL is not set. Skipping webhook notify.");
  }

  res.status(201).json(todo);
});


/**
 * ToDo 단건 조회
 */
app.get("/todos/:id", (req, res) => {
  const todo = getTodo(req.params.id);
  if (!todo) return res.status(404).json({ error: "Todo not found" });
  res.status(200).json(todo);
});

/**
 * ToDo 부분 수정
 * Body 예시: { "title": "new title", "done": true }
 */
app.patch("/todos/:id", (req, res) => {
  const { title, done } = req.body ?? {};

  if (title !== undefined && typeof title !== "string") {
    return res.status(400).json({ error: "Invalid title type" });
  }
  if (done !== undefined && typeof done !== "boolean") {
    return res.status(400).json({ error: "Invalid done type" });
  }

  const updated = patchTodo(req.params.id, { title, done });
  if (!updated) return res.status(404).json({ error: "Todo not found" });

  res.status(200).json(updated);
});

/**
 * ToDo 삭제
 */
app.delete("/todos/:id", (req, res) => {
  const ok = deleteTodo(req.params.id);
  if (!ok) return res.status(404).json({ error: "Todo not found" });
  res.status(204).send();
});

/**
 * n8n(Webhook Trigger) 연동 대비용 이벤트 엔드포인트
 * - Step 1-3에서 n8n이 이 엔드포인트를 호출하거나,
 * - 반대로 ToDo API가 n8n의 Webhook URL로 POST를 보내는 구조를 선택할 수 있다.
 */
app.post("/events/todo-created", (req, res) => {
  console.log("[EVENT] todo-created", req.body);
  res.status(202).json({ accepted: true });
});

app.post("/events/todo-updated", (req, res) => {
  console.log("[EVENT] todo-updated", req.body);
  res.status(202).json({ accepted: true });
});

app.post("/events/todo-deleted", (req, res) => {
  console.log("[EVENT] todo-deleted", req.body);
  res.status(202).json({ accepted: true });
});

app.listen(PORT, () => {
  console.log(`todo-api listening on port ${PORT}`);
});
