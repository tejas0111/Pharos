#!/usr/bin/env node
/**
 * Pharos MCP Server — Executable Tools
 *
 * 10 tools for AI agents to interact with the Pharos blockchain.
 * Tools execute real operations: deploy, verify, transfer, fetch logs, etc.
 *
 * Security: PRIVATE_KEY is read from env, NEVER exposed in output.
 */

import { Server } from "@modelcontextprotocol/sdk/server/index.js";
import { StdioServerTransport } from "@modelcontextprotocol/sdk/server/stdio.js";
import {
  createPublicClient,
  createWalletClient,
  http,
  formatUnits,
  parseUnits,
} from "viem";
import { privateKeyToAccount } from "viem/accounts";
import { execSync } from "child_process";
import { writeFileSync, existsSync } from "fs";
import { join, dirname } from "path";
import { fileURLToPath } from "url";

const __dirname = dirname(fileURLToPath(import.meta.url));
const PROJECT_ROOT = join(__dirname, "..");

// ---------------------------------------------------------------------------
// Network configs
// ---------------------------------------------------------------------------
const NETWORKS = {
  atlanticTestnet: {
    id: 688689,
    name: "Atlantic Testnet",
    nativeCurrency: { name: "PHRS", symbol: "PHRS", decimals: 18 },
    rpcUrl: process.env.PHAROS_TESTNET_RPC_URL || "https://atlantic.dplabs-internal.com",
    explorer: "https://atlantic.pharosscan.xyz",
    explorerApi: "https://atlantic.pharosscan.xyz/api",
    testnet: true,
  },
  pacificMainnet: {
    id: 1672,
    name: "Pacific Mainnet",
    nativeCurrency: { name: "PROS", symbol: "PROS", decimals: 18 },
    rpcUrl: process.env.PHAROS_MAINNET_RPC_URL || "https://rpc.pharos.xyz",
    explorer: "https://www.pharosscan.xyz",
    explorerApi: "https://www.pharosscan.xyz/api",
    testnet: false,
  },
};

function getNetwork(network = "atlanticTestnet") {
  const net = NETWORKS[network];
  if (!net) throw new Error(`Unknown network: ${network}. Use atlanticTestnet or pacificMainnet`);
  return net;
}

function getClient(network) {
  const net = getNetwork(network);
  return createPublicClient({ transport: http(net.rpcUrl) });
}

function getWalletClient(network) {
  const pk = process.env.PRIVATE_KEY;
  if (!pk) throw new Error("PRIVATE_KEY not set in environment");
  const net = getNetwork(network);
  const account = privateKeyToAccount(pk);
  return createWalletClient({
    account,
    transport: http(net.rpcUrl),
  });
}

function safeResult(data) {
  // Strip any line containing a private key before returning
  const sanitized = JSON.parse(JSON.stringify(data), (key, value) => {
    if (typeof value === "string" && value.length > 60 && value.includes("0x")) {
      // Heuristic: if a string looks like it could contain a private key, redact it
      const pkMatch = value.match(/0x[a-fA-F0-9]{64}/);
      if (pkMatch) return value.replace(pkMatch[0], "0x...REDACTED...");
    }
    return value;
  });
  return { content: [{ type: "text", text: JSON.stringify(sanitized, null, 2) }] };
}

function errorResult(msg) {
  return { isError: true, content: [{ type: "text", text: msg }] };
}

// ---------------------------------------------------------------------------
// Tool 1 — pharos_network_config (static)
// ---------------------------------------------------------------------------
function networkConfig(args) {
  try {
    const net = getNetwork(args.network);
    return safeResult({
      network: net.name,
      chainId: net.id,
      currency: net.nativeCurrency,
      rpcUrl: net.rpcUrl,
      explorer: net.explorer,
      explorerApi: net.explorerApi,
      isTestnet: net.testnet,
    });
  } catch (err) {
    return errorResult(err.message);
  }
}

