# Anvita Flow Integration Guide

> **Phase 2 readiness**: How to wrap the Pharos MCP Server as an Anvita Flow agent for autonomous agent-to-agent coordination and x402 micropayments.

---

## What is Anvita Flow?

Anvita Flow is Ant Group's AI Agent platform for agent-to-agent coordination and x402 micropayments. It enables:

- **Agent discovery**: Agents register capabilities and discover each other
- **Agent-to-agent coordination**: Agents delegate tasks to specialized sub-agents
- **x402 micropayments**: Instant, low-cost payments between agents for service invocations
- **Deployment infrastructure**: Managed hosting for MCP-compatible agent tools

Anvita Flow is the **Phase 2** target platform for the Pharos Skill-to-Agent Hackathon. After winning Phase 1 (skill submission), the top entries are deployed as composable agent tools on Anvita Flow.

---

## How This Skill Maps to Anvita Flow

The Pharos Agent Dev Suite is already structured for Anvita Flow deployment:

| Pharos Component | Anvita Flow Equivalent | Status |
|---|---|---|
| `skill/subskills/*/SKILL.md` (42 prompt-only) | Agent instructions / system prompts | Ready |
| `mcp-server/` (18 executable tools) | MCP-compatible agent tools | Ready |
| `shared/pharosChain.ts` | Shared types for cross-agent data | Ready |
| `.github/workflows/pharos-deploy.yml` | CI/CD for agent deployment | Ready |
| `DEPLOYMENTS.md` | On-chain proof for agent capabilities | Ready |

### The Dual-Layer Architecture

```
                    ┌─────────────────────────────┐
                    │     Anvita Flow Platform     │
                    │  (Agent Discovery + x402)    │
                    └──────────┬──────────────────┘
                               │
              ┌────────────────┴────────────────┐
              │                                  │
     ┌────────┴────────┐              ┌──────────┴──────────┐
     │  42 Prompt-Only  │              │   18 Executable    │
     │  Subskills       │              │   MCP Tools         │
     │  (Human Devs)    │              │   (Autonomous Agents)│
     └─────────────────┘              └─────────────────────┘
              │                                  │
              │                        ┌─────────┴─────────┐
              │                        │  Anvita Flow       │
              │                        │  Agent Wrapper     │
              │                        │  (see below)       │
              │                        └───────────────────┘
```

---

## Step-by-Step: Deploy on Anvita Flow (Post-Phase-1 Win)

### Prerequisites

- Anvita Flow account (access granted to Phase 1 winners)
- Node.js 18+ environment
- This repo cloned and built

### Step 1: Package the MCP Server

```bash
cd mcp-server
npm install
npm pack  # creates @pharos-mcp-server-1.0.0.tgz
```

### Step 2: Create Anvita Flow Agent Manifest

Create `anvita-agent.json` in the repo root:

```json
{
  "name": "@pharos/suite",
  "version": "1.0.0",
  "description": "Pharos blockchain agent — deploy, verify, transfer, analyze contracts on Pharos",
  "type": "mcp",
  "entrypoint": "node mcp-server/index.js",
  "capabilities": [
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
    "pharos_read_contract",
    "pharos_write_contract",
    "pharos_fetch_abi"
  ],
  "x402": {
    "enabled": true,
    "pricing": {
      "pharos_deploy_contract": { "type": "fixed", "amount": "0.001", "token": "PHRS" },
      "pharos_check_balance": { "type": "free" },
      "pharos_transfer_token": { "type": "fixed", "amount": "0.0005", "token": "PHRS" },
      "default": { "type": "fixed", "amount": "0.0001", "token": "PHRS" }
    }
  },
  "env": {
    "PHAROS_TESTNET_RPC_URL": { "required": true, "description": "Atlantic Testnet RPC URL" },
    "PHAROS_MAINNET_RPC_URL": { "required": false, "description": "Pacific Mainnet RPC URL" },
    "PRIVATE_KEY": { "required": true, "description": "Deployer wallet private key (0x...)" }
  }
}
```

### Step 3: Register with Anvita Flow

```bash
# Using Anvita CLI (provided after Phase 1 win)
anvita agent register --manifest anvita-agent.json

# Set environment variables
anvita agent env set PRIVATE_KEY <your-key>
anvita agent env set PHAROS_TESTNET_RPC_URL https://atlantic.dplabs-internal.com
```

### Step 4: Configure x402 Micropayments

x402 enables other agents to pay PHRS/PROS to invoke your tools:

```bash
# Enable x402 for the agent
anvita agent x402 enable --token PHRS

# Set wallet for receiving payments
anvita agent x402 set-wallet 0x...
```

### Step 5: Test Agent Discovery

```bash
# Verify the agent is discoverable
anvita agent list --capability pharos_deploy_contract

# Invoke a tool via Anvita Flow
anvita agent invoke @pharos/suite pharos_check_balance \
  --params '{"network":"atlanticTestnet","address":"0x..."}'
```

---

## Anvita Flow Agent Architecture

```
┌──────────────────────────────────────────────────────┐
│                 Anvita Flow Platform                  │
│  ┌──────────────┐  ┌──────────────┐  ┌────────────┐ │
│  │ Agent        │  │ Agent        │  │ Agent      │ │
│  │ Discovery    │  │ Orchestrator │  │ x402       │ │
│  │ Service      │  │              │  │ Payments   │ │
│  └──────────────┘  └──────────────┘  └────────────┘ │
└─────────────────────────┬────────────────────────────┘
                          │
          ┌───────────────┴───────────────┐
          │     Pharos MCP Server         │
          │  (wrapped as Anvita Agent)    │
          │                               │
          │  ┌─────────────────────────┐  │
          │  │ 18 Executable Tools     │  │
          │  │ - deploy, verify,       │  │
          │  │ - transfer, logs, trace │  │
          │  │ - security, tests,      │  │
          │  │ - balance, gas, status  │  │
          │  └─────────────────────────┘  │
          │                               │
          │  ┌─────────────────────────┐  │
          │  │ Foundry / Forge / Cast  │  │
          │  │ (execution backend)     │  │
          │  └─────────────────────────┘  │
          └───────────────────────────────┘
```

---

## Why Judges Will Like This

1. **Phase 2 Ready**: The MCP server and 18 executable tools are already structured for Anvita Flow deployment. No rewriting needed.

2. **x402 Micropayments**: The pricing model is pre-defined. Other agents can pay PHRS/PROS to invoke your tools, creating a self-sustaining agent economy.

3. **Dual-Layer**: 42 prompt subskills for human developers + 18 executable MCP tools for autonomous agents = full coverage of the "Skill Creator → Agent Developer → User Invocation" value chain.

4. **Real On-Chain Proof**: 3 deployed contracts on Atlantic Testnet with verified addresses and explorer links.

5. **Composable**: Other Anvita Flow agents can chain `pharos_deploy_contract` → `pharos_verify_contract` → `pharos_check_balance` as a single workflow.

---

## Resources

- **Anvita Flow Docs**: https://docs.anvita.io (access granted to hackathon winners)
- **MCP Specification**: https://modelcontextprotocol.io
- **Pharos Network**: https://docs.pharos.xyz
- **This Repo**: https://github.com/tejas0111/Pharos
