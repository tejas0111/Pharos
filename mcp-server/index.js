#!/usr/bin/env node
/**
 * Pharos MCP Server — Executable Tools
 *
 * 21 tools for AI agents to interact with the Pharos blockchain.
 * Tools execute real operations: deploy, verify, transfer, fetch logs, etc.
 *
 * Security: PRIVATE_KEY is read from env, NEVER exposed in output.
 */

import { Server } from "@modelcontextprotocol/sdk/server/index.js";
import { StdioServerTransport } from "@modelcontextprotocol/sdk/server/stdio.js";
import { ListToolsRequestSchema, CallToolRequestSchema } from "@modelcontextprotocol/sdk/types.js";
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
    fallbackUrls: [],
    explorer: "https://atlantic.pharosscan.xyz",
    explorerApi: "https://atlantic.pharosscan.xyz/api",
    testnet: true,
  },
  pacificMainnet: {
    id: 1672,
    name: "Pacific Mainnet",
    nativeCurrency: { name: "PROS", symbol: "PROS", decimals: 18 },
    rpcUrl: process.env.PHAROS_MAINNET_RPC_URL || "https://rpc.pharos.xyz",
    fallbackUrls: ["https://infra.orginstake.com/pharos/evm"],
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

const RPC_RETRIES = 2;
const RPC_TIMEOUT = 10000;

async function rpcCall(network, method, params) {
  const net = getNetwork(network);
  const urls = [net.rpcUrl, ...(net.fallbackUrls || [])];
  let lastErr;
  for (const url of urls) {
    for (let attempt = 0; attempt <= RPC_RETRIES; attempt++) {
      try {
        const controller = new AbortController();
        const timeout = setTimeout(() => controller.abort(), RPC_TIMEOUT);
        const response = await fetch(url, {
          method: "POST",
          headers: { "Content-Type": "application/json" },
          body: JSON.stringify({ jsonrpc: "2.0", method, params, id: 1 }),
          signal: controller.signal,
        });
        clearTimeout(timeout);
        const data = await response.json();
        if (data.error) throw new Error(`RPC error: ${data.error.message}`);
        return data.result;
      } catch (err) {
        lastErr = err;
        if (attempt < RPC_RETRIES) await new Promise(r => setTimeout(r, 1000 * (attempt + 1)));
      }
    }
  }
  throw new Error(`RPC failed after ${urls.length * (RPC_RETRIES + 1)} attempts: ${lastErr.message}`);
}

function getClient(network) {
  const net = getNetwork(network);
  return createPublicClient({ transport: http(net.rpcUrl, { timeout: RPC_TIMEOUT }) });
}

function getWalletClient(network) {
  const pk = process.env.PRIVATE_KEY;
  if (!pk) throw new Error("PRIVATE_KEY not set in environment");
  const net = getNetwork(network);
  const account = privateKeyToAccount(pk);
  return createWalletClient({
    account,
    transport: http(net.rpcUrl, { timeout: RPC_TIMEOUT }),
  });
}

const VALID_BLOCK_TAGS = ["latest", "safe", "finalized", "pending", "earliest"];

function validateBlockTag(tag) {
  if (tag && !VALID_BLOCK_TAGS.includes(tag)) {
    throw new Error(`Invalid blockTag: "${tag}". Must be one of: ${VALID_BLOCK_TAGS.join(", ")}`);
  }
}

const abiCache = new Map();

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
  get_account: "wallet-and-transaction-ui",
  gas_estimate: "gas-optimization",
  trace_transaction: "bug-finding-and-debugging",
  network_status: "production-ops",
  read_contract: "contract-review",
  write_contract: "wallet-and-transaction-ui",
  fetch_abi: "contract-review",
};

function contextualTip(toolName, args, result) {
  const tips = {
    pharos_check_balance: (args, result) => {
      if (result?.balanceFormatted === "0") return "Zero balance. Get free testnet PHRS at https://testnet.pharosnetwork.xyz";
      if (args?.network === "atlanticTestnet") return "This is Atlantic Testnet (688689). Balance is in PHRS, not PROS.";
      return "Pharos burns base fee (EIP-1559). Actual tx cost = gasUsed × (baseFee + priorityFee).";
    },
    pharos_deploy_contract: () => "PHRS has no 2300 gas stipend. Your contracts must use pull-over-push for native transfers, not .transfer() or .send().",
    pharos_transfer_token: (args) => args?.network === "pacificMainnet"
      ? "⚠️ MAINNET transfer. PROS cannot be recovered if sent to wrong network. Verify the address twice."
      : "Testnet transfer. Use small amounts first, then verify on explorer before mainnet.",
    pharos_get_logs: () => "Pharos RPC limits eth_getLogs to 100 blocks per request. Use pagination for larger ranges.",
    pharos_get_account: () => "eth_getAccount is Pharos-specific — no other chain returns all four fields (balance, nonce, codeHash, storageRoot) in one call.",
    pharos_gas_estimate: (args, result) => {
      const cost = result?.estimatedTxCostFormatted || "unknown";
      return `A simple transfer costs ~${cost} in gas (base fee burned + priority fee to validators).`;
    },
    pharos_trace_transaction: () => "debug_traceTransaction is publicly enabled on Pharos — use it to debug reverts and optimize gas.",
    pharos_network_status: (args, result) => `Chain is ${result?.blocksToFinalized || "?"} blocks from finality. Use "finalized" tag for production reads.`,
    pharos_read_contract: (args, result) => `Use safe or finalized block tags for production reads. Pharos has these tags available — most chains don't.`,
    pharos_write_contract: (args, result) => result?.simulated ? "Simulation passed. Set simulate=false to broadcast the transaction." : `Transaction sent. Track it at ${result?.explorerUrl || "the explorer"}.`,
    pharos_fetch_abi: () => "Use the returned ABI with pharos_read_contract or pharos_write_contract to interact with the contract. Cache ABIs locally to avoid repeated calls.",
  };
  const fn = tips[toolName];
  return fn ? fn(args, result) : "💡 Pharos uses EIP-1559 — base fee burned, priority fee to validators.";
}

