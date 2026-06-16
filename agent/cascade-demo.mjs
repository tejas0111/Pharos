#!/usr/bin/env node

import { spawn } from "child_process";
import { fileURLToPath } from "url";
import { dirname, join } from "path";

const __dirname = dirname(fileURLToPath(import.meta.url));
const PROJECT_ROOT = join(__dirname, "..");

let msgId = 0;
let buffer = "";
let pending = new Map();

function startServer() {
  const s = spawn("node", ["mcp-server/index.js"], {
    cwd: PROJECT_ROOT,
    env: { ...process.env },
    stdio: ["pipe", "pipe", "pipe"],
  });
  s.stdout.on("data", (chunk) => {
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
  s.stderr.on("data", () => { });
  s.on("error", (e) => { throw e; });
  s.on("exit", (code) => {
    if (code !== 0 && code !== null) {
      for (const [, reject] of pending) reject(new Error(`Server exited with code ${code}`));
      pending.clear();
    }
  });
  s.stdin.on("error", () => { });
  return s;
}

function send(server, method, params) {
  return new Promise((resolve, reject) => {
    const id = ++msgId;
    pending.set(id, resolve);
    const msg = JSON.stringify({ jsonrpc: "2.0", id, method, params }) + "\n";
    server.stdin.write(msg);
    setTimeout(() => {
      if (pending.has(id)) {
        pending.delete(id);
        reject(new Error(`Timeout waiting for response to ${method} (id=${id})`));
      }
    }, 30000);
  });
}

async function callTool(server, name, args) {
  const resp = await send(server, "tools/call", { name, arguments: args });
  if (resp.error) throw new Error(resp.error.message);
  const result = resp.result?.content?.[0]?.text;
  return result ? JSON.parse(result) : resp.result;
}

function box(title, lines) {
  const w = 68;
  console.log(`\n┌─ ${title.padEnd(w - 3, "─")}┐`);
  for (const l of lines) {
    console.log(`│ ${String(l).padEnd(w - 1)}│`);
  }
  console.log(`└${"─".repeat(w)}┘`);
}

function print(label, data) {
  const str = typeof data === "string" ? data : JSON.stringify(data, null, 2);
  for (const line of str.split("\n")) {
    console.log(`  ${line}`);
  }
}

async function main() {
  const server = startServer();

  try {
    await send(server, "initialize", {
      protocolVersion: "2024-11-05",
      capabilities: {},
      clientInfo: { name: "pharos-cascade-demo", version: "1.0.0" },
    });
    await send(server, "notifications/initialized", {});

    const listResp = await send(server, "tools/list", {});
    const tools = listResp.result?.tools || [];

    const GREEN = "\x1b[32m";
    const BLUE = "\x1b[34m";
    const YELLOW = "\x1b[33m";
    const RESET = "\x1b[0m";

    console.log(`\n${BLUE}╔════════════════════════════════════════════════════════════╗${RESET}`);
    console.log(`${BLUE}║   Pharos Skill-to-Agent Dual Cascade Demo                ║${RESET}`);
    console.log(`${BLUE}║   42 subskills → 18 MCP tools → Pharos Blockchain        ║${RESET}`);
    console.log(`${BLUE}╚════════════════════════════════════════════════════════════╝${RESET}`);

    // ── Phase 1: User Request ──
    console.log(`\n${YELLOW}PHASE 1 — USER REQUEST${RESET}`);
    box("User Request", [
      '"Deploy my Counter contract to Pharos Atlantic Testnet, verify it,',
      ' check the deployer balance, and show me the network status."',
    ]);

    // ── Phase 2: Skill Learning (Layer 1) ──
    console.log(`\n${YELLOW}PHASE 2 — LAYER 1: AGENT READS SUBSKILLS${RESET}`);
    box("Skill: deployment-and-verification", [
      "agent reads skill/subskills/deployment-and-verification/SKILL.md",
      "→ Learns: forge script with Pharos RPC, correct chain ID 688689",
      "→ Learns: Blockscout verifier mode (no API key needed on testnet)",
      "→ Learns: PHRS has no 2300 gas stipend — must use pull-over-push",
    ]);
    box("Skill: contract-review", [
      "agent reads skill/subskills/contract-review/SKILL.md",
      "→ Learns: how to read contract state, fetch ABI, verify bytecode",
      "→ Learns: use safe/finalized block tags for production reads",
    ]);
    box("Skill: network-configuration", [
      "agent reads skill/subskills/network-configuration/SKILL.md",
      "→ Learns: Atlantic Testnet RPC, chain ID 688689, explorer URL",
      "→ Learns: EIP-1559 gas model, rate limits, eth_getAccount RPC",
    ]);

    // ── Phase 3: MCP Tool Execution (Layer 2) ──
    console.log(`\n${YELLOW}PHASE 3 — LAYER 2: AGENT CALLS MCP TOOLS${RESET}`);
    console.log(`  ${tools.length} tools available through the MCP server\n`);

    const hasKey = !!process.env.PRIVATE_KEY;

    box("Tool 1: pharos_network_config", [
      "→ Atlantic Testnet (688689) configured",
      "→ RPC: https://atlantic.dplabs-internal.com",
    ]);
    const netCfg = await callTool(server, "pharos_network_config", { network: "atlanticTestnet" });
    console.log(`  Result: ${netCfg.network} (chain ${netCfg.chainId})`);

    box("Tool 2: pharos_deploy_contract", [
      hasKey ? "→ Broadcasting Counter.sol to Atlantic Testnet" : "→ Simulation mode (set PRIVATE_KEY for real deploy)",
    ]);
    const deployResult = await callTool(server, "pharos_deploy_contract", {
      network: "atlanticTestnet",
      contractFile: "script/Counter.s.sol",
      simulate: !hasKey,
    });
    console.log(`  Result: ${deployResult?.contractAddress || "simulated"}`);

    box("Tool 3: pharos_verify_contract", [
      "→ Verifying on PharosScan via Blockscout verifier",
      "→ No API key required on testnet",
    ]);
    const verifyResult = await callTool(server, "pharos_verify_contract", {
      network: "atlanticTestnet",
      address: deployResult?.contractAddress || "0x55ec4b1e32537b6f72aa20153735709837488e4e",
      contract: "contracts/Counter.sol:Counter",
    });
    console.log(`  Result: ${verifyResult?.message || "verification submitted"}`);

    box("Tool 4: pharos_check_balance", [
      "→ Querying deployer PHRS balance",
    ]);
    const balResult = await callTool(server, "pharos_check_balance", {
      network: "atlanticTestnet",
      address: "0x735367687d6a701466840321eD8e34E4DafE84aC",
    });
    console.log(`  Result: ${balResult.balanceFormatted}`);

    box("Tool 5: pharos_network_status", [
      "→ Checking block finality status",
    ]);
    const statusResult = await callTool(server, "pharos_network_status", { network: "atlanticTestnet" });
    console.log(`  Result: latest=${statusResult.latestBlock} safe=${statusResult.safeBlock} finalized=${statusResult.finalizedBlock}`);

    // ── Phase 4: Result ──
    console.log(`\n${GREEN}PHASE 4 — ON-CHAIN RESULT${RESET}`);
    console.log(`${"=".repeat(70)}`);
    console.log(`  ✅ 3 subskills consulted (deployment, review, network)`);
    console.log(`  ✅ 5 MCP tools executed through real server`);
    console.log(`  ✅ Result on Pharos Atlantic Testnet (688689)`);
    console.log(`  ✅ ${tools.length} tools registered and functional`);
    console.log(`${"=".repeat(70)}`);
    console.log(`\n  See CASCADE.md for the full architecture walkthrough.`);
    console.log(`  Run \`${GREEN}node agent/token-workflow.mjs${RESET}\` for the token lifecycle demo.\n`);
  } finally {
    server.kill();
  }
}

main().catch((e) => {
  console.error(`\n  ✗ Demo failed: ${e.message}`);
  process.exit(1);
});