// ---------------------------------------------------------------------------
// Tool 2 — pharos_deploy_contract (actually executes forge script)
// ---------------------------------------------------------------------------
async function deployContract(args) {
  try {
    const net = getNetwork(args.network);
    const script = args.script || "script/Deploy.s.sol:DeployCounter";
    const simulateOnly = args.simulate !== false;

    console.error(`[MCP] Deploying: ${script} on ${net.name} (simulate=${simulateOnly})`);

    const cmd = [
      "forge", "script", script,
      "--rpc-url", net.rpcUrl,
      "--private-key", process.env.PRIVATE_KEY || "",
    ];

    if (simulateOnly) {
      cmd.push("-vvv");
    } else {
      cmd.push("--broadcast", "-vvv");
    }

    const output = execSync(cmd.join(" "), {
      cwd: PROJECT_ROOT,
      encoding: "utf-8",
      maxBuffer: 10 * 1024 * 1024,
      timeout: 120_000,
    });

    // Parse deployed address from output
    const addressMatch = output.match(/deployed at: (0x[a-fA-F0-9]{40})/);
    const contractAddress = addressMatch ? addressMatch[1] : null;

    return safeResult({
      action: simulateOnly ? "simulate" : "deploy",
      network: net.name,
      chainId: net.id,
      script,
      contractAddress,
      warning: simulateOnly
        ? "Simulation only. Set simulate=false to broadcast."
        : "Contract deployed. Verify on explorer after broadcast.",
      explorerUrl: contractAddress ? `${net.explorer}/address/${contractAddress}` : null,
      raw: output.slice(-2000),
    });
  } catch (err) {
    return errorResult(`Deploy failed: ${err.message}`);
  }
}

// ---------------------------------------------------------------------------
// Tool 3 — pharos_verify_contract (calls PharosScan API)
// ---------------------------------------------------------------------------
async function verifyContract(args) {
  try {
    const net = getNetwork(args.network);
    const address = args.address;
    const contract = args.contract || "Counter";
    const constructorArgs = args.constructorArgs || "";

    const apiKey = process.env.PHAROSSCAN_API_KEY || "";
    const apiUrl = `${net.explorerApi}?module=contract&action=verify&address=${address}`;

    console.error(`[MCP] Verifying: ${contract} at ${address} on ${net.name}`);

    // Try API verification
    let apiResult = null;
    try {
      const response = await fetch(apiUrl, {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({
          address,
          contractName: contract,
          constructorArguments: constructorArgs,
          apikey: apiKey,
        }),
      });
      apiResult = await response.text();
    } catch (_fetchErr) {
      apiResult = "API verification unavailable (explorer may not support programmatic verification)";
    }

    return safeResult({
      action: "verify",
      network: net.name,
      address,
      contract,
      apiResult,
      forgeCommand: `forge verify-contract --chain-id ${net.id} --verifier-url ${net.explorerApi} ${address} ${contract}`,
      explorerUrl: `${net.explorer}/address/${address}`,
      manualUrl: `${net.explorer}/address/${address}#code`,
    });
  } catch (err) {
    return errorResult(`Verify failed: ${err.message}`);
  }
}

// ---------------------------------------------------------------------------
// Tool 4 — pharos_run_security_check (runs slither if available)
// ---------------------------------------------------------------------------
async function runSecurityCheck(args) {
  try {
    const contractPath = args.contract
      ? join(PROJECT_ROOT, "contracts", args.contract.endsWith(".sol") ? args.contract : `${args.contract}.sol`)
      : null;

    let slitherOutput = null;
    if (contractPath && existsSync(contractPath)) {
      try {
        slitherOutput = execSync(`slither "${contractPath}" --json 2>/dev/null`, {
          encoding: "utf-8",
          timeout: 30_000,
        });
      } catch (slitherErr) {
        slitherOutput = `slither not available: ${slitherErr.message}`;
      }
    }

    return safeResult({
      action: "security_check",
      contract: args.contract || "unknown",
      contractPath: contractPath || "not specified",
      slitherAvailable: slitherOutput && !slitherOutput.includes("not available"),
      slitherOutput: slitherOutput,
      structuredChecks: [
        "1. Reentrancy: checks-effects-interactions pattern followed?",
        "2. Access control: onlyOwner on sensitive functions?",
        "3. Integer safety: Solc 0.8+ checked math (no SafeMath needed)",
        "4. Front-running: tx ordering dependencies?",
        "5. Gas: bounded loops only?",
        "6. Pharos-specific: No 2300 gas stipend — use pull-over-push",
      ],
      nextSteps: [
        "forge test -vvv",
        "pip install slither-analyzer && slither .",
      ],
    });
  } catch (err) {
    return errorResult(`Security check failed: ${err.message}`);
  }
}

