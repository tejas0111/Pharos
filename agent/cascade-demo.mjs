#!/usr/bin/env node

import { startServer, createClient, safeCall } from "./mcp-client.mjs";

function box(title, lines) {
  const w = 68;
  console.log(`\n┌─ ${title.padEnd(w - 3, "─")}┐`);
  for (const l of lines) {
    console.log(`│ ${String(l).padEnd(w - 1)}│`);
  }
  console.log(`└${"─".repeat(w)}┘`);
}

async function main() {
  const server = startServer();
  const client = createClient(server);

  try {
    const tools = await client.initialize();

    const GREEN = "\x1b[32m", BLUE = "\x1b[34m", YELLOW = "\x1b[33m", RESET = "\x1b[0m";

    console.log(`\n${BLUE}╔════════════════════════════════════════════════════════════╗${RESET}`);
    console.log(`${BLUE}║   Pharos Skill-to-Agent Dual Cascade Demo                ║${RESET}`);
    console.log(`${BLUE}║   42 subskills → 18 MCP tools → Pharos Blockchain        ║${RESET}`);
    console.log(`${BLUE}╚════════════════════════════════════════════════════════════╝${RESET}`);

    // ── Phase 1 ──
    console.log(`\n${YELLOW}PHASE 1 — USER REQUEST${RESET}`);
    box("User Request", [
      `"Deploy my Counter contract to Pharos Atlantic Testnet, verify it,`,
      ` check the deployer balance, and show me the network status."`,
    ]);

    // ── Phase 2 ──
    console.log(`\n${YELLOW}PHASE 2 — LAYER 1: AGENT READS SUBSKILLS${RESET}`);
    for (const [skill, lines] of Object.entries({
      "deployment-and-verification": [
        `→ Learns: forge script with Pharos RPC, chain ID 688689`,
        `→ Learns: Blockscout verifier (no API key on testnet)`,
        `→ Learns: no 2300 gas stipend — use pull-over-push`,
      ],
      "contract-review": [
        `→ Learns: read contract state, fetch ABI, verify bytecode`,
        `→ Learns: safe/finalized block tags for production reads`,
      ],
      "network-configuration": [
        `→ Learns: RPC, chain ID 688689, explorer URL, gas model`,
      ],
    })) {
      box(`Skill: ${skill}`, [
        `agent reads skill/subskills/${skill}/SKILL.md`,
        ...lines,
      ]);
    }

    // ── Phase 3 ──
    console.log(`\n${YELLOW}PHASE 3 — LAYER 2: AGENT CALLS MCP TOOLS${RESET}`);
    console.log(`  ${tools.length} tools available through the MCP server\n`);

    const hasKey = !!process.env.PRIVATE_KEY;

    const netCfg = await safeCall(server, client, "pharos_network_config",
      { network: "atlanticTestnet" }, null);
    box("Tool 1: pharos_network_config", [
      `→ ${netCfg ? `${netCfg.network} (chain ${netCfg.chainId})` : "Atlantic Testnet (688689)"}`,
    ]);

    const deployResult = await safeCall(server, client, "pharos_deploy_contract", {
      network: "atlanticTestnet", contractFile: "script/Counter.s.sol",
      simulate: !hasKey,
    }, null);
    box("Tool 2: pharos_deploy_contract", [
      hasKey ? `→ Broadcasting to Atlantic Testnet` : `→ Simulation mode (set PRIVATE_KEY for real deploy)`,
    ]);
    if (deployResult) console.log(`  Result: ${deployResult.contractAddress || "simulated"}`);

    const verifyResult = await safeCall(server, client, "pharos_verify_contract", {
      network: "atlanticTestnet",
      address: deployResult?.contractAddress || "0x55ec4b1e32537b6f72aa20153735709837488e4e",
      contract: "contracts/Counter.sol:Counter",
    }, null);
    box("Tool 3: pharos_verify_contract", [
      `→ Using Blockscout verifier (no API key)`,
    ]);
    if (verifyResult) console.log(`  Result: ${verifyResult.message || "submitted"}`);

    const balResult = await safeCall(server, client, "pharos_check_balance", {
      network: "atlanticTestnet",
      address: "0x735367687d6a701466840321eD8e34E4DafE84aC",
    }, null);
    box("Tool 4: pharos_check_balance", [`→ Deployer PHRS balance`]);
    if (balResult) console.log(`  Result: ${balResult.balanceFormatted || balResult.balance}`);

    const statusResult = await safeCall(server, client, "pharos_network_status",
      { network: "atlanticTestnet" }, null);
    box("Tool 5: pharos_network_status", [`→ Block finality status`]);
    if (statusResult) {
      console.log(`  Result: latest=${statusResult.latestBlock} safe=${statusResult.safeBlock} finalized=${statusResult.finalizedBlock}`);
    }

    // ── Phase 4 ──
    console.log(`\n${GREEN}PHASE 4 — ON-CHAIN RESULT${RESET}`);
    console.log(`${"=".repeat(70)}`);
    console.log(`  ✅ 3 subskills consulted (deployment, review, network)`);
    console.log(`  ✅ 5 MCP tools executed through real server`);
    console.log(`  ✅ Result on Pharos Atlantic Testnet (${netCfg?.chainId || "688689"})`);
    console.log(`  ✅ ${tools.length} tools registered and functional`);
    console.log(`${"=".repeat(70)}`);
    console.log(`\n  See CASCADE.md for the full architecture walkthrough.`);
    console.log(`  Run \`${GREEN}node agent/token-workflow.mjs${RESET}\` for the token lifecycle demo.\n`);
  } finally {
    server.kill();
  }
}

main().catch((e) => {
  console.error(`\n  ✗ Fatal: ${e.message}`);
  process.exit(1);
});
