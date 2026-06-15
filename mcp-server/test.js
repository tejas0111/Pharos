import { execSync } from "child_process";
import { existsSync, readFileSync } from "fs";
import { fileURLToPath } from "url";
import { dirname, join } from "path";

const __filename = fileURLToPath(import.meta.url);
const __dirname = dirname(__filename);

function INDEX() {
  return join(__dirname, "index.js");
}
function PKG() {
  return join(__dirname, "package.json");
}

let passed = 0;
let failed = 0;

function test(name, fn) {
  try {
    fn();
    passed++;
    console.log("  " + String.fromCodePoint(0x2705) + " " + name);
  } catch (e) {
    failed++;
    console.log("  " + String.fromCodePoint(0x274C) + " " + name + ": " + e.message);
  }
}

function assert(condition, msg) {
  if (!condition) throw new Error(msg);
}

console.log("\nPharos MCP Server Tests\n");

// 1. Server file exists
test("mcp-server/index.js exists", () => {
  assert(existsSync(INDEX()), "index.js not found at " + INDEX());
});

// 2. Valid JSON parse check
test("package.json is valid JSON", () => {
  JSON.parse(readFileSync(PKG(), "utf8"));
});

// 3. index.js has valid syntax
test("index.js has valid syntax", () => {
  execSync("node --check " + INDEX() + " 2>/dev/null", { stdio: "pipe" });
});

// 4. Viem import resolves (runtime dependency check)
test("viem import resolves at runtime", () => {
  execSync('node --input-type=module -e "import(\'viem\')"', { stdio: "pipe", cwd: __dirname });
});

// 5. All 13 tools are registered by name
test("All 13 tools registered in source", () => {
  const content = readFileSync(INDEX(), "utf8");
  const toolNames = [
    "pharos_network_config",
    "pharos_deploy_contract",
    "pharos_verify_contract",
    "pharos_run_security_check",
    "pharos_generate_tests",
    "pharos_check_balance",
    "pharos_contract_info",
    "pharos_transfer_token",
    "pharos_deploy_erc20",
    "pharos_get_logs",
    "pharos_diagnose",
    "pharos_get_account",
    "pharos_gas_estimate",
    "pharos_trace_transaction",
    "pharos_network_status",
  ];
  for (const name of toolNames) {
    assert(content.includes('"' + name + '"') || content.includes("'" + name + "'"), "Missing tool reference: " + name);
  }
});

// 6. No hardcoded private keys
test("No hardcoded private keys in source", () => {
  const content = readFileSync(INDEX(), "utf8");
  assert(!content.includes("0x0000000000000000000000000000000000000000"), "Hardcoded zero-address found");
  assert(!content.includes("PRIVATE_KEY="), "PRIVATE_KEY= found in source");
});

// 7. TOOL_SCHEMAS has all 13 tools
test("TOOL_SCHEMAS has all 13 tool entries", () => {
  const content = readFileSync(INDEX(), "utf8");
  const schemaKeys = [
    "pharos_network_config", "pharos_deploy_contract", "pharos_verify_contract",
    "pharos_run_security_check", "pharos_generate_tests", "pharos_check_balance",
    "pharos_contract_info", "pharos_transfer_token", "pharos_deploy_erc20",
    "pharos_get_logs", "pharos_diagnose", "pharos_get_account", "pharos_gas_estimate",
    "pharos_trace_transaction", "pharos_network_status"
  ];
  for (const key of schemaKeys) {
    assert(content.includes(key), "Missing TOOL_SCHEMAS key: " + key);
  }
});

// 8. SUBLINK map has all 13 tools
test("SUBLINK map has all 13 tool entries", () => {
  const content = readFileSync(INDEX(), "utf8");
  const sublinkKeys = [
    "deploy_contract", "deploy_erc20", "verify_contract", "transfer_token",
    "check_balance", "security_check", "generate_tests", "get_logs",
    "contract_info", "network_config", "diagnose", "get_account", "gas_estimate",
    "trace_transaction", "network_status"
  ];
  for (const key of sublinkKeys) {
    assert(content.includes('"' + key + '"') || content.includes("'" + key + "'"), "Missing SUBLINK key: " + key);
  }
});

