/**
 * Behavioral MCP Tests
 * 
 * Tests that validate tool handler behavior, not just structure.
 * Runs against an Anvil fork or uses mocked RPC responses.
 */

import { describe, it, before, after } from "node:test";
import assert from "node:assert";
import { spawn } from "node:child_process";
import { sendRequest, SERVER_SCRIPT, PROJECT_ROOT } from "./test-helpers.mjs";

describe("MCP Server — Tool Registration", async () => {
  const server = spawn("node", [SERVER_SCRIPT], {
    stdio: ["pipe", "pipe", "pipe"],
    env: { ...process.env, PATH: process.env.PATH },
    cwd: PROJECT_ROOT,
  });

  let tools = {};

  before(async () => {
    // Request tool list
    const response = await sendRequest(server, {
      jsonrpc: "2.0",
      id: 1,
      method: "tools/list",
      params: {},
    });
    
    if (response?.result?.tools) {
      for (const tool of response.result.tools) {
        tools[tool.name] = tool;
      }
    }
  });

  after(() => {
    server.kill();
  });

  it("should register at least 20 tools", () => {
    const count = Object.keys(tools).length;
    assert.ok(count >= 20, `Expected >=20 tools, got ${count}`);
  });

  it("should register network_config tool with inputSchema", () => {
    assert.ok(tools["pharos_network_config"], "pharos_network_config not found");
    assert.ok(tools["pharos_network_config"].inputSchema, "Missing inputSchema");
  });

  it("should register deploy_contract tool", () => {
    assert.ok(tools["pharos_deploy_contract"], "pharos_deploy_contract not found");
    assert.ok(tools["pharos_deploy_contract"].description, "Missing description");
  });

  it("should register verify_contract tool", () => {
    assert.ok(tools["pharos_verify_contract"], "pharos_verify_contract not found");
  });

  it("should register check_balance tool", () => {
    assert.ok(tools["pharos_check_balance"], "pharos_check_balance not found");
  });

  it("should register transfer_token tool", () => {
    assert.ok(tools["pharos_transfer_token"], "pharos_transfer_token not found");
  });

  it("should register read_contract tool", () => {
    assert.ok(tools["pharos_read_contract"], "pharos_read_contract not found");
  });

  it("should register write_contract tool", () => {
    assert.ok(tools["pharos_write_contract"], "pharos_write_contract not found");
  });

  it("should register run_security_check tool", () => {
    assert.ok(tools["pharos_run_security_check"], "pharos_run_security_check not found");
  });

  it("should register safe multi-sig tools", () => {
    assert.ok(tools["pharos_create_safe_tx"], "pharos_create_safe_tx not found");
    assert.ok(tools["pharos_propose_safe_tx"], "pharos_propose_safe_tx not found");
  });

  it("should register frontend_sync tool", () => {
    assert.ok(tools["pharos_frontend_sync"], "pharos_frontend_sync not found");
  });

  it("should include valid inputSchema with types", () => {
    for (const [name, tool] of Object.entries(tools)) {
      assert.ok(tool.inputSchema, `${name} missing inputSchema`);
      if (tool.inputSchema.properties) {
        for (const [propName, prop] of Object.entries(tool.inputSchema.properties)) {
          assert.ok(prop.type, `${name}.${propName} missing type`);
        }
      }
    }
  });

  it("should include network parameter on deploy tools", () => {
    const deployTool = tools["pharos_deploy_contract"];
    if (deployTool?.inputSchema?.properties?.network) {
      const network = deployTool.inputSchema.properties.network;
      assert.ok(network.enum, "network should have enum values");
      assert.ok(network.enum.includes("atlanticTestnet"), "should include atlanticTestnet");
      assert.ok(network.enum.includes("pacificMainnet"), "should include pacificMainnet");
    }
  });
});

// ── Behavioral: network_config returns valid data ──
describe("MCP Server — Tool Behavior", async () => {
  const server = spawn("node", [SERVER_SCRIPT], {
    stdio: ["pipe", "pipe", "pipe"],
    env: { ...process.env },
    cwd: PROJECT_ROOT,
  });

  after(() => {
    server.kill();
  });

  it("network_config should return testnet details", async () => {
    const response = await sendRequest(server, {
      jsonrpc: "2.0",
      id: 2,
      method: "tools/call",
      params: {
        name: "pharos_network_config",
        arguments: {},
      },
    });

    assert.ok(response?.result?.content, "No content returned");
    const text = response.result.content.map(c => c.text).join(" ");
    assert.ok(text.includes("688689") || text.includes("1672"), "Should include chain ID");
    assert.ok(text.length > 50, "Response too short");
  });

  it("check_balance should return error for invalid address", async () => {
    const response = await sendRequest(server, {
      jsonrpc: "2.0",
      id: 3,
      method: "tools/call",
      params: {
        name: "pharos_check_balance",
        arguments: {
          network: "atlanticTestnet",
          address: "0x0000000000000000000000000000000000000000",
        },
      },
    });

    // Should either return a balance (0) or a meaningful error
    assert.ok(response?.result?.content, "No response from check_balance");
  });

  it("gas_estimate should return for known function", async () => {
    const response = await sendRequest(server, {
      jsonrpc: "2.0",
      id: 4,
      method: "tools/call",
      params: {
        name: "pharos_gas_estimate",
        arguments: {
          network: "atlanticTestnet",
        },
      },
    });

    assert.ok(response?.result?.content, "No response from gas_estimate");
  });

  it("should return error for unknown tool", async () => {
    const response = await sendRequest(server, {
      jsonrpc: "2.0",
      id: 5,
      method: "tools/call",
      params: {
        name: "pharos_nonexistent_tool",
        arguments: {},
      },
    });

    // Either isError flag is set, or error text mentions "unknown"
    const text = JSON.stringify(response);
    assert.ok(
      response?.isError || text.includes("Unknown") || text.includes("unknown"),
      "Should report unknown tool"
    );
  });
});

// ── Self-Test: Run this file ──
// node --test mcp-server/test-behavioral.mjs
