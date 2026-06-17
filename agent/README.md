# Agent Demos

This directory contains **real MCP client demos** that connect to the Pharos MCP server via stdio transport and execute tools — exactly as an AI agent would.

| Demo | File | Tools Called | Requires PRIVATE_KEY? |
|------|------|-------------|----------------------|
| **MCP Quick Demo** | `mcp-demo.mjs` | 6 read-only tools (network, diagnose, gas, status, account, balance) | No |
| **Token Workflow** | `token-workflow.mjs` | 8 tools — full lifecycle (deploy ERC-20, check balance, transfer, logs) | Only for real deployment |
| **Cascade Demo** | `cascade-demo.mjs` | 5 tools — shows skill layer → tool layer → on-chain result | No |

## Why This Matters

These demos prove the **Phase 2 Skill-to-Agent Dual Cascade** pipeline:

1. **Skill Creator** → writes subskills and MCP tools (this repo)
2. **Agent** → reads subskills, calls MCP tools (simulated here via stdio)
3. **Blockchain** → result on Pharos Atlantic Testnet / Pacific Mainnet

## Usage

```bash
# Quick demo (no key needed — 6 read-only tools)
node agent/mcp-demo.mjs

# Token workflow (no key = simulation, with key = real on-chain)
export PRIVATE_KEY=0x...
node agent/token-workflow.mjs

# Cascade demo (prints the skill→tool→blockchain flow)
node agent/cascade-demo.mjs
```

## Expected Output (token-workflow.mjs)

```
  ✅ Connected — 21 tools available

  ⚠  PRIVATE_KEY not set — deploys/transfers will be simulated

  ──────────────────────────────────────────────────────
    Step 1/8  pharos_network_config — Target Network
  ──────────────────────────────────────────────────────

    ◆ Atlantic Testnet
      Chain 688689 — https://atlantic.dplabs-internal.com

  ──────────────────────────────────────────────────────
    Step 4/8  pharos_deploy_erc20 — Token Deployment
  ──────────────────────────────────────────────────────
  ...
  ──────────────────────────────────────────────────────
    Token Workflow Complete — simulated through MCP
    21 tools registered
  ──────────────────────────────────────────────────────
```

## Extending

Add new workflows by composing MCP tools:

- **Audit Pipeline**: `deploy_contract` → `run_security_check` → `generate_tests`
- **Deploy & Verify**: `deploy_contract` → `verify_contract` → `contract_info`
- **Monitor**: `check_balance` → `get_logs` → `contract_info`
