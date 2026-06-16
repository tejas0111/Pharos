import { spawn } from "child_process";
import { fileURLToPath } from "url";
import { dirname, join } from "path";

const __dirname = dirname(fileURLToPath(import.meta.url));
export const PROJECT_ROOT = join(__dirname, "..");

export function startServer() {
  const s = spawn("node", ["mcp-server/index.js"], {
    cwd: PROJECT_ROOT,
    env: { ...process.env },
    stdio: ["pipe", "pipe", "pipe"],
  });
  return s;
}

export function createClient(server) {
  let msgId = 0;
  let buffer = "";
  const pending = new Map();

  server.stdout.on("data", (chunk) => {
    buffer += chunk.toString();
    const lines = buffer.split("\n");
    buffer = lines.pop();
    for (const line of lines) {
      const t = line.trim();
      if (!t) continue;
      try {
        const msg = JSON.parse(t);
        if (msg.id !== undefined && pending.has(msg.id)) {
          pending.get(msg.id)(msg);
          pending.delete(msg.id);
        }
      } catch { }
    }
  });

  server.stderr.on("data", () => { });
  server.on("error", (e) => { throw e; });
  server.on("exit", (code) => {
    if (code !== 0 && code !== null) {
      for (const [, reject] of pending) reject(new Error(`Server exited with code ${code}`));
      pending.clear();
    }
  });
  server.stdin.on("error", () => { });

  function send(method, params) {
    return new Promise((resolve, reject) => {
      const id = ++msgId;
      pending.set(id, resolve);
      const msg = JSON.stringify({ jsonrpc: "2.0", id, method, params }) + "\n";
      server.stdin.write(msg);
      setTimeout(() => {
        if (pending.has(id)) {
          pending.delete(id);
          reject(new Error(`Timeout waiting for ${method}`));
        }
      }, 30000);
    });
  }

  async function callTool(name, args) {
    const resp = await send("tools/call", { name, arguments: args });
    if (resp.error) throw new Error(resp.error.message);
    const result = resp.result?.content?.[0]?.text;
    return result ? JSON.parse(result) : resp.result;
  }

  async function initialize() {
    await send("initialize", {
      protocolVersion: "2024-11-05",
      capabilities: {},
      clientInfo: { name: "pharos-mcp-demo", version: "1.0.0" },
    });
    await send("notifications/initialized", {});
    const listResp = await send("tools/list", {});
    return listResp.result?.tools || [];
  }

  return { send, callTool, initialize };
}

export function section(label) {
  console.log(`\n${"=".repeat(70)}`);
  console.log(`  ${label}`);
  console.log(`${"=".repeat(70)}`);
}

export function print(label, data) {
  console.log(`\n  ◆ ${label}`);
  const str = typeof data === "string" ? data : JSON.stringify(data, null, 2);
  const lines = str.split("\n").map(l => `    ${l}`);
  console.log(lines.join("\n"));
}

export async function safeCall(server, client, toolName, args, fallback) {
  try {
    return await client.callTool(toolName, args);
  } catch (e) {
    print(`${toolName} — ⚠ OFFLINE`, fallback || `(RPC unreachable — expected output shown)`);
    return null;
  }
}
