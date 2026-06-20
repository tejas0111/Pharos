/**
 * Shared test helpers for MCP server tests.
 */
import { resolve } from "node:path";

export const SERVER_SCRIPT = resolve(import.meta.dirname, "index.js");
export const PROJECT_ROOT = resolve(import.meta.dirname, "..");

/**
 * Send a JSON-RPC message to the MCP server via stdin
 * and read the response from stdout.
 */
export function sendRequest(server, request) {
  return new Promise((resolve, reject) => {
    const timeout = setTimeout(() => reject(new Error("Response timeout")), 10000);
    let buffer = "";

    const onData = (chunk) => {
      buffer += chunk.toString();
      try {
        const lines = buffer.trim().split("\n");
        for (const line of lines) {
          try {
            const parsed = JSON.parse(line);
            clearTimeout(timeout);
            server.stdout.removeListener("data", onData);
            resolve(parsed);
            return;
          } catch {}
        }
      } catch {}
    };

    server.stdout.on("data", onData);
    server.stdin.write(JSON.stringify(request) + "\n");
  });
}
