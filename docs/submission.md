# Pharos Agent Dev Suite

## One-Liner
**42 agent skills + 21 MCP tools + live on-chain deployment proof for building on Pharos (Atlantic Testnet / Pacific Mainnet).**

---

## What It Is

The Pharos Agent Dev Suite is a comprehensive skill package that turns any AI coding agent (Codex, Claude Code, OpenCode, Gemini CLI) into a Pharos blockchain specialist. With 42 finely-grained subskills spanning architecture, Solidity authoring, deployment, frontend dapp integration, security auditing, and production operations — plus 21 executable MCP tools for autonomous agents — it provides end-to-end coverage for Pharos development.

## Key Differentiators

### ✅ Live On-Chain Deployment
We don't just talk about Pharos — we prove it. Three contracts deployed to Pharos Atlantic Testnet (chain 688689):

- **Counter**: <a href="https://atlantic.pharosscan.xyz/address/0x55ec4b1e32537b6f72aa20153735709837488e4e" target="_blank" rel="noopener noreferrer">`0x55ec4b1e32537b6f72aa20153735709837488e4e`</a>
- **Storage**: <a href="https://atlantic.pharosscan.xyz/address/0x2527FDc8C6FdF7C5239f005D94Cc7dC6173d34f0" target="_blank" rel="noopener noreferrer">`0x2527FDc8C6FdF7C5239f005D94Cc7dC6173d34f0`</a>
- **PharosERC20**: <a href="https://atlantic.pharosscan.xyz/address/0x3636F1BBcc56D1b5a22F8B778494D1553d95B4CD" target="_blank" rel="noopener noreferrer">`0x3636F1BBcc56D1b5a22F8B778494D1553d95B4CD`</a>

**Deployer**: `0x735367687d6a701466840321eD8e34E4DafE84aC`
**Network**: Atlantic Testnet (688689, PHRS)

### 🎯 42 Focused Subskills + 21 MCP Tools

Dual-layer design: instruction subskills for human developers and executable MCP tools for autonomous AI agents.

**21 MCP Tools:**

| # | Tool | Description | Executes? |
|---|------|-------------|-----------|
| 1 | `pharos_network_config` | Get network configuration (RPC, chain ID, explorer) | Static |
| 2 | `pharos_deploy_contract` | Deploy a compiled contract via `forge script` | Yes |
| 3 | `pharos_verify_contract` | Verify contract on PharosScan via explorer API | Yes |
| 4 | `pharos_run_security_check` | Run `slither` + structured security review | Yes |
| 5 | `pharos_generate_tests` | Write Foundry test file to disk | Yes |
| 6 | `pharos_check_balance` | Check PHRS/PROS balance via RPC | Yes |
| 7 | `pharos_contract_info` | Fetch contract metadata from explorer API | Yes |
| 8 | `pharos_transfer_token` | Send PHRS/PROS using walletClient | Yes |
| 9 | `pharos_deploy_erc20` | Deploy ERC-20 token via `forge create` | Yes |
| 10 | `pharos_get_logs` | Fetch event logs with block range | Yes |
| 11 | `pharos_diagnose` | Check environment: deps, RPC, env vars | Yes |
| 12 | `pharos_get_account` | Get account state via Pharos-specific `eth_getAccount` RPC | Yes |
| 13 | `pharos_gas_estimate` | Estimate gas prices with EIP-1559 breakdown | Yes |
| 14 | `pharos_trace_transaction` | Trace a tx with `debug_traceTransaction` (Pharos enables this) | Yes |
| 15 | `pharos_network_status` | Check safe/finalized block numbers and gas prices | Yes |
| 16 | `pharos_read_contract` | Call any view/pure function on a deployed contract via its ABI | Yes |
| 17 | `pharos_write_contract` | Call any state-changing function via ABI (simulate then broadcast) | Yes |
| 18 | `pharos_fetch_abi` | Download verified ABI JSON from PharosScan explorer | Yes |
| 19 | `pharos_frontend_sync` | Sync deployed contract address and ABI to a frontend project | Yes |
| 20 | `pharos_create_safe_tx` | Build a Safe transaction payload for multi-sig execution | Yes |
| 21 | `pharos_propose_safe_tx` | Prepare a Safe multi-sig transaction for proposal via Safe Transaction Service | Yes |

