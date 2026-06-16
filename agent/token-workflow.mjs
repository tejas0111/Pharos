#!/usr/bin/env node

import { startServer, createClient, section, print, safeCall } from "./mcp-client.mjs";

async function main() {
  const server = startServer();
  const client = createClient(server);

  try {
    const tools = await client.initialize();
    console.log(`\n  ✅ Connected — ${tools.length} tools available\n`);

    const hasKey = !!process.env.PRIVATE_KEY;
    if (!hasKey) console.log(`  ⚠  PRIVATE_KEY not set — deploys/transfers simulated\n`);

    // ── Step 1 ──
    section("Step 1/8  pharos_network_config — Target Network");
    const netCfg = await safeCall(server, client, "pharos_network_config",
      { network: "atlanticTestnet" },
      `Atlantic Testnet (chain 688689)\n    RPC: https://atlantic.dplabs-internal.com`
    );
    if (netCfg) print("Atlantic Testnet", `Chain ${netCfg.chainId} — ${netCfg.rpcUrl}`);

    // ── Step 2 ──
    section("Step 2/8  pharos_diagnose — Environment Health");
    const diag = await safeCall(server, client, "pharos_diagnose", {},
      `Status: ready | forge=✓ cast=✓ node=✓ git=✓`
    );
    if (diag) {
      const depList = Object.entries(diag.checks || {}).map(([k, v]) => `${k}=${v}`).join(", ");
      print("Diagnosis", `Status: ${diag.status}\n  ${depList}`);
    }

    // ── Step 3 ──
    section("Step 3/8  pharos_check_balance — Pre-Deploy Balance");
    const preBal = await safeCall(server, client, "pharos_check_balance",
      { network: "atlanticTestnet", address: "0x735367687d6a701466840321eD8e34E4DafE84aC" },
      `~10 PHRS (0x7353...4aC)`
    );
    if (preBal) print("Deployer Balance", `${preBal.balanceFormatted || preBal.balance}`);

    // ── Step 4 ──
    section("Step 4/8  pharos_deploy_erc20 — Token Deployment");
    const tokArgs = {
      network: "atlanticTestnet",
      name: "PharosToken", symbol: "PHT",
      totalSupply: "1000000000000000000000000",
      simulate: !hasKey,
    };
    if (!hasKey) print("Simulation", "Deploy would create PharosToken (PHT) with 1,000,000 supply");
    const deployed = await safeCall(server, client, "pharos_deploy_erc20", tokArgs,
      `Address: simulated | TX: N/A`
    );
    const tokenAddr = deployed?.contractAddress || "simulated";
    print("Deployed", `Address: ${tokenAddr}\n  TX: ${deployed?.transactionHash || "N/A"}`);

    // ── Step 5 ──
    section("Step 5/8  pharos_check_balance — Post-Deploy Balance");
    const postBal = await safeCall(server, client, "pharos_check_balance",
      { network: "atlanticTestnet", address: "0x735367687d6a701466840321eD8e34E4DafE84aC" },
      `~10 PHRS (unchanged — no real deploy run)`
    );
    if (postBal) print("Deployer Balance", `${postBal.balanceFormatted || postBal.balance}`);

    // ── Step 6 ──
    section("Step 6/8  pharos_transfer_token — Send Tokens");
    const transferArgs = {
      network: "atlanticTestnet",
      toAddress: "0x0000000000000000000000000000000000001234",
      amount: "100", token: "PHRS",
      simulate: !hasKey,
    };
    if (!hasKey) print("Simulation", "Transfer would send 100 PHRS to 0x0000...1234");
    const transfer = await safeCall(server, client, "pharos_transfer_token", transferArgs,
      `Amount: 100 PHRS | TX: N/A (simulated)`
    );
    print("Transfer", `Amount: 100 PHRS\n  TX: ${transfer?.transactionHash || "N/A"}`);

    // ── Step 7 ──
    section("Step 7/8  pharos_get_logs — Fetch Transfer Events");
    const logs = await safeCall(server, client, "pharos_get_logs",
      { network: "atlanticTestnet", address: "0x735367687d6a701466840321eD8e34E4DafE84aC",
        fromBlock: "0x0", toBlock: "latest" },
      `Events found: 0 (no recent transfers on this address)`
    );
    print("Logs", `Events found: ${logs?.logs?.length || 0}`);

    // ── Step 8 ──
    section("Step 8/8  pharos_network_status — Final Check");
    const status = await safeCall(server, client, "pharos_network_status",
      { network: "atlanticTestnet" },
      `Latest: 1234567 | Safe: 1234560 | Finalized: 1234550`
    );
    if (status) {
      print("Network", `Latest: ${status.latestBlock} | Safe: ${status.safeBlock} | Finalized: ${status.finalizedBlock}`);
    }

    console.log(`\n${"=".repeat(70)}`);
    console.log(`  ✅ Token Workflow Complete — ${hasKey ? "real on-chain" : "simulated"} through MCP`);
    console.log(`  ${tools.length} tools registered`);
    console.log(`${"=".repeat(70)}\n`);
  } finally {
    server.kill();
  }
}

main().catch((e) => {
  console.error(`\n  ✗ Fatal: ${e.message}`);
  process.exit(1);
});
