# Pharos Agent Dev Suite

## One-Liner
**46 agent skills + live on-chain deployment proof for building on Pharos (Atlantic Testnet / Pacific Mainnet).**

---

## What It Is

The Pharos Agent Dev Suite is a comprehensive skill package that turns any AI coding agent (Codex, Claude Code, OpenCode, Gemini CLI) into a Pharos blockchain specialist. With 46 finely-grained subskills spanning architecture, Solidity authoring, deployment, frontend dapp integration, security auditing, and production operations, it provides end-to-end coverage for Pharos development.

## Key Differentiators

### ✅ Live On-Chain Deployment
We don't just talk about Pharos — we prove it. A Counter contract has been deployed to Pharos Atlantic Testnet (chain 688689), demonstrating real on-chain capability:

- **Contract**: [`0x55ec4b1e32537b6f72aa20153735709837488e4e`](https://atlantic.pharosscan.xyz/address/0x55ec4b1e32537b6f72aa20153735709837488e4e) (Counter)
- **Tx Hash**: [`0x0f1891dee4bd6fa7901ef287e0bef044f10bff1d445a5645ea15da723085e411`](https://atlantic.pharosscan.xyz/tx/0x0f1891dee4bd6fa7901ef287e0bef044f10bff1d445a5645ea15da723085e411)
- **Deployer**: `0x735367687d6a701466840321eD8e34E4DafE84aC`
- **Network**: Atlantic Testnet (688689, PHRS)
- **Explorer**: [View on PharosScan](https://atlantic.pharosscan.xyz/address/0x55ec4b1e32537b6f72aa20153735709837488e4e)

### 🎯 46 Focused Subskills
Each subskill is independently promptable with its own risk gate, execution workflow, and verification criteria:

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

### 🌐 Pharos-Native Intelligence
The suite encodes Pharos-specific gotchas that generic agents miss:
- **No 2300 gas stipend** for native PHRS/PROS transfers
- **Correct chain IDs**: Atlantic Testnet (688689, PHRS) vs Pacific Mainnet (1672, PROS)
- **EIP-1559 fee model** with base fee burn and priority fee to validators
- **Multi-platform support**: Foundry, Hardhat, Remix, wagmi/viem, ethers

### 📦 Multi-Platform Ready
Works across all major AI coding assistants:
- **Codex** → `~/.codex/skills/pharos-agent-dev-suite/`
- **Claude Code** → `~/.claude/skills/pharos-agent-dev-suite/`
- **OpenCode** → `opencode.json` skills config
- **Gemini CLI** → `~/.gemini/skills/pharos-agent-dev-suite/`
- **npx** → `npx skills add https://github.com/tejas0111/Pharos`

## Technical Architecture

```
skill/
  SKILL.md                 # Master routing & orchestration (1.2.0)
  subskills/*/SKILL.md     # 46 focused subskills
  references/*.md          # Network context, deployment patterns, harness
  scripts/*.sh             # Deploy & verify scripts for Foundry & Hardhat

contracts/                 # Example Solidity contracts
test/                      # Foundry tests (15 passing)
script/                    # Forge deploy scripts
config/                    # Pharos network configuration
packages/                  # Shared TypeScript types (viem defineChain)
mcp-server/                # MCP server with 7 tools
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
| Atlantic Testnet | 688689 | [atlantic.pharosscan.xyz](https://atlantic.pharosscan.xyz) | [testnet.pharosnetwork.xyz](https://testnet.pharosnetwork.xyz) |
| Pacific Mainnet | 1672 | [pharosscan.xyz](https://pharosscan.xyz) | — |

## Installation

```bash
# Via npx (recommended)
npx skills add https://github.com/tejas0111/Pharos

# Or manual setup for your AI assistant
# See README.md for per-platform instructions
```

## Links

- **GitHub**: [https://github.com/tejas0111/Pharos](https://github.com/tejas0111/Pharos)
- **Pharos Docs**: [https://docs.pharos.xyz](https://docs.pharos.xyz)
- **Pharos Discord**: [https://discord.com/invite/pharos](https://discord.com/invite/pharos)

---

## Why This Wins

| Judging Criterion | How We Deliver |
|---|---|
| **Originality & Creativity** | Dual-layer design: 46 instruction subskills + 10 executable MCP tools — the only skill offering both layers for Pharos development |
| **Technical Quality** | 10 tools that actually execute (forge, viem RPC, explorer API, slither), not just print commands. Private key sanitization. Error handling in every tool. |
| **Practical Use Case** | Full dev lifecycle coverage: deploy, verify, transfer, security audit, test generation, log fetching, balance checking |
| **Reusability & Composability** | MCP tools chain together via the MCP protocol. See `agent/token-workflow.sh` for a 3-tool composition demo (deploy ERC-20 → check balance → transfer). |
| **On-Chain Deployment** | 3 contracts live on Atlantic Testnet (688689): Counter, Storage, PharosERC20. All addresses and tx hashes documented in `DEPLOYMENTS.md`. |
| **Documentation** | 46 subskill READMEs, 250+ line master README, Anvita Flow integration guide, deployment proof, architecture diagram, agent composition demo |
| **Pharos Vision Alignment** | Anvita Flow ready with x402 micropayments pre-configured. Phase 2 Agent Arena pipeline documented in `ANVITA_FLOW_INTEGRATION.md`. |

## Quick Demo

![Architecture](./screenshots/architecture.png)

See [screenshots/architecture.txt](./screenshots/architecture.txt) for the full architecture diagram.

### 90-Second Demo

1. **Open the explorer**: https://atlantic.pharosscan.xyz/address/0x55ec4b1e32537b6f72aa20153735709837488e4e
2. **Run the agent**: `bash agent/token-workflow.sh`
3. **Inspect the code**: Browse the skill suite at `skill/subskills/*/SKILL.md`

### Screenshots

See [screenshots/README.md](./screenshots/README.md) for screenshot instructions and placeholder images.