**42 Subskills by Category:**

| Category | Subskills |
|---|---|
| **Contract Work** | architecture, Solidity authoring, interface/ABI design, protocol integration, upgrade patterns, RWA compliance |
| **Frontend & UX** | dapp integration, wallet/transaction UI, Next.js App Router, React hooks, Tailwind/shadcn, wagmi/viem |
| **Testing & Review** | strategy, test generation, contract review, bug debugging, network-specific testing |
| **Deployment** | deployment prep, testnet deploy, mainnet deploy, post-deploy ops, verification |
| **Security** | contract review, security audit, gas optimization, access control review |
| **Infrastructure** | Foundry/Hardhat workflows, Remix, CI troubleshooting, monorepo management |
| **Quality** | refactoring, performance optimization, accessibility, state management, dependency upgrades |
| **Operations** | production ops, cross-chain bridge, SPN development, workflow orchestration |

### 🛡️ Risk-Gated Workflow

Every subskill has an explicit risk level (High/Medium/Low) with a two-phase execution model:
1. **Phase 1** — agent freely drafts plans, code, and artifacts
2. **Phase 2** — agent waits for user approval before executing or broadcasting

High-risk operations (deployments, security changes, upgrades) require explicit user confirmation. No surprise transactions.

### 🆚 Why This Entry

| Dimension | This Entry | Typical Entry |
|---|---|---|
| Format | **Dual-layer**: subskills + MCP tools | Single format only |
| On-chain proof | **3 verified contracts** on Atlantic testnet | No deployment or code only |
| Tool count | **42 subskills + 21 MCP tools** | Under 10 skills |
| Pharos-specific | SPN, safe/finalized tags, eth_getAccount, no-2300-gas patterns | Generic EVM advice |
| Live demo | `node agent/mcp-demo.mjs` calls 6 tools through the real MCP server | No demo or single command |
| Phase 2 ready | Anvita Flow integration (x402 micropayments) documented | No forward planning |

### 🌐 Pharos-Native Intelligence

The suite encodes Pharos-specific gotchas that generic agents miss:
- **No 2300 gas stipend** for native PHRS/PROS transfers
- **Correct chain IDs**: Atlantic Testnet (688689, PHRS) vs Pacific Mainnet (1672, PROS)
- **EIP-1559 fee model** with base fee burn and priority fee to validators
- **`debug_traceTransaction` enabled** on Pharos (most chains disable this)
- **`safe` and `finalized` block tags** for production reads
- **`eth_getAccount`** returns balance, nonce, codeHash, storageRoot in one call
- **Multi-platform support**: Foundry, Hardhat, Remix, wagmi/viem, ethers

### 📦 Multi-Platform Ready

Works across all major AI coding assistants:
- **Codex** → `~/.codex/skills/pharos-agent-dev-suite/`
- **Claude Code** → `~/.claude/skills/pharos-agent-dev-suite/`
- **OpenCode** → `opencode.json` skills config
- **Gemini CLI** → `~/.gemini/skills/pharos-agent-dev-suite/`
- **npx** → `npx skills add https://github.com/tejas0111/Pharos`

## Quick Start

```bash
# 1. Run the MCP demo (no PRIVATE_KEY needed — 6 read-only tools)
node agent/mcp-demo.mjs

# 2. Full token workflow (set PRIVATE_KEY for real on-chain)
node agent/token-workflow.mjs

# 3. Deploy Counter to testnet with forge
forge script script/Deploy.s.sol:DeployCounter --rpc-url https://atlantic.dplabs-internal.com --broadcast
```

See the <a href="https://github.com/tejas0111/Pharos#try-it-now" target="_blank" rel="noopener noreferrer">README</a> for the full Try It Now quickstart.

## Technical Architecture

```
skill/
  SKILL.md                 # Master routing & orchestration (1.2.0)
  subskills/*/SKILL.md     # 42 focused subskills
  references/*.md          # Network context, deployment patterns, harness
  scripts/*.sh             # Deploy & verify scripts for Foundry

contracts/                 # Example Solidity contracts (3 deployed)
test/                      # Foundry tests (30 passing)
script/                    # Forge deploy scripts
config/                    # Pharos network configuration
shared/                     # viem defineChain configs
mcp-server/                # MCP server with 21 executable tools
.github/workflows/         # CI/CD deploy pipeline
DEPLOYMENTS.md             # Live on-chain deployment proof
```

