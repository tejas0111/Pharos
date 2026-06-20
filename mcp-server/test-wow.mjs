import { describe, it, before, after } from "node:test";
import assert from "node:assert/strict";
import { spawn } from "node:child_process";
import { sendRequest, SERVER_SCRIPT } from "./test-helpers.mjs";

let server;

describe("MCP Server - Wow Tests", () => {
  before(() => {
    server = spawn(process.execPath, ["index.js"], {
      stdio: ["pipe", "pipe", "pipe"],
      env: { ...process.env, NODE_ENV: "test" },
    });
    server.stderr.on("data", () => {});
  });

  after(() => { server.kill(); });

  it("should list all 20+ tools with valid schemas", async () => {
    const res = await sendRequest(server, { jsonrpc: "2.0", id: 1, method: "tools/list", params: {} });
    const tools = res?.result?.tools || [];
    assert.ok(tools.length >= 20, "has at least 20 tools");
    for (const tool of tools) {
      assert.ok(tool.description, tool.name + " has description");
      assert.ok(tool.inputSchema, tool.name + " has inputSchema");
    }
  });

  it("should return error for unknown tool", async () => {
    const res = await sendRequest(server, { jsonrpc: "2.0", id: 1, method: "tools/call", params: {
      name: "pharos_nonexistent_tool_xyz",
      arguments: {},
    } });
    assert.ok(res.isError, 'returns isError flag');
    const errText = JSON.stringify(res).toLowerCase();
    assert.ok(errText.includes('unknown'), 'error mentions unknown tool');
  });

  it("should handle network config for atlanticTestnet", async () => {
    const res = await sendRequest(server, { jsonrpc: "2.0", id: 1, method: "tools/call", params: {
      name: "pharos_network_config",
      arguments: { network: "atlanticTestnet" },
    } });
    const text = JSON.stringify(res);
    assert.ok(text.toLowerCase().includes('688689') || text.toLowerCase().includes('atlantic'), "has Atlantic chain info");
  });

  it("should handle network config for pacificMainnet", async () => {
    const res = await sendRequest(server, { jsonrpc: "2.0", id: 1, method: "tools/call", params: {
      name: "pharos_network_config",
      arguments: { network: "pacificMainnet" },
    } });
    const text = JSON.stringify(res);
    assert.ok(text.toLowerCase().includes('1672') || text.toLowerCase().includes('pacific'), "has Pacific chain info");
  });
});
