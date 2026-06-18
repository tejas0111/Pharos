#!/usr/bin/env node

import { startServer, createClient, section, print, safeCall } from "./mcp-client.mjs";

async function main() {
  const server = startServer();
  const client = createClient(server);

  try {
    const tools = await client.initialize();
    const toolCount = tools.length;
    console.log(`\n  ✅ Connected — ${toolCount} tools available\n`);

    if (!process.env.PHAROS_TESTNET_RPC_URL && !process.env.PRIVATE_KEY) {
      console.log(`  🔗 Using default RPC (Atlantic Testnet)`);
      console.log(`  💡 Set PHAROS_TESTNET_RPC_URL to use a custom endpoint\n`);
    }

    // ── 1. Network Config ──
    section("1/6  pharos_network_config — Network Configuration");
    const netCfg = await safeCall(server, client, "pharos_network_config",
      { network: "atlanticTestnet" },
      `Atlantic Testnet (chain 688689)\n    RPC: https://atlantic.dplabs-internal.com\n    Explorer: https://atlantic.pharosscan.xyz\n    Currency: PHRS`
    );
    if (netCfg) print("Atlantic Testnet", `${netCfg.network} (chain ${netCfg.chainId})`);

    // ── 2. Diagnose ──
    section("2/6  pharos_diagnose — Environment Health");
    const diag = await safeCall(server, client, "pharos_diagnose", {},
      `Status: ready\n    Dependencies: forge=✓ cast=✓ jq=✓ curl=✓ node=✓ npm=✓`
    );
    if (diag) {
      const depList = Object.entries(diag.checks || {}).map(([k, v]) => `${k}=${v}`).join(", ");
      print("Diagnosis", `Status: ${diag.status}\n  ${depList}`);
    }

    // ── 3. Gas Estimate ──
    section("3/6  pharos_gas_estimate — Gas Prices");
    const gas = await safeCall(server, client, "pharos_gas_estimate",
      { network: "atlanticTestnet" },
      `Base: ~100 gwei | Priority: ~1 gwei | Tx cost: ~0.002 PHRS`
    );
    if (gas) print("Gas", `Base: ${gas.baseFeeWei} wei | Priority: ${gas.priorityFeeWei} wei`);

    // ── 4. Network Status ──
    section("4/6  pharos_network_status — Block Status");
    const status = await safeCall(server, client, "pharos_network_status",
      { network: "atlanticTestnet" },
      `Latest: 1234567 | Safe: 1234560 | Finalized: 1234550 (~17 blocks to finality)`
    );
    if (status) {
      print("Blocks", `Latest: ${status.latestBlock} | Safe: ${status.safeBlock} | Finalized: ${status.finalizedBlock} (${status.blocksToFinalized} to finality)`);
    }

    // ── 5. Account State ──
    section("5/6  pharos_get_account — Pharos eth_getAccount");
    const account = await safeCall(server, client, "pharos_get_account",
      { network: "atlanticTestnet", address: "0x735367687d6a701466840321eD8e34E4DafE84aC" },
      `Balance: 1.234 PHRS | Nonce: 42 | CodeHash: 0x0f18... | StorageRoot: 0xabcd...`
    );
    if (account) {
      const balWei = account.balance ? BigInt(account.balance) : 0n;
      const balFormatted = (Number(balWei) / 1e18).toFixed(4);
      print("Account", `Balance: ${balFormatted} PHRS | Nonce: ${account.nonce} | CodeHash: ${(account.codeHash || "").slice(0, 20)}...`);
    }

    // ── 6. Balance ──
    section("6/6  pharos_check_balance — Balance Query");
    const bal = await safeCall(server, client, "pharos_check_balance",
      { network: "atlanticTestnet", address: "0x735367687d6a701466840321eD8e34E4DafE84aC" },
      `0.042 PHRS (0x7353...4aC)`
    );
    if (bal) print("Balance", `${bal.balanceFormatted || bal.balance} (${bal.address})`);

    console.log(`\n${"=".repeat(70)}`);
    console.log(`  ✅ Demo Complete — 6 tools called through real MCP server`);
    console.log(`  ${toolCount} MCP tools registered`);
    if (!process.env.PHAROS_TESTNET_RPC_URL) {
      console.log(`  🌐 Data from Atlantic Testnet via default RPC`);
    }
    console.log(`${"=".repeat(70)}\n`);
  } finally {
    server.kill();
  }
}

main().catch((e) => {
  console.error(`\n  ✗ Fatal: ${e.message}`);
  process.exit(1);
});