function withSubskill(data, toolKey, args) {
  const sub = SUBLINK[toolKey];
  data.recommendedSubskill = sub;
  data.nextStep = `For detailed guidance, invoke the \`${sub}\` subskill.`;
  const fullName = `pharos_${toolKey}`;
  data.pharosTip = contextualTip(fullName, args, data);
  return data;
}

function safeResult(data) {
  const sanitized = JSON.parse(JSON.stringify(data));
  return { content: [{ type: "text", text: JSON.stringify(sanitized, null, 2) }] };
}

function validateAddress(address, label) {
  if (typeof address !== "string" || !/^0x[a-fA-F0-9]{40}$/.test(address)) {
    throw new Error(`${label}: invalid Ethereum address (must be 0x + 40 hex chars)`);
  }
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
  const fullName = `pharos_${toolKey}`;
  const pharosTip = contextualTip(fullName);
  return {
    isError: true,
    content: [{
      type: "text",
      text: JSON.stringify({ error: msg, hint, tool: fullName, recommendedSubskill: sub, nextStep: `For detailed guidance, invoke the \`${sub}\` subskill.`, pharosTip }, null, 2),
    }],
  };
}

// ---------------------------------------------------------------------------
// Security gate — auto-run slither pre-deploy, block on High severity
// ---------------------------------------------------------------------------
const GAS_SPIKE_THRESHOLD_GWEI = 50;

async function securityGate(contractPath, network) {
  if (!contractPath || !existsSync(contractPath)) return null;
  try {
    const raw = execSync(`slither "${contractPath}" --json 2>/dev/null`, { encoding: "utf-8", timeout: 30_000 });
    const report = JSON.parse(raw);
    const highIssues = (report.results?.detectors || []).filter(d =>
      d.impact === "High" || d.impact === "Critical"
    );
    if (highIssues.length > 0) {
      return {
        blocked: true,
        count: highIssues.length,
        issues: highIssues.map(d => ({ check: d.check, impact: d.impact, description: d.description, elements: d.elements })),
        message: `⛔ Security gate blocked: ${highIssues.length} High/Critical issue(s) found. Fix them before deploying.`,
      };
    }
    return { blocked: false, message: "✅ Security gate passed — no High/Critical issues." };
  } catch {
    return { blocked: "unknown", message: "⚠️  Slither not available or parse failed. Gate skipped. Install: pip install slither-analyzer" };
  }
}

// ---------------------------------------------------------------------------
// Gas price monitor — warn before broadcast if spiked
// ---------------------------------------------------------------------------
async function checkGasSpike(network) {
  const GAS_SPIKE_WARN = 60;
  try {
    const gasPrice = await rpcCall(network, "eth_gasPrice", []);
    const gwei = Number(BigInt(gasPrice)) / 1e9;
    if (gwei > GAS_SPIKE_WARN) {
      return { spiked: true, currentGwei: gwei.toFixed(1), threshold: GAS_SPIKE_WARN,
        message: `⚠️  Gas price is ${gwei.toFixed(1)} Gwei (threshold ${GAS_SPIKE_WARN}). Consider waiting.` };
    }
    return { spiked: false, currentGwei: gwei.toFixed(1), message: `✅ Gas at ${gwei.toFixed(1)} Gwei — normal.` };
  } catch {
    return { spiked: false, currentGwei: "unknown", message: "⚠️  Could not check gas prices." };
  }
}

// ---------------------------------------------------------------------------
// Auto-verify — post-deploy hook for PharosScan
// ---------------------------------------------------------------------------
async function autoVerify(network, address, contractName, constructorArgs) {
  try {
    const net = getNetwork(network);
    const apiKey = process.env.PHAROSSCAN_API_KEY || "";
    const apiUrl = `${net.explorerApi}?module=contract&action=verify&address=${address}`;
    const response = await fetch(apiUrl, {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({ address, contractName: contractName || "Counter", constructorArguments: constructorArgs || "", apikey: apiKey }),
    });
    const text = await response.text();
    const guid = (typeof text === "string" && text.includes("result"))
      ? (JSON.parse(text).result || text)
      : text;
    return { submitted: true, guid, explorerUrl: `${net.explorer}/address/${address}` };
  } catch {
    return { submitted: false, reason: "Explorer API not reachable. Verify manually after deploy." };
  }
}