## How It Works

1. **Agent classifies** the request into the appropriate subskill
2. **Gathers minimal context** (stack, repo structure, affected files)
3. **Drafts a concrete plan** with explicit assumptions
4. **Presents plan for review** — high-risk tasks wait for approval
5. **Executes surgically** — makes the smallest useful change
6. **Verifies immediately** — compile → unit test → build

## Pharos Networks

| Network | Chain ID | Explorer | Faucet |
|---|---|---|---|
| Atlantic Testnet | 688689 | <a href="https://atlantic.pharosscan.xyz" target="_blank" rel="noopener noreferrer">atlantic.pharosscan.xyz</a> | <a href="https://testnet.pharosnetwork.xyz" target="_blank" rel="noopener noreferrer">testnet.pharosnetwork.xyz</a> |
| Pacific Mainnet | 1672 | <a href="https://pharosscan.xyz" target="_blank" rel="noopener noreferrer">pharosscan.xyz</a> | — |

## Links

- **GitHub**: <a href="https://github.com/tejas0111/Pharos" target="_blank" rel="noopener noreferrer">https://github.com/tejas0111/Pharos</a>
- **Pharos Docs**: <a href="https://docs.pharos.xyz" target="_blank" rel="noopener noreferrer">https://docs.pharos.xyz</a>
- **Pharos Discord**: <a href="https://discord.com/invite/pharos" target="_blank" rel="noopener noreferrer">https://discord.com/invite/pharos</a>

---

## Judging Rubric

| Criterion | How We Deliver |
|---|---|
| **Originality & Creativity** | Dual-layer design: 42 instruction subskills + 21 executable MCP tools — the only skill offering both layers for Pharos development |
| **Technical Quality** | 21 tools that actually execute (forge, viem RPC, Pharos-specific RPC, explorer API, slither), not just print commands. Private key sanitization. Error handling in every tool. Context-aware tips per tool. |
| **Practical Use Case** | Full dev lifecycle coverage: deploy, verify, transfer, trace, gas estimate, network status, account state, security audit, test generation, log fetching |
| **Reusability & Composability** | MCP tools chain together via the MCP protocol. See `agent/token-workflow.mjs` for an 8-tool composition demo (network config → diagnose → balance check → deploy ERC-20 → post-deploy balance → transfer → event logs → network status). |
| **On-Chain Deployment** | 3 contracts live on Atlantic Testnet (688689): Counter, Storage, PharosERC20. All addresses and tx hashes documented in `DEPLOYMENTS.md`. |
| **Documentation** | 42 subskill READMEs, 250+ line master README, Anvita Flow integration guide, deployment proof, architecture diagram, agent composition demo |
| **Pharos Vision Alignment** | Anvita Flow ready with x402 micropayments pre-configured. Phase 2 Agent Arena pipeline documented in `ANVITA_FLOW_INTEGRATION.md`. Pharos-native RPC methods (`eth_getAccount`, `debug_traceTransaction`, safe/finalized tags). |

## Quick Demo

**Contract screenshots** (Atlantic Testnet explorer):

<p align="center">
  <img src="./screenshots/1-pharos.png" width="30%" alt="Counter on explorer" />
  <img src="./screenshots/2-pharos.png" width="30%" alt="Storage on explorer" />
  <img src="./screenshots/3-pharos.png" width="30%" alt="PharosERC20 on explorer" />
</p>

See [screenshots/architecture.txt](./screenshots/architecture.txt) for the architecture diagram.

### 90-Second Demo

1. **Open the explorer**: https://atlantic.pharosscan.xyz/address/0x55ec4b1e32537b6f72aa20153735709837488e4e
2. **Run the agent**: `node agent/mcp-demo.mjs`
3. **Inspect the code**: Browse the skill suite at `skill/subskills/*/SKILL.md`

> **Demo video**: [Watch on pharos-ads.netlify.app/demo.mp4](https://pharos-ads.netlify.app/demo.mp4) — shows MCP server calling 6 tools live, explorer with deployed contracts, and the dual-layer architecture.