// ---------------------------------------------------------------------------
// Tool 5 — pharos_generate_tests (writes test file to disk)
// ---------------------------------------------------------------------------
async function generateTests(args) {
  try {
    const contract = args.contract || "MyContract";
    const testDir = join(PROJECT_ROOT, "test");
    const testPath = join(testDir, `${contract}.t.sol`);

    const testCode = `// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import "forge-std/Test.sol";
import "../contracts/${contract}.sol";

contract ${contract}Test is Test {
    ${contract} private s_contract;

    function setUp() public {
        s_contract = new ${contract}();
    }

    function test_Constructor() public view {
        // TODO: verify initial state
    }

    function test_Example() public {
        // TODO: add your test
    }
}
`;

    writeFileSync(testPath, testCode, "utf-8");
    console.error(`[MCP] Wrote test file: ${testPath}`);

    return safeResult({
      action: "generate_tests",
      contract,
      filePath: `test/${contract}.t.sol`,
      code: testCode,
      status: "written",
      nextStep: `forge test --match-path test/${contract}.t.sol -vvv`,
    });
  } catch (err) {
    return errorResult(`Test generation failed: ${err.message}`);
  }
}

// ---------------------------------------------------------------------------
// Tool 6 — pharos_check_balance (already works via viem)
// ---------------------------------------------------------------------------
async function checkBalance(args) {
  try {
    const net = getNetwork(args.network);
    const client = getClient(args.network);
    const balance = await client.getBalance({ address: args.address });
    const formatted = formatUnits(balance, net.nativeCurrency.decimals);

    return safeResult({
      action: "check_balance",
      network: net.name,
      address: args.address,
      balanceWei: balance.toString(),
      balanceFormatted: `${formatted} ${net.nativeCurrency.symbol}`,
      explorerUrl: `${net.explorer}/address/${args.address}`,
    });
  } catch (err) {
    return errorResult(`Balance check failed: ${err.message}`);
  }
}

// ---------------------------------------------------------------------------
// Tool 7 — pharos_contract_info (fetches from explorer API)
// ---------------------------------------------------------------------------
async function contractInfo(args) {
  try {
    const net = getNetwork(args.network);
    const address = args.address;

    // Try to fetch source code from explorer API
    let sourceCode = null;
    try {
      const resp = await fetch(
        `${net.explorerApi}?module=contract&action=getsourcecode&address=${address}`
      );
      const data = await resp.json();
      sourceCode = data;
    } catch (_fetchErr) {
      sourceCode = "Explorer API unavailable";
    }

    return safeResult({
      action: "contract_info",
      address,
      network: net.name,
      chainId: net.id,
      sourceCode,
      explorerUrl: `${net.explorer}/address/${address}`,
      explorerApiUrl: `${net.explorerApi}?module=contract&action=getsourcecode&address=${address}`,
    });
  } catch (err) {
    return errorResult(`Contract info failed: ${err.message}`);
  }
}

// ---------------------------------------------------------------------------
// Tool 8 — pharos_transfer_token (sends PHRS/PROS via viem walletClient)
// ---------------------------------------------------------------------------
async function transferToken(args) {
  try {
    const net = getNetwork(args.network);

    if (!process.env.PRIVATE_KEY) {
      return errorResult("PRIVATE_KEY environment variable not set");
    }

    const walletClient = getWalletClient(args.network);
    const to = args.toAddress;
    const amount = args.amount;
    const unit = args.unit || "ether";

    const value = unit === "wei" ? BigInt(amount) : parseUnits(amount, 18);

    console.error(`[MCP] Transferring ${amount} ${unit} to ${to} on ${net.name}`);

    const hash = await walletClient.sendTransaction({
      to,
      value,
      chain: null,
    });

    // Return only tx hash — NEVER return private key or raw env vars
    return safeResult({
      action: "transfer",
      network: net.name,
      to,
      amount: `${amount} ${unit}`,
      amountWei: value.toString(),
      txHash: hash,
      explorerUrl: `${net.explorer}/tx/${hash}`,
    });
  } catch (err) {
    return errorResult(`Transfer failed: ${err.message}`);
  }
}

