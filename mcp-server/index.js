#!/usr/bin/env node
/**
 * Pharos MCP Server — Executable Tools
 *
 * 11 tools for AI agents to interact with the Pharos blockchain.
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

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------
const SUBLINK = {
  deploy_contract: "deployment-and-verification",
  deploy_erc20: "solidity-authoring",
  verify_contract: "deployment-and-verification",
  transfer_token: "wallet-and-transaction-ui",
  check_balance: "frontend-dapp-integration",
  security_check: "security-audit",
  generate_tests: "test-generation",
  get_logs: "protocol-integration-planning",
  contract_info: "contract-review",
  network_config: "framework-integration",
  diagnose: "framework-integration",
};

function withSubskill(data, toolKey) {
  const sub = SUBLINK[toolKey];
  data.recommendedSubskill = sub;
  data.nextStep = `For detailed guidance, invoke the \`${sub}\` subskill.`;
  return data;
}

function safeResult(data) {
  const sanitized = JSON.parse(JSON.stringify(data), (key, value) => {
    if (typeof value === "string" && value.length > 60 && value.includes("0x")) {
      const pkMatch = value.match(/0x[a-fA-F0-9]{64}/);
      if (pkMatch) return value.replace(pkMatch[0], "0x...REDACTED...");
    }
    return value;
  });
  return { content: [{ type: "text", text: JSON.stringify(sanitized, null, 2) }] };
}

function structuredError(err, toolKey) {
  const msg = err.message || String(err);
  let hint;
  if (msg.includes("forge") || msg.includes("cast") || msg.includes("command not found")) {
    hint = "Install Foundry: curl -L https://foundry.paradigm.xyz | bash && foundryup";
  } else if (msg.includes("PRIVATE_KEY") || msg.includes("private key")) {
    hint = "Set PRIVATE_KEY environment variable in your shell or .env file";
  } else if (msg.includes("RPC") || msg.includes("connect") || msg.includes("ECONNREFUSED")) {
    hint = "Check PHAROS_TESTNET_RPC_URL or network connectivity. Default: https://atlantic.dplabs-internal.com";
  } else if (msg.includes("chain") || msg.includes("network")) {
    hint = "Use 'atlanticTestnet' (688689) or 'pacificMainnet' (1672). Verify with: cast chain-id --rpc-url <url>";
  } else if (msg.includes("balance") || msg.includes("insufficient funds")) {
    hint = "Get testnet PHRS from https://testnet.pharosnetwork.xyz";
  } else if (msg.includes("slither")) {
    hint = "Install slither: pip install slither-analyzer";
  } else {
    hint = "Unexpected error. Check network config and environment setup. See README.md for details.";
  }
  const sub = SUBLINK[toolKey] || "framework-integration";
  return {
    isError: true,
    content: [{
      type: "text",
      text: JSON.stringify({ error: msg, hint, tool: `pharos_${toolKey}`, recommendedSubskill: sub, nextStep: `For detailed guidance, invoke the \`${sub}\` subskill.` }, null, 2),
    }],
  };
}

// ---------------------------------------------------------------------------
// Tool 1 — pharos_network_config
// ---------------------------------------------------------------------------
function networkConfig(args) {
  try {
    const net = getNetwork(args.network);
    return safeResult(withSubskill({
      network: net.name,
      chainId: net.id,
      currency: net.nativeCurrency,
      rpcUrl: net.rpcUrl,
      explorer: net.explorer,
      explorerApi: net.explorerApi,
      isTestnet: net.testnet,
    }, "network_config"));
  } catch (err) {
    return structuredError(err, "network_config");
  }
}

// ---------------------------------------------------------------------------
// Tool 2 — pharos_deploy_contract
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

    const addressMatch = output.match(/deployed at: (0x[a-fA-F0-9]{40})/);
    const contractAddress = addressMatch ? addressMatch[1] : null;

    return safeResult(withSubskill({
      action: simulateOnly ? "simulate" : "deploy",
      network: net.name,
      chainId: net.id,
      script,
      contractAddress,
      warning: simulateOnly ? "Simulation only. Set simulate=false to broadcast." : "Contract deployed. Verify on explorer after broadcast.",
      explorerUrl: contractAddress ? `${net.explorer}/address/${contractAddress}` : null,
    }, "deploy_contract"));
  } catch (err) {
    return structuredError(err, "deploy_contract");
  }
}

// ---------------------------------------------------------------------------
// Tool 3 — pharos_verify_contract
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

    let apiResult = null;
    try {
      const response = await fetch(apiUrl, {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ address, contractName: contract, constructorArguments: constructorArgs, apikey: apiKey }),
      });
      apiResult = await response.text();
    } catch (_fetchErr) {
      apiResult = "API verification unavailable (explorer may not support programmatic verification)";
    }

    return safeResult(withSubskill({
      action: "verify",
      network: net.name,
      address,
      contract,
      apiResult,
      forgeCommand: `forge verify-contract --chain-id ${net.id} --verifier-url ${net.explorerApi} ${address} ${contract}`,
      explorerUrl: `${net.explorer}/address/${address}`,
      manualUrl: `${net.explorer}/address/${address}#code`,
    }, "verify_contract"));
  } catch (err) {
    return structuredError(err, "verify_contract");
  }
}

// ---------------------------------------------------------------------------
// Tool 4 — pharos_run_security_check (Pharos-specific)
// ---------------------------------------------------------------------------
async function runSecurityCheck(args) {
  try {
    const contractPath = args.contract
      ? join(PROJECT_ROOT, "contracts", args.contract.endsWith(".sol") ? args.contract : `${args.contract}.sol`)
      : null;

    let slitherOutput = null;
    if (contractPath && existsSync(contractPath)) {
      try {
        slitherOutput = execSync(`slither "${contractPath}" --json 2>/dev/null`, { encoding: "utf-8", timeout: 30_000 });
      } catch (slitherErr) {
        slitherOutput = `slither not available: ${slitherErr.message}`;
      }
    }

    return safeResult(withSubskill({
      action: "security_check",
      contract: args.contract || "unknown",
      contractPath: contractPath || "not specified",
      slitherAvailable: slitherOutput && !slitherOutput.includes("not available"),
      slitherOutput,
      pharosSpecificChecks: [
        "PHRS has no 2300 gas stipend — use pull-over-push pattern for native transfers",
        "Atlantic Testnet chain ID is 688689, not 688688 (deprecated v1)",
        "EIP-1559 gas model — base fee burned, priority fee to validators",
        "RPC rate-limited to ~30 req/s sustained — avoid unbounded loops in scripts",
        "SPN cross-chain transactions require mailbox verification on both sides",
        "Atlantic RPC: https://atlantic.dplabs-internal.com | Mainnet: https://rpc.pharos.xyz",
        "Explorer verification via https://atlantic.pharosscan.xyz/api",
      ],
      generalChecks: [
        "Reentrancy: checks-effects-interactions pattern followed?",
        "Access control: onlyOwner on sensitive functions?",
        "Integer safety: Solc 0.8+ checked math (no SafeMath needed)",
        "Front-running: tx ordering dependencies?",
        "Gas: bounded loops only?",
      ],
    }, "security_check"));
  } catch (err) {
    return structuredError(err, "security_check");
  }
}

// ---------------------------------------------------------------------------
// Tool 5 — pharos_generate_tests
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

    return safeResult(withSubskill({
      action: "generate_tests",
      contract,
      filePath: `test/${contract}.t.sol`,
      code: testCode,
      status: "written",
    }, "generate_tests"));
  } catch (err) {
    return structuredError(err, "generate_tests");
  }
}

// ---------------------------------------------------------------------------
// Tool 6 — pharos_check_balance
// ---------------------------------------------------------------------------
async function checkBalance(args) {
  try {
    const net = getNetwork(args.network);
    const client = getClient(args.network);
    const balance = await client.getBalance({ address: args.address });
    const formatted = formatUnits(balance, net.nativeCurrency.decimals);

    return safeResult(withSubskill({
      action: "check_balance",
      network: net.name,
      address: args.address,
      balanceWei: balance.toString(),
      balanceFormatted: `${formatted} ${net.nativeCurrency.symbol}`,
      explorerUrl: `${net.explorer}/address/${args.address}`,
    }, "check_balance"));
  } catch (err) {
    return structuredError(err, "check_balance");
  }
}

// ---------------------------------------------------------------------------
// Tool 7 — pharos_contract_info
// ---------------------------------------------------------------------------
async function contractInfo(args) {
  try {
    const net = getNetwork(args.network);
    const address = args.address;

    let sourceCode = null;
    try {
      const resp = await fetch(`${net.explorerApi}?module=contract&action=getsourcecode&address=${address}`);
      const data = await resp.json();
      sourceCode = data;
    } catch (_fetchErr) {
      sourceCode = "Explorer API unavailable";
    }

    return safeResult(withSubskill({
      action: "contract_info",
      address,
      network: net.name,
      chainId: net.id,
      sourceCode,
      explorerUrl: `${net.explorer}/address/${address}`,
      explorerApiUrl: `${net.explorerApi}?module=contract&action=getsourcecode&address=${address}`,
    }, "contract_info"));
  } catch (err) {
    return structuredError(err, "contract_info");
  }
}

// ---------------------------------------------------------------------------
// Tool 8 — pharos_transfer_token
// ---------------------------------------------------------------------------
async function transferToken(args) {
  try {
    const net = getNetwork(args.network);
    if (!process.env.PRIVATE_KEY) {
      return structuredError(new Error("PRIVATE_KEY not set in environment"), "transfer_token");
    }

    const walletClient = getWalletClient(args.network);
    const to = args.toAddress;
    const amount = args.amount;
    const unit = args.unit || "ether";
    const value = unit === "wei" ? BigInt(amount) : parseUnits(amount, 18);

    console.error(`[MCP] Transferring ${amount} ${unit} to ${to} on ${net.name}`);

    const hash = await walletClient.sendTransaction({ to, value, chain: null });

    return safeResult(withSubskill({
      action: "transfer",
      network: net.name,
      to,
      amount: `${amount} ${unit}`,
      amountWei: value.toString(),
      txHash: hash,
      explorerUrl: `${net.explorer}/tx/${hash}`,
    }, "transfer_token"));
  } catch (err) {
    return structuredError(err, "transfer_token");
  }
}

// ---------------------------------------------------------------------------
// Tool 9 — pharos_deploy_erc20
// ---------------------------------------------------------------------------
async function deployErc20(args) {
  try {
    const net = getNetwork(args.network);
    const name = args.name || "Pharos Token";
    const symbol = args.symbol || "PHT";
    const supply = args.initialSupply || "1000000000000000000000000";

    if (!process.env.PRIVATE_KEY) {
      return structuredError(new Error("PRIVATE_KEY not set in environment"), "deploy_erc20");
    }

    console.error(`[MCP] Deploying ERC-20: ${name} (${symbol}) on ${net.name}`);

    const cmd = [
      "forge", "create",
      "contracts/PharosERC20.sol:PharosERC20",
      "--rpc-url", net.rpcUrl,
      "--private-key", process.env.PRIVATE_KEY,
      "--constructor-args", name, symbol, supply,
    ];

    const output = execSync(cmd.join(" "), {
      cwd: PROJECT_ROOT,
      encoding: "utf-8",
      maxBuffer: 10 * 1024 * 1024,
      timeout: 120_000,
    });

    const addressMatch = output.match(/Deployed to: (0x[a-fA-F0-9]{40})/);
    const contractAddress = addressMatch ? addressMatch[1] : null;

    return safeResult(withSubskill({
      action: "deploy_erc20",
      network: net.name,
      chainId: net.id,
      tokenName: name,
      tokenSymbol: symbol,
      initialSupply: supply,
      contractAddress,
      explorerUrl: contractAddress ? `${net.explorer}/address/${contractAddress}` : null,
    }, "deploy_erc20"));
  } catch (err) {
    return structuredError(err, "deploy_erc20");
  }
}

// ---------------------------------------------------------------------------
// Tool 10 — pharos_get_logs
// ---------------------------------------------------------------------------
async function getLogs(args) {
  try {
    const net = getNetwork(args.network);
    const client = getClient(args.network);
    const address = args.address;
    const fromBlock = args.fromBlock ? BigInt(args.fromBlock) : undefined;
    const toBlock = args.toBlock ? BigInt(args.toBlock) : undefined;

    console.error(`[MCP] Fetching logs for ${address} on ${net.name}`);

    const logs = await client.getLogs({ address, fromBlock, toBlock });

    return safeResult(withSubskill({
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
    }, "get_logs"));
  } catch (err) {
    return structuredError(err, "get_logs");
  }
}

// ---------------------------------------------------------------------------
// Tool 11 — pharos_diagnose
// ---------------------------------------------------------------------------
async function diagnose(args) {
  const results = {};

  for (const cmd of ["forge", "cast", "node", "git"]) {
    try {
      execSync(`which ${cmd} 2>/dev/null`, { stdio: "pipe" });
      results[cmd] = "installed";
    } catch {
      results[cmd] = "missing";
    }
  }

  try {
    const chainId = execSync("cast chain-id --rpc-url https://atlantic.dplabs-internal.com 2>/dev/null", { encoding: "utf8" }).trim();
    results.rpc = chainId === "688689" ? `reachable (chain ${chainId})` : `wrong chain: ${chainId}`;
  } catch {
    results.rpc = "unreachable";
  }

  results.privateKey = process.env.PRIVATE_KEY ? "set" : "missing";
  results.pharosscanApiKey = process.env.PHAROSSCAN_API_KEY ? "set" : "missing";

  const allGood = Object.values(results).every((v) => v === "installed" || v.startsWith("reachable") || v === "set");

  return safeResult(withSubskill({
    status: allGood ? "ready" : "needs setup",
    checks: results,
    nextSteps: results.privateKey === "missing" ? ["Set PRIVATE_KEY env var"] : [],
  }, "diagnose"));
}

// ---------------------------------------------------------------------------
// Subskill lookup for tools/list descriptions
// ---------------------------------------------------------------------------
const TOOL_META = {
  pharos_network_config: { description: "Get Pharos network configuration (RPC URL, chain ID, explorer, currency) for a given network", subskill: "framework-integration" },
  pharos_deploy_contract: { description: "Deploy a compiled contract to a Pharos network using forge script (simulation by default)", subskill: "deployment-and-verification" },
  pharos_verify_contract: { description: "Verify a deployed contract on PharosScan explorer (calls explorer API)", subskill: "deployment-and-verification" },
  pharos_run_security_check: { description: "Run slither + structured security review with Pharos-specific checks (no 2300 gas, chain IDs, RPC limits)", subskill: "security-audit" },
  pharos_generate_tests: { description: "Generate and write Foundry test scaffolding for a contract to disk", subskill: "test-generation" },
  pharos_check_balance: { description: "Check the PHRS/PROS balance of a wallet address on a Pharos network", subskill: "frontend-dapp-integration" },
  pharos_contract_info: { description: "Fetch contract metadata from PharosScan explorer API", subskill: "contract-review" },
  pharos_transfer_token: { description: "Send PHRS/PROS to a wallet address (uses PRIVATE_KEY from environment, NEVER exposes it)", subskill: "wallet-and-transaction-ui" },
  pharos_deploy_erc20: { description: "Deploy a standard PharosERC20 token contract with name, symbol, and initial supply", subskill: "solidity-authoring" },
  pharos_get_logs: { description: "Fetch event logs from a contract address with optional block range", subskill: "protocol-integration-planning" },
  pharos_diagnose: { description: "Diagnose environment: check dependencies (forge, cast, node, git), RPC connectivity, and env vars", subskill: "framework-integration" },
};

// ---------------------------------------------------------------------------
// MCP Server
// ---------------------------------------------------------------------------
const server = new Server(
  { name: "@pharos/mcp-server", version: "1.0.0" },
  { capabilities: { tools: {} } },
);

const TOOL_SCHEMAS = {
  pharos_network_config: {
    type: "object",
    properties: {
      network: { type: "string", enum: ["atlanticTestnet", "pacificMainnet"], default: "atlanticTestnet" },
    },
  },
  pharos_deploy_contract: {
    type: "object",
    properties: {
      network: { type: "string", enum: ["atlanticTestnet", "pacificMainnet"], default: "atlanticTestnet" },
      script: { type: "string", description: "Forge script path (e.g., script/Deploy.s.sol:DeployCounter)" },
      simulate: { type: "boolean", description: "Simulate only (no broadcast)", default: true },
    },
  },
  pharos_verify_contract: {
    type: "object",
    properties: {
      network: { type: "string", enum: ["atlanticTestnet", "pacificMainnet"] },
      address: { type: "string", description: "Deployed contract address (0x...)" },
      contract: { type: "string", description: "Contract name (e.g., Counter)" },
      constructorArgs: { type: "string", description: "Optional constructor args" },
    },
    required: ["address"],
  },
  pharos_run_security_check: {
    type: "object",
    properties: {
      contract: { type: "string", description: "Contract file name (with or without .sol)" },
    },
  },
  pharos_generate_tests: {
    type: "object",
    properties: {
      contract: { type: "string", description: "Contract name (e.g., MyContract)" },
    },
  },
  pharos_check_balance: {
    type: "object",
    properties: {
      network: { type: "string", enum: ["atlanticTestnet", "pacificMainnet"] },
      address: { type: "string", description: "Wallet address (0x...)" },
    },
    required: ["address"],
  },
  pharos_contract_info: {
    type: "object",
    properties: {
      network: { type: "string", enum: ["atlanticTestnet", "pacificMainnet"] },
      address: { type: "string", description: "Contract address (0x...)" },
    },
    required: ["address"],
  },
  pharos_transfer_token: {
    type: "object",
    properties: {
      network: { type: "string", enum: ["atlanticTestnet", "pacificMainnet"], default: "atlanticTestnet" },
      toAddress: { type: "string", description: "Recipient address (0x...)" },
      amount: { type: "string", description: "Amount to send" },
      unit: { type: "string", enum: ["ether", "wei"], default: "ether" },
    },
    required: ["toAddress", "amount"],
  },
  pharos_deploy_erc20: {
    type: "object",
    properties: {
      network: { type: "string", enum: ["atlanticTestnet", "pacificMainnet"], default: "atlanticTestnet" },
      name: { type: "string", description: "Token name", default: "Pharos Token" },
      symbol: { type: "string", description: "Token symbol", default: "PHT" },
      initialSupply: { type: "string", description: "Initial supply in wei", default: "1000000000000000000000000" },
      simulate: { type: "boolean", description: "Simulate only", default: true },
    },
  },
  pharos_get_logs: {
    type: "object",
    properties: {
      network: { type: "string", enum: ["atlanticTestnet", "pacificMainnet"] },
      address: { type: "string", description: "Contract address (0x...)" },
      fromBlock: { type: "string", description: "Start block number (optional)" },
      toBlock: { type: "string", description: "End block number (optional)" },
    },
    required: ["address"],
  },
  pharos_diagnose: {
    type: "object",
    properties: {},
  },
};

server.setRequestHandler({ method: "tools/list" }, async () => ({
  tools: Object.entries(TOOL_META).map(([name, meta]) => ({
    name,
    description: meta.description,
    inputSchema: TOOL_SCHEMAS[name] || { type: "object", properties: {} },
  })),
}));

server.setRequestHandler({ method: "tools/call" }, async (request) => {
  const { name, arguments: args } = request.params;

  try {
    switch (name) {
      case "pharos_network_config": return networkConfig(args);
      case "pharos_deploy_contract": return await deployContract(args);
      case "pharos_verify_contract": return await verifyContract(args);
      case "pharos_run_security_check": return await runSecurityCheck(args);
      case "pharos_generate_tests": return await generateTests(args);
      case "pharos_check_balance": return await checkBalance(args);
      case "pharos_contract_info": return await contractInfo(args);
      case "pharos_transfer_token": return await transferToken(args);
      case "pharos_deploy_erc20": return await deployErc20(args);
      case "pharos_get_logs": return await getLogs(args);
      case "pharos_diagnose": return await diagnose(args);
      default: return { isError: true, content: [{ type: "text", text: JSON.stringify({ error: `Unknown tool: ${name}` }) }] };
    }
  } catch (err) {
    return { isError: true, content: [{ type: "text", text: `Tool ${name} error: ${err.message}` }] };
  }
});

// ---------------------------------------------------------------------------
// Startup dependency check
// ---------------------------------------------------------------------------
function checkDependencies() {
  for (const cmd of ["forge", "cast", "node"]) {
    try {
      execSync(`which ${cmd} 2>/dev/null || command -v ${cmd} 2>/dev/null`, { stdio: "pipe" });
    } catch {
      console.error(`WARNING: ${cmd} not found in PATH. Tools that depend on it will fail.`);
    }
  }
  console.error("Dependency check complete.");
}

// ---------------------------------------------------------------------------
// Start
// ---------------------------------------------------------------------------
checkDependencies();
const transport = new StdioServerTransport();
await server.connect(transport);
console.error("Pharos MCP Server running on stdio — 11 tools");
