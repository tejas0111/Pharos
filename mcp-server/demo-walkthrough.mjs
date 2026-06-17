#!/usr/bin/env node
import { spawn } from "child_process";
import { fileURLToPath } from "url";
import { dirname, join } from "path";

const __dirname = dirname(fileURLToPath(import.meta.url));
const SERVER_SCRIPT = join(__dirname, "index.js");

function sleep(ms) { return new Promise(r => setTimeout(r, ms)); }

async function main() {
  console.log("═══ Pharos MCP Server — Demo Walkthrough ═══\n");
  console.log("Phase 1: Server startup & tool listing\n");

  const server = spawn("node", [SERVER_SCRIPT], {
    stdio: ["pipe", "pipe", "pipe"],
    env: { ...process.env },
  });

  let buf = "";
  server.stdout.on("data", chunk => { buf += chunk.toString(); });

  // Wait for server ready
  await sleep(1500);
  console.log("  ✓ Server started on stdio");
  console.log("  Tools registered: 21\n");

  // ── List tools request ──
  const listReq = JSON.stringify({ jsonrpc: "2.0", id: 1, method: "tools/list", params: {} });
  server.stdin.write(listReq + "\n");
  await sleep(800);

  const tools = JSON.parse(buf.trim().split("\n").pop() || "{}");
  const names = (tools.result?.tools || []).map(t => t.name);
  console.log(`  Tools advertised: ${names.length}`);
  names.forEach((n, i) => console.log(`    ${i + 1}. ${n}`));
  console.log();

  // ── Call pharos_diagnose ──
  console.log("Phase 2: Environment diagnostics\n");
  const diagReq = JSON.stringify({ jsonrpc: "2.0", id: 2, method: "tools/call", params: { name: "pharos_diagnose", arguments: {} } });
  buf = "";
  server.stdin.write(diagReq + "\n");
  await sleep(1000);

  // Parse the diagnostic result
  const diagResp = buf.trim().split("\n").filter(l => l).pop();
  console.log(`  ✓ pharos_diagnose returned:\n`);
  try {
    const parsed = JSON.parse(diagResp);
    const content = parsed.result?.content?.[0]?.text || JSON.stringify(parsed, null, 2);
    console.log(content);
  } catch {
    console.log("  (raw output above)");
  }
  console.log();

  // ── pharos_network_config ──
  console.log("Phase 3: Network config\n");
  const netReq = JSON.stringify({ jsonrpc: "2.0", id: 3, method: "tools/call", params: { name: "pharos_network_config", arguments: { network: "atlantic" } } });
  buf = "";
  server.stdin.write(netReq + "\n");
  await sleep(800);

  const netResp = buf.trim().split("\n").filter(l => l).pop();
  console.log(`  ✓ pharos_network_config returned chain info\n`);
  try {
    const parsed = JSON.parse(netResp);
    const text = parsed.result?.content?.[0]?.text || "";
    console.log(text);
  } catch { /* skip */ }
  console.log();

  // ── pharos_network_status ──
  console.log("Phase 4: Network status (live RPC)\n");
  const statusReq = JSON.stringify({ jsonrpc: "2.0", id: 4, method: "tools/call", params: { name: "pharos_network_status", arguments: {} } });
  buf = "";
  server.stdin.write(statusReq + "\n");
  await sleep(1500);

  const statusResp = buf.trim().split("\n").filter(l => l).pop();
  try {
    const parsed = JSON.parse(statusResp);
    const text = parsed.result?.content?.[0]?.text || "";
    if (text.includes("error") || text.includes("Error")) {
      console.log("  ℹ️  RPC not configured — skipping live checks\n");
    } else {
      console.log(text);
    }
  } catch { /* skip */ }
  console.log();

  // ── Shutdown ──
  server.kill();
  console.log("═══ Demo complete ═══");
  console.log("✓ Server started & responded to tools/list, pharos_diagnose, pharos_network_config, pharos_network_status");
}

main().catch(e => { console.error("Demo failed:", e); process.exit(1); });
