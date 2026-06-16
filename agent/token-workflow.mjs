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

function section(label) {
  console.log(`\n${"=".repeat(70)}`);
  console.log(`  ${label}`);
  console.log(`${"=".repeat(70)}`);
}

function print(label, data) {
  console.log(`\n  ◆ ${label}`);
  const str = typeof data === "string" ? data : JSON.stringify(data, null, 2);
  const lines = str.split("\n").map(l => `    ${l}`);
  console.log(lines.join("\n"));
}

async function main() {
  const server = startServer();

  try {
    await send(server, "initialize", {
      protocolVersion: "2024-11-05",
      capabilities: {},
      clientInfo: { name: "pharos-token-workflow", version: "1.0.0" },
    });
    await send(server, "notifications/initialized", {});

    const listResp = await send(server, "tools/list", {});
    const tools = listResp.result?.tools || [];
    console.log(`\n  ✅ Connected — ${tools.length} tools available\n`);

    const hasKey = !!process.env.PRIVATE_KEY;
    if (!hasKey) console.log("  ⚠  PRIVATE_KEY not set — deploys/transfers will be simulated\n");

    // ── Step 1: Network config ──
    section("Step 1/8  pharos_network_config — Target Network");
    const netCfg = await callTool(server, "pharos_network_config", { network: "atlanticTestnet" });
    print("Atlantic Testnet", `Chain ${netCfg.chainId} — ${netCfg.rpcUrl}`);

    // ── Step 2: Diagnose ──
    section("Step 2/8  pharos_diagnose — Environment Health");
    const diag = await callTool(server, "pharos_diagnose", {});
    const depList = Object.entries(diag.checks || {}).map(([k, v]) => `${k}=${v}`).join(", ");
    print("Diagnosis", `Status: ${diag.status}\n  ${depList}`);

    // ── Step 3: Check pre-deploy balance ──
    section("Step 3/8  pharos_check_balance — Pre-Deploy Balance");
    const preBal = await callTool(server, "pharos_check_balance", {
      network: "atlanticTestnet",
      address: "0x735367687d6a701466840321eD8e34E4DafE84aC",
    });
    print("Deployer Balance", `${preBal.balanceFormatted}`);

    // ── Step 4: Deploy ERC-20 ──
    section("Step 4/8  pharos_deploy_erc20 — Token Deployment");
    const tokArgs = {
      network: "atlanticTestnet",
      name: "PharosToken",
      symbol: "PHT",
      totalSupply: "1000000000000000000000000",
      simulate: !hasKey,
    };
    if (!hasKey) print("Simulation", "Deploy would create PharosToken (PHT) with 1,000,000 supply");
    const deployed = await callTool(server, "pharos_deploy_erc20", tokArgs);
    const tokenAddr = deployed?.contractAddress || "simulated";
    const deployTx = deployed?.transactionHash || "N/A";
    print("Deployed", `Address: ${tokenAddr}\n  TX: ${deployTx}`);

    // ── Step 5: Check post-deploy balance ──
    section("Step 5/8  pharos_check_balance — Post-Deploy Balance");
    const postBal = await callTool(server, "pharos_check_balance", {
      network: "atlanticTestnet",
      address: "0x735367687d6a701466840321eD8e34E4DafE84aC",
    });
    print("Deployer Balance", `${postBal.balanceFormatted}`);

    // ── Step 6: Transfer tokens ──
    section("Step 6/8  pharos_transfer_token — Send Tokens");
    const transferArgs = {
      network: "atlanticTestnet",
      toAddress: "0x0000000000000000000000000000000000001234",
      amount: "100",
      token: "PHRS",
      simulate: !hasKey,
    };
    if (!hasKey) print("Simulation", "Transfer would send 100 PHRS to 0x0000...1234");
    const transfer = await callTool(server, "pharos_transfer_token", transferArgs);
    print("Transfer", `Amount: 100 PHRS\n  TX: ${transfer?.transactionHash || "N/A"}`);

    // ── Step 7: Event logs ──
    section("Step 7/8  pharos_get_logs — Fetch Transfer Events");
    const logs = await callTool(server, "pharos_get_logs", {
      network: "atlanticTestnet",
      address: "0x735367687d6a701466840321eD8e34E4DafE84aC",
      fromBlock: "0x0",
      toBlock: "latest",
    });
    print("Logs", `Events found: ${logs?.logs?.length || 0}`);

    // ── Step 8: Network status ──
    section("Step 8/8  pharos_network_status — Final Check");
    const status = await callTool(server, "pharos_network_status", { network: "atlanticTestnet" });
    print("Network", `Latest: ${status.latestBlock} | Safe: ${status.safeBlock} | Finalized: ${status.finalizedBlock}`);

    console.log(`\n${"=".repeat(70)}`);
    console.log(`  Token Workflow Complete — ${hasKey ? "real on-chain" : "simulated"} through MCP`);
    console.log(`  ${tools.length} tools registered`);
    console.log(`${"=".repeat(70)}\n`);
  } finally {
    server.kill();
  }
}

main().catch((e) => {
  console.error(`\n  ✗ Demo failed: ${e.message}`);
  process.exit(1);
});