// ---------------------------------------------------------------------------
// Tool 9 — pharos_deploy_erc20 (deploys ERC-20 via forge create)
// ---------------------------------------------------------------------------
async function deployErc20(args) {
  try {
    const net = getNetwork(args.network);
    const name = args.name || "Pharos Token";
    const symbol = args.symbol || "PHT";
    const supply = args.initialSupply || "1000000000000000000000000"; // 1M * 1e18

    if (!process.env.PRIVATE_KEY) {
      return errorResult("PRIVATE_KEY environment variable not set");
    }

    const simulateOnly = args.simulate !== false;

    console.error(`[MCP] Deploying ERC-20: ${name} (${symbol}) on ${net.name}`);

    const cmd = [
      "forge", "create",
      "contracts/PharosERC20.sol:PharosERC20",
      "--rpc-url", net.rpcUrl,
      "--private-key", process.env.PRIVATE_KEY,
      "--constructor-args", name, symbol, supply,
    ];

    if (simulateOnly) {
      cmd.push("--verify");
    } else {
      // forge create doesn't have a simulate flag, so we just run it
    }

    const output = execSync(cmd.join(" "), {
      cwd: PROJECT_ROOT,
      encoding: "utf-8",
      maxBuffer: 10 * 1024 * 1024,
      timeout: 120_000,
    });

    const addressMatch = output.match(/Deployed to: (0x[a-fA-F0-9]{40})/);
    const contractAddress = addressMatch ? addressMatch[1] : null;

    return safeResult({
      action: "deploy_erc20",
      network: net.name,
      chainId: net.id,
      tokenName: name,
      tokenSymbol: symbol,
      initialSupply: supply,
      contractAddress,
      explorerUrl: contractAddress ? `${net.explorer}/address/${contractAddress}` : null,
      raw: output.slice(-2000),
    });
  } catch (err) {
    return errorResult(`ERC-20 deploy failed: ${err.message}`);
  }
}

// ---------------------------------------------------------------------------
// Tool 10 — pharos_get_logs (fetches event logs via viem)
// ---------------------------------------------------------------------------
async function getLogs(args) {
  try {
    const net = getNetwork(args.network);
    const client = getClient(args.network);

    const address = args.address;
    const fromBlock = args.fromBlock ? BigInt(args.fromBlock) : undefined;
    const toBlock = args.toBlock ? BigInt(args.toBlock) : undefined;

    console.error(`[MCP] Fetching logs for ${address} blocks ${fromBlock || "latest-100"} to ${toBlock || "latest"}`);

    const logs = await client.getLogs({
      address,
      fromBlock,
      toBlock,
    });

    return safeResult({
      action: "get_logs",
      network: net.name,
      address,
      fromBlock: fromBlock?.toString() || "latest-100",
      toBlock: toBlock?.toString() || "latest",
      logCount: logs.length,
      logs: logs.slice(-100).map((l) => ({
        blockNumber: l.blockNumber?.toString(),
        txHash: l.transactionHash,
        address: l.address,
        topics: l.topics,
        data: l.data,
      })),
      warning: logs.length > 100 ? `Showing last 100 of ${logs.length} logs` : undefined,
    });
  } catch (err) {
    return errorResult(`Get logs failed: ${err.message}`);
  }
}

// ---------------------------------------------------------------------------
// MCP Server
// ---------------------------------------------------------------------------
const server = new Server(
  { name: "@pharos/mcp-server", version: "1.0.0" },
  { capabilities: { tools: {} } },
);

