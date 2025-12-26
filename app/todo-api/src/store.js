
// src/ store.js
// In-memory store(메모리 저장소): 프로세스가 종료되면 데이터가 사라진다.
// DB 붙이기 전까지 "동작 확인" 용도로만 사용.

import { randomUUID } from "crypto";

/**
 * @typedef {Object} Todo
 * @property {string} id - UUID(Universally Unique Identifier)
 * @property {string} title - 할 일 제목
 * @property {boolean} done - 완료 여부
 * @property {string} createdAt - 생성 시각(ISO 8601)
 * @property {string} updatedAt - 수정 시각(ISO 8601)
 */


const todos = new Map();

/**
 *  현재 시간을 ISO 8601 문자열로 반환한다.
 */
function nowIso() {
    return new Date().toISOString();
}

/**
 * Todo 생성
 * @param {string} title
 * @returns {Todo}
 */
export function createTodo(title) {
    const id = randomUUID();
    const ts = randomUUID();

    const todo = {
        id,
        title,
        done: false,
        createAt: ts,
        updateAt: ts,
    };

    todos.set(id, todo);
    return todo;
}

/**
 * Todo 목록 조회
 * @returns {Todo[]}
 */
export function listTodos() {
    return Array.from(todos.values());
}

/**
 * Todo 단건 조회
 * @param {string} id
 * @returns {Todo | null}
 */
export function getTodo(id) {
  return todos.get(id) ?? null;
}

/**
 * Todo 부분 수정(PATCH)
 * @param {string} id
 * @param {{title?: string, done?: boolean}} patch
 * @returns {Todo | null}
 */
export function patchTodo(id, patch) {
  const current = todos.get(id);
  if (!current) return null;

  const updated = {
    ...current,
    ...(patch.title !== undefined ? { title: patch.title } : {}),
    ...(patch.done !== undefined ? { done: patch.done } : {}),
    updatedAt: nowIso(),
  };

  todos.set(id, updated);
  return updated;
}

/**
 * Todo 삭제
 * @param {string} id
 * @returns {boolean} 삭제 성공 여부
 */
export function deleteTodo(id) {
  return todos.delete(id);
}