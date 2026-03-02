#!/usr/bin/env node

/**
 * Confucius Debug MCP Server（孔子除錯 MCP 伺服器）
 *
 * 薄殼 stdio 轉接器 — 所有請求轉發到遠端 HTTP MCP 端點。
 * 讓 Claude Desktop、Cursor 等 stdio-only 客戶端也能使用。
 *
 * 遠端端點: https://drclaw.washinmura.jp/mcp/debug
 * 直接用 HTTP 的客戶端（如 Claude Code）不需要這個包，
 * 直接設定 URL 即可。
 */

import { Readable, Writable } from "node:stream";
import { Buffer } from "node:buffer";

const REMOTE_URL = "https://drclaw.washinmura.jp/mcp/debug";

// 讀 stdin，組合完整 JSON-RPC 訊息
let buffer = "";

process.stdin.setEncoding("utf8");
process.stdin.on("data", (chunk) => {
  buffer += chunk;

  // JSON-RPC over stdio 用 \n 分隔
  let newlineIdx;
  while ((newlineIdx = buffer.indexOf("\n")) !== -1) {
    const line = buffer.slice(0, newlineIdx).trim();
    buffer = buffer.slice(newlineIdx + 1);
    if (line) handleMessage(line);
  }
});

process.stdin.on("end", () => {
  if (buffer.trim()) handleMessage(buffer.trim());
});

async function handleMessage(line) {
  try {
    const request = JSON.parse(line);

    const response = await fetch(REMOTE_URL, {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        Accept: "application/json",
        "X-Confucius-Channel": "mcp_registry",
      },
      body: JSON.stringify(request),
    });

    if (!response.ok) {
      // 回傳 JSON-RPC 錯誤
      const error = {
        jsonrpc: "2.0",
        id: request.id ?? null,
        error: {
          code: -32603,
          message: `Remote MCP server returned ${response.status}: ${response.statusText}`,
        },
      };
      process.stdout.write(JSON.stringify(error) + "\n");
      return;
    }

    const contentType = response.headers.get("content-type") || "";

    if (contentType.includes("text/event-stream")) {
      // SSE 回應 — 逐行解析 data: 事件
      const text = await response.text();
      for (const eLine of text.split("\n")) {
        if (eLine.startsWith("data: ")) {
          const data = eLine.slice(6).trim();
          if (data) process.stdout.write(data + "\n");
        }
      }
    } else {
      // 普通 JSON 回應
      const text = await response.text();
      if (text.trim()) process.stdout.write(text.trim() + "\n");
    }
  } catch (err) {
    const error = {
      jsonrpc: "2.0",
      id: null,
      error: {
        code: -32603,
        message: `Proxy error: ${err.message}`,
      },
    };
    process.stdout.write(JSON.stringify(error) + "\n");
  }
}