// ---------------------------------------------------------------------------
// Frontend Gate Sync — write .env and ABI files
// ---------------------------------------------------------------------------
async function syncFrontend(frontendPath, network, address, contractName, abi) {
  const envPath = join(frontendPath, ".env.local");
  const networkUpper = network === "pacificMainnet" ? "MAINNET" : "TESTNET";
  const envEntry = `NEXT_PUBLIC_${contractName.toUpperCase()}_ADDRESS_${networkUpper}=${address}\n`;

  let envContent = "";
  if (existsSync(envPath)) {
    envContent = execSync(`cat "${envPath}"`, { encoding: "utf-8" });
    const regex = new RegExp(`^NEXT_PUBLIC_${contractName.toUpperCase()}_ADDRESS_${networkUpper}=.*\n?`, "m");
    if (regex.test(envContent)) {
      envContent = envContent.replace(regex, envEntry);
    } else {
      envContent += envEntry;
    }
  } else {
    envContent = envEntry;
  }
  writeFileSync(envPath, envContent, "utf-8");

  const abiDir = join(frontendPath, "abis");
  if (!existsSync(abiDir)) execSync(`mkdir -p "${abiDir}"`, { stdio: "pipe" });
  const abiPath = join(abiDir, `${contractName}.json`);
  writeFileSync(abiPath, typeof abi === "string" ? abi : JSON.stringify(abi, null, 2), "utf-8");

  return { envFile: envPath, abiFile: abiPath, address, network };
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
    const skipGate = args.skipSecurityGate === true;
    const skipVerify = args.skipAutoVerify === true;
    const frontendPath = args.frontendPath || null;
    const contractName = args.contractName || "Counter";

    // 1. Security gate
    if (!skipGate && !simulateOnly) {
      const gate = await securityGate(join(PROJECT_ROOT, "contracts", `${contractName}.sol`), args.network);
      if (gate && gate.blocked === true) {
        return structuredError(new Error(gate.message), "deploy_contract");
      }
    }

    // 2. Gas check
    if (!simulateOnly) {
      const gas = await checkGasSpike(args.network);
      if (gas.spiked) {
        console.error(`[MCP] ${gas.message}`);
      }
    }

    console.error(`[MCP] Deploying: ${script} on ${net.name} (simulate=${simulateOnly})`);

    const cmd = [
      "forge", "script", script,
      "--rpc-url", net.rpcUrl,
    ];
    if (simulateOnly) {
      cmd.push("-vvv");
    } else {
      cmd.push("--broadcast", "-vvv");
    }

    const env = { ...process.env, PRIVATE_KEY: process.env.PRIVATE_KEY };
    const output = execSync(cmd.join(" "), {
      cwd: PROJECT_ROOT,
      encoding: "utf-8",
      maxBuffer: 10 * 1024 * 1024,
      timeout: 120_000,
      stdio: ["pipe", "pipe", "pipe"],
      env,
    });

    const addressMatch = output.match(/deployed at: (0x[a-fA-F0-9]{40})/);
    const contractAddress = addressMatch ? addressMatch[1] : null;

    // 3. Auto-verify
    let verifyResult = null;
    if (contractAddress && !simulateOnly && !skipVerify) {
      verifyResult = await autoVerify(args.network, contractAddress, contractName, args.constructorArgs);
    }

    // 4. Frontend sync
    let syncResult = null;
    if (contractAddress && frontendPath) {
      try {
        const abiPath = join(PROJECT_ROOT, "out", `${contractName}.sol`, `${contractName}.json`);
        const abiContent = existsSync(abiPath)
          ? JSON.stringify(JSON.parse(execSync(`cat "${abiPath}"`, { encoding: "utf-8" })).abi, null, 2)
          : "[]";
        syncResult = await syncFrontend(frontendPath, args.network, contractAddress, contractName, abiContent);
      } catch { /* skip frontend sync on failure */ }
    }

    return safeResult(withSubskill({
      action: simulateOnly ? "simulate" : "deploy",
      network: net.name,
      chainId: net.id,
      script,
      contractAddress,
      contractName,
      securityGate: skipGate ? "skipped" : "passed",
      gasCheck: `current: ${(await checkGasSpike(args.network)).currentGwei} Gwei`,
      autoVerify: verifyResult,
      frontendSync: syncResult,
      warning: simulateOnly ? "Simulation only. Set simulate=false to broadcast." : "Contract deployed.",
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
    validateAddress(args.address, "verifyContract address");
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
    validateAddress(args.address, "checkBalance address");
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
    validateAddress(args.address, "contractInfo address");
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
    validateAddress(args.toAddress, "transferToken toAddress");
    if (!process.env.PRIVATE_KEY) {
      return structuredError(new Error("PRIVATE_KEY not set in environment"), "transfer_token");
    }

    const walletClient = getWalletClient(args.network);
    const to = args.toAddress;
    const amount = args.amount;
    const unit = args.unit || "ether";
    const value = unit === "wei" ? BigInt(amount) : parseUnits(amount, 18);

    const gas = await checkGasSpike(args.network);
    if (gas.spiked) console.error(`[MCP] ${gas.message}`);

    console.error(`[MCP] Transferring ${amount} ${unit} to ${to} on ${net.name}`);

    const hash = await walletClient.sendTransaction({ to, value, chain: null });

    return safeResult(withSubskill({
      action: "transfer",
      network: net.name,
      to,
      amount: `${amount} ${unit}`,
      amountWei: value.toString(),
      txHash: hash,
      gasCheck: `current: ${gas.currentGwei} Gwei`,
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
    const skipGate = args.skipSecurityGate === true;
    const skipVerify = args.skipAutoVerify === true;
    const frontendPath = args.frontendPath || null;

    if (!process.env.PRIVATE_KEY) {
      return structuredError(new Error("PRIVATE_KEY not set in environment"), "deploy_erc20");
    }

    // 1. Security gate
    if (!skipGate) {
      const gate = await securityGate(join(PROJECT_ROOT, "contracts", "PharosERC20.sol"), args.network);
      if (gate && gate.blocked === true) {
        return structuredError(new Error(gate.message), "deploy_erc20");
      }
    }

    // 2. Gas check
    const gas = await checkGasSpike(args.network);
    if (gas.spiked) {
      console.error(`[MCP] ${gas.message}`);
    }

    console.error(`[MCP] Deploying ERC-20: ${name} (${symbol}) on ${net.name}`);

    const cmd = [
      "forge", "create",
      "contracts/PharosERC20.sol:PharosERC20",
      "--rpc-url", net.rpcUrl,
      "--constructor-args", name, symbol, supply,
    ];

    const env = { ...process.env, PRIVATE_KEY: process.env.PRIVATE_KEY };
    const output = execSync(cmd.join(" "), {
      cwd: PROJECT_ROOT,
      encoding: "utf-8",
      maxBuffer: 10 * 1024 * 1024,
      timeout: 120_000,
      stdio: ["pipe", "pipe", "pipe"],
      env,
    });

    const addressMatch = output.match(/Deployed to: (0x[a-fA-F0-9]{40})/);
    const contractAddress = addressMatch ? addressMatch[1] : null;

    // 3. Auto-verify
    let verifyResult = null;
    if (contractAddress && !skipVerify) {
      verifyResult = await autoVerify(args.network, contractAddress, "PharosERC20", `${name} ${symbol} ${supply}`);
    }

    // 4. Frontend sync
    let syncResult = null;
    if (contractAddress && frontendPath) {
      try {
        const abiPath = join(PROJECT_ROOT, "out", "PharosERC20.sol", "PharosERC20.json");
        const abiContent = existsSync(abiPath)
          ? JSON.stringify(JSON.parse(execSync(`cat "${abiPath}"`, { encoding: "utf-8" })).abi, null, 2)
          : "[]";
        syncResult = await syncFrontend(frontendPath, args.network, contractAddress, symbol, abiContent);
      } catch { /* skip */ }
    }

    return safeResult(withSubskill({
      action: "deploy_erc20",
      network: net.name,
      chainId: net.id,
      tokenName: name,
      tokenSymbol: symbol,
      initialSupply: supply,
      contractAddress,
      gasCheck: `current: ${gas.currentGwei} Gwei`,
      securityGate: skipGate ? "skipped" : "passed",
      autoVerify: verifyResult,
      frontendSync: syncResult,
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
    validateAddress(args.address, "getLogs address");
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
    const chainId = execSync("cast chain-id --rpc-url https://atlantic.dplabs-internal.com 2>/dev/null", { encoding: "utf8", stdio: ["pipe", "pipe", "pipe"] }).trim();
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
// Tool 12 — pharos_get_account (Pharos-specific RPC)
// ---------------------------------------------------------------------------
async function getPharosAccount(args) {
  validateAddress(args.address, "address");
  try {
    const result = await rpcCall(args.network, "eth_getAccount", [args.address, "latest"]);
    return safeResult(withSubskill({
      action: "get_account",
      network: getNetwork(args.network).name,
      address: args.address,
      balance: result.balance,
      nonce: result.nonce,
      codeHash: result.codeHash,
      storageRoot: result.storageRoot,
    }, "get_account"));
  } catch (err) { return structuredError(err, "get_account"); }
}

// ---------------------------------------------------------------------------
// Tool 13 — pharos_gas_estimate
// ---------------------------------------------------------------------------
async function estimateGas(args) {
  try {
    const [gasPrice, maxPriorityFee] = await Promise.all([
      rpcCall(args.network, "eth_gasPrice", []),
      rpcCall(args.network, "eth_maxPriorityFeePerGas", []),
    ]);
    const baseFee = (BigInt(gasPrice) - BigInt(maxPriorityFee)).toString();
    const net = getNetwork(args.network);
    return safeResult(withSubskill({
      action: "gas_estimate",
      network: net.name,
      gasPriceWei: gasPrice,
      baseFeeWei: baseFee,
      priorityFeeWei: maxPriorityFee,
      estimatedTxCostWei: (BigInt(gasPrice) * 21000n).toString(),
      estimatedTxCostFormatted: `${formatUnits(BigInt(gasPrice) * 21000n, 18)} ${net.nativeCurrency.symbol}`,
    }, "gas_estimate"));
  } catch (err) { return structuredError(err, "gas_estimate"); }
}

// ---------------------------------------------------------------------------
// Tool 14 — pharos_trace_transaction (Pharos enables debug_traceTransaction)
// ---------------------------------------------------------------------------
async function traceTransaction(args) {
  if (typeof args.txHash !== "string" || !/^0x[a-fA-F0-9]{64}$/.test(args.txHash)) {
    throw new Error("txHash: invalid transaction hash (must be 0x + 64 hex chars)");
  }
  try {
    const trace = await rpcCall(args.network, "debug_traceTransaction", [args.txHash, { tracer: "callTracer" }]);
    const net = getNetwork(args.network);
    return safeResult(withSubskill({
      action: "trace_transaction",
      network: net.name,
      txHash: args.txHash,
      trace,
      explorerUrl: `${net.explorer}/tx/${args.txHash}`,
    }, "trace_transaction", args));
  } catch (err) { return structuredError(err, "trace_transaction"); }
}

// ---------------------------------------------------------------------------
// Tool 15 — pharos_network_status (safe + finalized block tags are Pharos-specific)
// ---------------------------------------------------------------------------
async function networkStatus(args) {
  try {
    const [latest, safe, finalized, gasPrice] = await Promise.all([
      rpcCall(args.network, "eth_getBlockByNumber", ["latest", false]),
      rpcCall(args.network, "eth_getBlockByNumber", ["safe", false]),
      rpcCall(args.network, "eth_getBlockByNumber", ["finalized", false]),
      rpcCall(args.network, "eth_gasPrice", []),
    ]);

    const net = getNetwork(args.network);
    const latestNum = BigInt(latest.number);
    const safeNum = BigInt(safe.number);
    const finalizedNum = BigInt(finalized.number);

    return safeResult(withSubskill({
      action: "network_status",
      network: net.name,
      chainId: net.id,
      latestBlock: latestNum.toString(),
      safeBlock: safeNum.toString(),
      finalizedBlock: finalizedNum.toString(),
      blocksToSafe: (latestNum - safeNum).toString(),
      blocksToFinalized: (latestNum - finalizedNum).toString(),
      gasPriceWei: gasPrice,
      gasPriceGwei: (BigInt(gasPrice) / 1000000000n).toString(),
      currency: net.nativeCurrency.symbol,
    }, "network_status", args));
  } catch (err) { return structuredError(err, "network_status"); }
}

// ---------------------------------------------------------------------------
// Tool 16 — pharos_read_contract
// ---------------------------------------------------------------------------
function validateAbi(abi) {
  if (!Array.isArray(abi)) throw new Error("ABI must be a JSON array of function/event entries");
  if (abi.length === 0) throw new Error("ABI must contain at least one entry");
}

async function readContract(args) {
  const { network = "atlanticTestnet", address, abi: abiRaw, functionName, args: fnArgs = [], blockTag = "latest" } = args;
  validateAddress(address, "address");
  validateBlockTag(blockTag);
  let abi;
  try { abi = JSON.parse(abiRaw); } catch { throw new Error("abi must be a valid JSON array"); }
  validateAbi(abi);
  if (!functionName) throw new Error("functionName is required");

  const client = getClient(network);
  const result = await client.readContract({
    address: address,
    abi: abi,
    functionName: functionName,
    args: fnArgs,
    blockTag: blockTag,
  });

  return safeResult(withSubskill({
    action: "read_contract",
    network: getNetwork(network).name,
    chainId: getNetwork(network).id,
    contract: address,
    function: functionName,
    result: typeof result === "bigint" ? result.toString() : result,
  }, "read_contract", args));
}

// ---------------------------------------------------------------------------
// Tool 17 — pharos_write_contract (requires PRIVATE_KEY)
// ---------------------------------------------------------------------------
async function writeContract(args) {
  const { network = "atlanticTestnet", address, abi: abiRaw, functionName, args: fnArgs = [], value = "0", simulate = true } = args;
  validateAddress(address, "address");
  let abi;
  try { abi = JSON.parse(abiRaw); } catch { throw new Error("abi must be a valid JSON array"); }
  validateAbi(abi);
  if (!functionName) throw new Error("functionName is required");

  const wallet = getWalletClient(network);
  const net = getNetwork(network);

  const request = {
    address: address,
    abi: abi,
    functionName: functionName,
    args: fnArgs,
    value: BigInt(value),
    account: wallet.account,
    chain: { id: net.id, name: net.name, nativeCurrency: net.nativeCurrency, rpcUrls: { default: { http: [net.rpcUrl] } } },
  };

  if (simulate) {
    const client = getClient(network);
    const { request: simulated } = await client.simulateContract(request);
    return safeResult(withSubskill({
      action: "write_contract",
      simulated: true,
      network: net.name,
      contract: address,
      function: functionName,
      message: "Simulation passed. Set simulate=false to broadcast.",
    }, "write_contract", args));
  }

  const gas = await checkGasSpike(network);
  if (gas.spiked) console.error(`[MCP] ${gas.message}`);

  const hash = await wallet.writeContract(request);
  const explorerUrl = `${net.explorer}/tx/${hash}`;
  return safeResult(withSubskill({
    action: "write_contract",
    simulated: false,
    network: net.name,
    contract: address,
    function: functionName,
    txHash: hash,
    gasCheck: `current: ${gas.currentGwei} Gwei`,
    explorerUrl: explorerUrl,
  }, "write_contract", args));
}

// ---------------------------------------------------------------------------
// Tool 18 — pharos_fetch_abi
// ---------------------------------------------------------------------------
async function fetchAbi(args) {
  const { network = "atlanticTestnet", address } = args;
  validateAddress(address, "address");
  const net = getNetwork(network);

  const cacheKey = `${network}:${address.toLowerCase()}`;
  if (abiCache.has(cacheKey)) {
    const cached = abiCache.get(cacheKey);
    return safeResult(withSubskill({
      action: "fetch_abi",
      network: net.name,
      contract: address,
      verified: true,
      cached: true,
      abi: cached.abi,
      functions: cached.functions,
      events: cached.events,
    }, "fetch_abi", args));
  }

  const controller = new AbortController();
  const timeout = setTimeout(() => controller.abort(), RPC_TIMEOUT);
  let response;
  try {
    response = await fetch(`${net.explorerApi}?module=contract&action=getabi&address=${address}`, { signal: controller.signal });
  } finally {
    clearTimeout(timeout);
  }
  const data = await response.json();
  if (data.status !== "1") throw new Error(`Explorer API error: ${data.message || data.result || "ABI not found. Contract may not be verified."}`);

  let abi;
  try { abi = JSON.parse(data.result); } catch { throw new Error("Failed to parse ABI from explorer response"); }

  const functions = abi.filter(item => item.type === "function").map(f => `${f.name}(${(f.inputs || []).map(i => i.type).join(",")}) → ${(f.outputs || []).map(o => o.type).join(",")}`);
  const events = abi.filter(item => item.type === "event").map(e => `${e.name}(${(e.inputs || []).map(i => i.type).join(",")})`);

  abiCache.set(cacheKey, { abi: data.result, functions, events });

  return safeResult(withSubskill({
    action: "fetch_abi",
    network: net.name,
    contract: address,
    verified: true,
    abi: data.result,
    functions: functions,
    events: events,
  }, "fetch_abi", args));
}

// ---------------------------------------------------------------------------
// Tool 19 — pharos_frontend_sync
// ---------------------------------------------------------------------------
async function frontendSync(args) {
  try {
    const { network = "atlanticTestnet", address, contractName = "MyContract", frontendPath, abi: abiRaw } = args;
    validateAddress(address, "address");
    if (!frontendPath) throw new Error("frontendPath is required — path to your React/Next.js project root");

    const abiContent = abiRaw || "[]";
    const result = await syncFrontend(frontendPath, network, address, contractName, abiContent);

    return safeResult(withSubskill({
      action: "frontend_sync",
      contract: contractName,
      address,
      network,
      envFileWritten: result.envFile,
      abiFileWritten: result.abiFile,
      tip: ".env.local reloads automatically in dev. Restart your Next.js dev server to pick up new env vars.",
    }, "check_balance"));
  } catch (err) {
    return structuredError(err, "check_balance");
  }
}

// ---------------------------------------------------------------------------
// Tool 20 — pharos_create_safe_tx
// ---------------------------------------------------------------------------
function parseAbiForFunction(abi, fnName) {
  if (!abi || !Array.isArray(abi)) return null;
  return abi.find(e => e.type === "function" && e.name === fnName) || null;
}

async function createSafeTx(args) {
  try {
    const { network = "atlanticTestnet", to, value = "0", data = "0x", safeAddress, abi: abiRaw, functionName, fnArgs = [] } = args;
    if (safeAddress) validateAddress(safeAddress, "safeAddress");
    validateAddress(to, "to");
    const net = getNetwork(network);

    let txData = data;
    if (abiRaw && functionName) {
      const abi = typeof abiRaw === "string" ? JSON.parse(abiRaw) : abiRaw;
      const fnDef = parseAbiForFunction(abi, functionName);
      if (!fnDef) throw new Error(`Function "${functionName}" not found in ABI`);
      const iface = (await import("viem")).encodeFunctionData({ abi, functionName, args: fnArgs });
      txData = iface;
    }

    const safeTx = {
      to,
      value: typeof value === "string" && value.startsWith("0x") ? value : `0x${BigInt(value).toString(16)}`,
      data: txData,
      operation: 0,
      safeTxGas: 0,
      baseGas: 0,
      gasPrice: 0,
      gasToken: "0x0000000000000000000000000000000000000000",
      refundReceiver: "0x0000000000000000000000000000000000000000",
      nonce: args.nonce || 0,
    };

    return safeResult(withSubskill({
      action: "create_safe_tx",
      network: net.name,
      safeAddress: safeAddress || "not specified (provide safeAddress for proposal)",
      to,
      value,
      functionName: functionName || "raw transaction",
      safeTransaction: safeTx,
      nextStep: safeAddress
        ? "Use pharos_propose_safe_tx to submit this to the Safe Transaction Service."
        : "Provide a safeAddress to enable proposal. You can also submit this JSON manually via Safe UI.",
      note: "This is a standard Safe transaction format. Propose via Safe Transaction Service API or Safe {Wallet} UI.",
    }, "wallet-and-transaction-ui"));
  } catch (err) {
    return structuredError(err, "wallet-and-transaction-ui");
  }
}

// ---------------------------------------------------------------------------
// Tool 21 — pharos_propose_safe_tx
// ---------------------------------------------------------------------------
async function proposeSafeTx(args) {
  try {
    const { network = "atlanticTestnet", safeAddress, to, value = "0", data = "0x", safeTxGas = "0", nonce } = args;
    validateAddress(safeAddress, "safeAddress");
    validateAddress(to, "to");
    const net = getNetwork(network);

    const safeTxData = {
      to,
      value: typeof value === "string" && value.startsWith("0x") ? value : `0x${BigInt(value).toString(16)}`,
      data,
      operation: 0,
      safeTxGas: typeof safeTxGas === "string" && safeTxGas.startsWith("0x") ? safeTxGas : `0x${BigInt(safeTxGas).toString(16)}`,
      baseGas: "0x0",
      gasPrice: "0x0",
      gasToken: "0x0000000000000000000000000000000000000000",
      refundReceiver: "0x0000000000000000000000000000000000000000",
      nonce: nonce ? (typeof nonce === "string" && nonce.startsWith("0x") ? nonce : `0x${BigInt(nonce).toString(16)}`) : undefined,
    };

    const safeTxServiceUrl = net.testnet
      ? `https://safe-transaction-atlantistestnet.safe.global`
      : `https://safe-transaction-mainnet.safe.global`;

    return safeResult(withSubskill({
      action: "propose_safe_tx",
      network: net.name,
      safeAddress,
      safeTransaction: safeTxData,
      apiEndpoint: `${safeTxServiceUrl}/api/v1/safes/${safeAddress}/multisig-transactions/`,
      status: "ready_for_signing",
      message: "This transaction is ready for off-chain signatures via the Safe Transaction Service.",
      nextSteps: [
        `POST to ${safeTxServiceUrl}/api/v1/safes/${safeAddress}/multisig-transactions/ with the above payload signed by one owner.`,
        "Use a Safe API client or the Safe UI at https://app.safe.global to propose and collect signatures.",
        "Once enough confirmations are collected, anyone can execute the transaction.",
      ],
      note: "Safe {Wallet} is the standard multi-sig for Pharos (EVM-compatible). Use the Atlantic testnet Safe app for testing.",
    }, "wallet-and-transaction-ui"));
  } catch (err) {
    return structuredError(err, "wallet-and-transaction-ui");
  }
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
  pharos_get_account: { description: "Fetch account details (balance, nonce, codeHash, storageRoot) via Pharos-specific eth_getAccount RPC", subskill: "wallet-and-transaction-ui" },
  pharos_gas_estimate: { description: "Estimate current gas prices and transaction costs on a Pharos network", subskill: "gas-optimization" },
  pharos_trace_transaction: { description: "Trace a transaction using debug_traceTransaction with callTracer — enabled on Pharos (most chains disable this)", subskill: "bug-finding-and-debugging" },
  pharos_network_status: { description: "Check network status: safe & finalized block numbers, gas prices — Pharos has unique safe/finalized block tags", subskill: "production-ops" },
  pharos_read_contract: { description: "Call any view/pure function on a deployed contract using its ABI (e.g., balanceOf, totalSupply, ownerOf)", subskill: "contract-review" },
  pharos_write_contract: { description: "Call any state-changing function on a deployed contract using its ABI. Supports simulation mode (default) before broadcasting", subskill: "wallet-and-transaction-ui" },
  pharos_fetch_abi: { description: "Download the verified ABI JSON for a contract from PharosScan explorer", subskill: "contract-review" },
  pharos_frontend_sync: { description: "Sync deployed contract address and ABI to a frontend project (.env.local + abis/)", subskill: "frontend-dapp-integration" },
  pharos_create_safe_tx: { description: "Build a Safe transaction payload for multi-sig execution (Gnosis Safe)", subskill: "wallet-and-transaction-ui" },
  pharos_propose_safe_tx: { description: "Prepare a Safe multi-sig transaction for proposal via Safe Transaction Service", subskill: "wallet-and-transaction-ui" },
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
      skipSecurityGate: { type: "boolean", description: "Skip auto slither security scan", default: false },
      skipAutoVerify: { type: "boolean", description: "Skip post-deploy verification on PharosScan", default: false },
      contractName: { type: "string", description: "Contract name for security gate lookup (e.g., Counter)", default: "Counter" },
      constructorArgs: { type: "string", description: "Constructor args to pass to auto-verify API" },
      frontendPath: { type: "string", description: "Auto-sync to frontend project path (.env.local + abis/)" },
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
      skipSecurityGate: { type: "boolean", description: "Skip auto slither security scan", default: false },
      skipAutoVerify: { type: "boolean", description: "Skip post-deploy auto-verification", default: false },
      frontendPath: { type: "string", description: "Auto-sync to frontend project path (.env.local + abis/)" },
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
  pharos_get_account: {
    type: "object",
    properties: {
      network: { type: "string", enum: ["atlanticTestnet", "pacificMainnet"], default: "atlanticTestnet" },
      address: { type: "string", description: "Wallet address (0x...)" },
    },
    required: ["address"],
  },
  pharos_gas_estimate: {
    type: "object",
    properties: {
      network: { type: "string", enum: ["atlanticTestnet", "pacificMainnet"], default: "atlanticTestnet" },
    },
  },
  pharos_trace_transaction: {
    type: "object",
    properties: {
      network: { type: "string", enum: ["atlanticTestnet", "pacificMainnet"] },
      txHash: { type: "string", description: "Transaction hash to trace (0x...)" },
    },
    required: ["txHash"],
  },
  pharos_network_status: {
    type: "object",
    properties: {
      network: { type: "string", enum: ["atlanticTestnet", "pacificMainnet"], default: "atlanticTestnet" },
    },
  },
  pharos_read_contract: {
    type: "object",
    properties: {
      network: { type: "string", enum: ["atlanticTestnet", "pacificMainnet"], default: "atlanticTestnet" },
      address: { type: "string", description: "Contract address (0x...)" },
      abi: { type: "string", description: "Contract ABI as a JSON array string" },
      functionName: { type: "string", description: "Function name to call (e.g., balanceOf)" },
      args: { type: "array", items: {}, description: "Function arguments as JSON array" },
      blockTag: { type: "string", default: "latest", enum: ["latest", "safe", "finalized"] },
    },
    required: ["address", "abi", "functionName"],
  },
  pharos_write_contract: {
    type: "object",
    properties: {
      network: { type: "string", enum: ["atlanticTestnet", "pacificMainnet"], default: "atlanticTestnet" },
      address: { type: "string", description: "Contract address (0x...)" },
      abi: { type: "string", description: "Contract ABI as a JSON array string" },
      functionName: { type: "string", description: "Function name to call (e.g., transfer)" },
      args: { type: "array", items: {}, description: "Function arguments as JSON array" },
      value: { type: "string", default: "0", description: "ETH value to send in wei" },
      simulate: { type: "boolean", default: true, description: "If true, simulate only (no broadcast)" },
    },
    required: ["address", "abi", "functionName"],
  },
  pharos_fetch_abi: {
    type: "object",
    properties: {
      network: { type: "string", enum: ["atlanticTestnet", "pacificMainnet"], default: "atlanticTestnet" },
      address: { type: "string", description: "Contract address (0x...)" },
    },
    required: ["address"],
  },
  pharos_frontend_sync: {
    type: "object",
    properties: {
      network: { type: "string", enum: ["atlanticTestnet", "pacificMainnet"], default: "atlanticTestnet" },
      address: { type: "string", description: "Deployed contract address (0x...)" },
      contractName: { type: "string", description: "Contract name (e.g., Counter)", default: "MyContract" },
      frontendPath: { type: "string", description: "Absolute path to frontend project root (e.g., /home/user/my-dapp)" },
      abi: { type: "string", description: "Contract ABI as JSON array (optional — pass from fetch_abi result)" },
    },
    required: ["address", "frontendPath"],
  },
  pharos_create_safe_tx: {
    type: "object",
    properties: {
      network: { type: "string", enum: ["atlanticTestnet", "pacificMainnet"], default: "atlanticTestnet" },
      safeAddress: { type: "string", description: "Safe wallet address (0x...)" },
      to: { type: "string", description: "Destination contract address (0x...)" },
      value: { type: "string", description: "Value in wei (string)", default: "0" },
      data: { type: "string", description: "Raw calldata (0x...). Omit if using abi+functionName", default: "0x" },
      abi: { type: "string", description: "Contract ABI to encode function call" },
      functionName: { type: "string", description: "Function name to call (e.g., transfer)" },
      fnArgs: { type: "array", items: {}, description: "Function arguments as array" },
      nonce: { type: "number", description: "Safe transaction nonce (auto if omitted)" },
    },
    required: ["to"],
  },
  pharos_propose_safe_tx: {
    type: "object",
    properties: {
      network: { type: "string", enum: ["atlanticTestnet", "pacificMainnet"], default: "atlanticTestnet" },
      safeAddress: { type: "string", description: "Safe wallet address (0x...)" },
      to: { type: "string", description: "Destination contract address (0x...)" },
      value: { type: "string", description: "Value in wei", default: "0" },
      data: { type: "string", description: "Calldata (0x...)", default: "0x" },
      safeTxGas: { type: "string", description: "Gas limit for safe tx", default: "0" },
      nonce: { type: "number", description: "Safe transaction nonce" },
    },
    required: ["safeAddress", "to", "data"],
  },
};

server.setRequestHandler(ListToolsRequestSchema, async () => ({
  tools: Object.entries(TOOL_META).map(([name, meta]) => ({
    name,
    description: meta.description,
    inputSchema: TOOL_SCHEMAS[name] || { type: "object", properties: {} },
  })),
}));

server.setRequestHandler(CallToolRequestSchema, async (request) => {
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
      case "pharos_get_account": return await getPharosAccount(args);
      case "pharos_gas_estimate": return await estimateGas(args);
      case "pharos_trace_transaction": return await traceTransaction(args);
      case "pharos_network_status": return await networkStatus(args);
      case "pharos_read_contract": return await readContract(args);
      case "pharos_write_contract": return await writeContract(args);
      case "pharos_fetch_abi": return await fetchAbi(args);
      case "pharos_frontend_sync": return await frontendSync(args);
      case "pharos_create_safe_tx": return await createSafeTx(args);
      case "pharos_propose_safe_tx": return await proposeSafeTx(args);
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
console.error("Pharos MCP Server running on stdio — 21 tools");