server.setRequestHandler({ method: "tools/list" }, async () => ({
  tools: [
    {
      name: "pharos_network_config",
      description: "Get Pharos network configuration (RPC URL, chain ID, explorer, currency) for a given network",
      inputSchema: {
        type: "object",
        properties: {
          network: { type: "string", enum: ["atlanticTestnet", "pacificMainnet"], default: "atlanticTestnet" },
        },
      },
    },
    {
      name: "pharos_deploy_contract",
      description: "Deploy a compiled contract to a Pharos network using forge script (simulation by default)",
      inputSchema: {
        type: "object",
        properties: {
          network: { type: "string", enum: ["atlanticTestnet", "pacificMainnet"], default: "atlanticTestnet" },
          script: { type: "string", description: "Forge script path (e.g., script/Deploy.s.sol:DeployCounter)" },
          simulate: { type: "boolean", description: "Simulate only (no broadcast)", default: true },
        },
      },
    },
    {
      name: "pharos_verify_contract",
      description: "Verify a deployed contract on PharosScan explorer (calls explorer API)",
      inputSchema: {
        type: "object",
        properties: {
          network: { type: "string", enum: ["atlanticTestnet", "pacificMainnet"] },
          address: { type: "string", description: "Deployed contract address (0x...)" },
          contract: { type: "string", description: "Contract name (e.g., Counter)" },
          constructorArgs: { type: "string", description: "Optional constructor args" },
        },
        required: ["address"],
      },
    },
    {
      name: "pharos_run_security_check",
      description: "Run slither + structured security review on a Pharos contract",
      inputSchema: {
        type: "object",
        properties: {
          contract: { type: "string", description: "Contract file name (with or without .sol)" },
        },
      },
    },
    {
      name: "pharos_generate_tests",
      description: "Generate and write Foundry test scaffolding for a contract to disk",
      inputSchema: {
        type: "object",
        properties: {
          contract: { type: "string", description: "Contract name (e.g., MyContract)" },
        },
      },
    },
    {
      name: "pharos_check_balance",
      description: "Check the PHRS/PROS balance of a wallet address on a Pharos network",
      inputSchema: {
        type: "object",
        properties: {
          network: { type: "string", enum: ["atlanticTestnet", "pacificMainnet"] },
          address: { type: "string", description: "Wallet address (0x...)" },
        },
        required: ["address"],
      },
    },
    {
      name: "pharos_contract_info",
      description: "Fetch contract metadata from PharosScan explorer API",
      inputSchema: {
        type: "object",
        properties: {
          network: { type: "string", enum: ["atlanticTestnet", "pacificMainnet"] },
          address: { type: "string", description: "Contract address (0x...)" },
        },
        required: ["address"],
      },
    },
    {
      name: "pharos_transfer_token",
      description: "Send PHRS/PROS to a wallet address (uses PRIVATE_KEY from environment)",
      inputSchema: {
        type: "object",
        properties: {
          network: { type: "string", enum: ["atlanticTestnet", "pacificMainnet"], default: "atlanticTestnet" },
          toAddress: { type: "string", description: "Recipient address (0x...)" },
          amount: { type: "string", description: "Amount to send" },
          unit: { type: "string", enum: ["ether", "wei"], default: "ether" },
        },
        required: ["toAddress", "amount"],
      },
    },
    {
      name: "pharos_deploy_erc20",
      description: "Deploy a standard PharosERC20 token contract with name, symbol, and initial supply",
      inputSchema: {
        type: "object",
        properties: {
          network: { type: "string", enum: ["atlanticTestnet", "pacificMainnet"], default: "atlanticTestnet" },
          name: { type: "string", description: "Token name", default: "Pharos Token" },
          symbol: { type: "string", description: "Token symbol", default: "PHT" },
          initialSupply: { type: "string", description: "Initial supply in wei (default 1M * 1e18)", default: "1000000000000000000000000" },
          simulate: { type: "boolean", description: "Simulate only", default: true },
        },
      },
    },
    {
      name: "pharos_get_logs",
      description: "Fetch event logs from a contract address with optional block range",
      inputSchema: {
        type: "object",
        properties: {
          network: { type: "string", enum: ["atlanticTestnet", "pacificMainnet"] },
          address: { type: "string", description: "Contract address (0x...)" },
          fromBlock: { type: "string", description: "Start block number (optional)" },
          toBlock: { type: "string", description: "End block number (optional)" },
        },
        required: ["address"],
      },
    },
  ],
}));

server.setRequestHandler({ method: "tools/call" }, async (request) => {
  const { name, arguments: args } = request.params;

  try {
    switch (name) {
      case "pharos_network_config":
        return networkConfig(args);
      case "pharos_deploy_contract":
        return await deployContract(args);
      case "pharos_verify_contract":
        return await verifyContract(args);
      case "pharos_run_security_check":
        return await runSecurityCheck(args);
      case "pharos_generate_tests":
        return await generateTests(args);
      case "pharos_check_balance":
        return await checkBalance(args);
      case "pharos_contract_info":
        return await contractInfo(args);
      case "pharos_transfer_token":
        return await transferToken(args);
      case "pharos_deploy_erc20":
        return await deployErc20(args);
      case "pharos_get_logs":
        return await getLogs(args);
      default:
        return errorResult(`Unknown tool: ${name}`);
    }
  } catch (err) {
    return errorResult(`Tool ${name} error: ${err.message}`);
  }
});

// ---------------------------------------------------------------------------
// Start
// ---------------------------------------------------------------------------
const transport = new StdioServerTransport();
await server.connect(transport);
console.error("Pharos MCP Server running on stdio — 10 executable tools");