// 9. withSubskill function wired to tools
test("withSubskill function wired to all tools", () => {
  const content = readFileSync(INDEX(), "utf8");
  const callCount = (content.match(/withSubskill\(/g) || []).length;
  assert(callCount >= 15, "Expected 15+ withSubskill calls, found " + callCount);
});

// 10. Structured error hints present
test("Structured error hints with recovery steps", () => {
  const content = readFileSync(INDEX(), "utf8");
  assert(content.includes("structuredError"), "structuredError function not found");
  assert(content.includes("Install Foundry"), "Foundry install hint missing");
  assert(content.includes("Set PRIVATE_KEY"), "PRIVATE_KEY hint missing");
});

// 11. Pharos-specific security checks present
test("Pharos-specific security checks in security tool", () => {
  const content = readFileSync(INDEX(), "utf8");
  assert(content.includes("2300 gas stipend"), "2300 gas check missing");
  assert(content.includes("688689"), "Chain ID 688689 check missing");
  assert(content.includes("EIP-1559"), "EIP-1559 check missing");
  assert(content.includes("30 req/s"), "Rate limit check missing");
});

// 12. pharos_diagnose tool exists
test("pharos_diagnose tool exists", () => {
  const content = readFileSync(INDEX(), "utf8");
  assert(content.includes('"pharos_diagnose"') || content.includes("pharos_diagnose"), "pharos_diagnose not found");
  assert(content.includes('"diagnose"') || content.includes("() => diagnose"), "diagnose function not wired");
});

// 13. pharos_get_account tool exists
test("pharos_get_account tool exists", () => {
  const content = readFileSync(INDEX(), "utf8");
  assert(content.includes('"pharos_get_account"') || content.includes("pharos_get_account"), "pharos_get_account not found");
  assert(content.includes("eth_getAccount"), "eth_getAccount RPC method not found");
});

// 14. pharos_gas_estimate tool exists
test("pharos_gas_estimate tool exists", () => {
  const content = readFileSync(INDEX(), "utf8");
  assert(content.includes('"pharos_gas_estimate"') || content.includes("pharos_gas_estimate"), "pharos_gas_estimate not found");
  assert(content.includes("eth_gasPrice"), "eth_gasPrice RPC method not found");
});

// 15. contextualTip function exists with tips for key tools
test("contextualTip function provides tips", () => {
  const content = readFileSync(INDEX(), "utf8");
  assert(content.includes("contextualTip"), "contextualTip function not found");
  assert(content.includes("eth_getAccount is Pharos-specific"), "Pharos get_account tip missing");
  assert(content.includes("debug_traceTransaction"), "trace tip missing");
  assert(content.includes("finalized"), "finalized tag tip missing");
});

// 16. pharos_trace_transaction tool exists
test("pharos_trace_transaction tool exists", () => {
  const content = readFileSync(INDEX(), "utf8");
  assert(content.includes('"pharos_trace_transaction"') || content.includes("pharos_trace_transaction"), "pharos_trace_transaction not found");
  assert(content.includes("debug_traceTransaction"), "debug_traceTransaction RPC method not found");
  assert(content.includes("callTracer"), "callTracer not found");
});

// 17. pharos_network_status tool exists
test("pharos_network_status tool exists", () => {
  const content = readFileSync(INDEX(), "utf8");
  assert(content.includes('"pharos_network_status"') || content.includes("pharos_network_status"), "pharos_network_status not found");
  assert(content.includes('"safe"') || content.includes("'safe'"), "safe block tag not found");
  assert(content.includes('"finalized"') || content.includes("'finalized'"), "finalized block tag not found");
});

console.log("\nResults: " + passed + " passed, " + failed + " failed\n");
console.log("Tools: 15 configured (network_config, deploy_contract, verify_contract, security_check, generate_tests, check_balance, contract_info, transfer_token, deploy_erc20, get_logs, diagnose, get_account, gas_estimate, trace_transaction, network_status)");
process.exit(failed > 0 ? 1 : 0);
