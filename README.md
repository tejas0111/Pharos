# Pharos Agent Dev Suite

**A dual-layer Pharos Skill — 46 instruction subskills for human developers + 10 executable MCP tools for autonomous AI agents.**

Built for the Pharos Skill-to-Agent Hackathon (Atlantic Testnet 688689 / Pacific Mainnet 1672).

### Layer 1: 46 Prompt-Only Subskills

For human developers using AI coding assistants (Codex, Claude Code, OpenCode, Gemini CLI):
- **46 focused subskills** — architecture, Solidity, deployment, frontend, security, and more
- **Plan-first execution** — agents draft a plan before touching code
- **Approval gates** — higher-risk work requires explicit confirmation
- **Structured output** — downstream agents can reuse results

### Layer 2: 10 Executable MCP Tools

For autonomous AI agents that execute real on-chain operations:
- **Deploy**, **verify**, and **transfer** on Pharos networks
- **Check balances**, **fetch logs**, and **run security checks**
- **Generate tests** and **get contract info** from PharosScan
- **Deploy ERC-20 tokens** with custom name/symbol/supply

### Live On-Chain Proof

3 contracts deployed on Pharos Atlantic Testnet (688689):

| Contract | Address | Explorer |
|----------|---------|----------|
| **Counter** | `0x55ec4b1e32537b6f72aa20153735709837488e4e` | [View](https://pharos.socialscan.io/address/0x55ec4b1e32537b6f72aa20153735709837488e4e) ✅ Verified |
| **Storage** | `0x2527FDc8C6FdF7C5239f005D94Cc7dC6173d34f0` | [View](https://pharos.socialscan.io/address/0x2527FDc8C6FdF7C5239f005D94Cc7dC6173d34f0) ✅ Verified |
| **PharosERC20** | `0x3636F1BBcc56D1b5a22F8B778494D1553d95B4CD` | [View](https://pharos.socialscan.io/address/0x3636F1BBcc56D1b5a22F8B778494D1553d95B4CD) ✅ Verified |

### Uniquely Pharos

Two capabilities in this skill exist for **NO other blockchain**:

| Feature | Subskill | Why It Matters |
|---------|----------|----------------|
| **SPN (Subnet Processing Network)** | `spn-development` | Pharos-native L2 subnets for dedicated compute — no other L1 offers this |
| **RWA Compliance** | `rwa-compliance` | Real-world asset tokenization with regulatory checks — Pharos's core focus |

### Anvita Flow Ready

This skill is pre-configured for deployment on **Anvita Flow** (Ant Group's AI Agent platform with x402 micropayments). See [ANVITA_FLOW_INTEGRATION.md](./ANVITA_FLOW_INTEGRATION.md) for Phase 2 readiness.

## Install

```bash
npx skills add https://github.com/tejas0111/Pharos
```

> **OpenClaw users:** `npx clawhub install https://github.com/tejas0111/Pharos`

### OpenClaw (Pharos-native)

```bash
clawhub install https://github.com/tejas0111/Pharos
```

### Manual Setup

<details>
<summary><b>Codex</b></summary>

```bash
mkdir -p ~/.codex/skills/pharos-agent-dev-suite
cp -R skill/* ~/.codex/skills/pharos-agent-dev-suite/
```
</details>

<details>
<summary><b>Claude Code</b></summary>

```bash
mkdir -p ~/.claude/skills/pharos-agent-dev-suite
cp -R skill/* ~/.claude/skills/pharos-agent-dev-suite/
```
</details>

<details>
<summary><b>OpenCode</b></summary>

Add to `opencode.json`:

```json
{
  "skills": ["skill/"]
}
```

Or symlink:

```bash
ln -s "$PWD/skill" ~/.opencode/skills/pharos-agent-dev-suite
```
</details>

<details>
<summary><b>Gemini CLI</b></summary>

```bash
mkdir -p ~/.gemini/skills/pharos-agent-dev-suite
cp -R skill/* ~/.gemini/skills/pharos-agent-dev-suite/
```
</details>

## Usage

Reference a subskill in your prompt:

```
@pharos-agent-dev-suite deploy this contract to Atlantic testnet
```

The agent classifies your request, routes to the appropriate subskill, presents a plan, and executes with verification.

## Skill Map

| Subskill | Best For | Gate |
|---|---|---|
| `contract-architecture` | module boundaries, storage, permissions, upgrade stance | required |
| `solidity-authoring` | writing or refactoring Solidity | required |
| `interface-abi-design` | interfaces, events, errors, typed bindings | required |
| `protocol-integration-planning` | read/write call sequences and approval flow | required |
| `frontend-dapp-integration` | UI wiring to contract state and actions | required |
| `wallet-and-transaction-ui` | transaction preview, status, and history flows | required |
| `framework-integration` | Next.js, wagmi, viem, ethers, Foundry, Hardhat, Remix | optional |
| `testing-strategy` | test scope, fixtures, and coverage plan | required |
| `test-generation` | writing concrete tests and fixtures | required |
| `contract-review` | security, correctness, gas, and design review | required |
| `bug-finding-and-debugging` | root-cause analysis and narrow fixes | required |
| `deployment-and-verification` | deploy prep, verification, and release checks | required |
| `repo-onboarding` | mapping the codebase and entrypoints | optional |
| `docs-and-example-generation` | docs, examples, and usage notes | optional |
| `ci-and-build-troubleshooting` | failing builds, lint, type errors, CI regressions | required |
| `migration-and-backward-compatibility` | safe upgrades, rewrites, rollback planning | required |
| `refactoring-and-code-health` | behavior-preserving cleanup and structure improvements | required |
| `dependency-upgrade-management` | package, toolchain, and version upgrades | required |
| `performance-optimization` | runtime, render, bundle, and hot-path improvements | required |
| `accessibility-review` | keyboard, semantics, contrast, screen-reader checks | required |
| `release-notes-and-changelog` | release notes, changelog entries, PR summaries | optional |
| `code-scaffolding-and-generation` | boilerplate, templates, and starter files | optional |
| `state-management-integration` | query, store, cache, and client state wiring | required |
| `monorepo-workspace-management` | workspace boundaries and shared tooling | required |
| `localization-and-copy` | copy, strings, tone, and localization structure | optional |
| `repo-automation-and-tooling` | scripts, automation, and local tooling | optional |
| `deployment-for-testnet-and-mainnet` | network-aware deployment planning | required |
| `contract-testing-for-testnet-and-mainnet` | network-specific contract tests and checks | required |
| `code-review-templates-and-checklists` | PR checklists and review rubrics | optional |
| `nextjs-app-router-and-server-actions` | App Router, route handlers, server actions | optional |
| `react-ui-patterns-and-hooks` | React hooks and component patterns | optional |
| `wagmi-viem-dapp-workflow` | wallet connect and contract flow helpers | optional |
| `foundry-hardhat-contract-workflow` | Solidity dev workflows in Foundry or Hardhat | optional |
| `remix-contract-workflow` | Remix/browser Solidity workflows | optional |
| `tailwind-shadcn-ui-workflow` | Tailwind and shadcn/ui design systems | optional |
| `cross-chain-bridge` | cross-chain bridge design and integration | required |
| `upgrade-patterns` | proxy, beacon, and diamond upgrade strategies | required |
| `gas-optimization` | gas profiling and optimization techniques | optional |
| `security-audit` | comprehensive security review and audit | required |
| `production-ops` | production monitoring, incident response, ops | required |
| `spn-development` | Subnet (SPN) development and management | required |
| `rwa-compliance` | real-world asset compliance and regulatory | required |
| `workflow-orchestrator` | multi-step workflow orchestration | required |
| `post-deploy` | post-deployment monitoring and maintenance | required |

## Workflow

1. Agent classifies the request into the appropriate subskill
2. Gathers minimal relevant context (stack, repo structure, affected files)
3. Drafts a concrete plan before making changes
4. Presents the plan for review
5. High-risk tasks wait for explicit approval
6. Makes the smallest useful change
7. Verifies with the narrowest meaningful check
8. Returns a concise summary with a structured handoff

## Repository Layout

```
skill/
  SKILL.md              # master skill -- routing and orchestration
  subskills/*/SKILL.md  # 46 focused subskills
  references/*.md       # network context, deployment patterns, harness
  scripts/*.sh          # deploy and verify scripts (Foundry and Hardhat)
contracts/              # example Solidity contracts (3 deployed on testnet)
test/                   # Foundry tests (15 passing)
script/                 # Forge deploy scripts
config/                 # Pharos network configuration
packages/               # shared TypeScript types (viem defineChain)
mcp-server/             # MCP server with 10 executable tools for AI agents
.github/workflows/      # CI/CD deploy pipeline
foundry.toml            # Foundry config with Pharos RPC endpoints
hardhat.config.js       # Hardhat config with Pharos network definitions
.env.example            # environment variable template
LICENSE                 # MIT licensed
DEPLOYMENTS.md          # live on-chain deployment proof
ANVITA_FLOW_INTEGRATION.md  # Phase 2 readiness documentation
```

## On-Chain Deployment

3 contracts deployed and confirmed on Pharos Atlantic Testnet (688689):

| Contract | Address | Tx Hash | Explorer |
|----------|---------|---------|----------|
| **Counter** | `0x55ec4b1e32537b6f72aa20153735709837488e4e` | `0x0f1891dee4bd6fa7901ef287e0bef044f10bff1d445a5645ea15da723085e411` | [View](https://pharos.socialscan.io/address/0x55ec4b1e32537b6f72aa20153735709837488e4e) | ✅ |
| **Storage** | `0x2527FDc8C6FdF7C5239f005D94Cc7dC6173d34f0` | `0xed4bd34a99282782e9e6b9670ac8703148560c34fc695896aeb6b36458b94001` | [View](https://pharos.socialscan.io/address/0x2527FDc8C6FdF7C5239f005D94Cc7dC6173d34f0) | ✅ |
| **PharosERC20** | `0x3636F1BBcc56D1b5a22F8B778494D1553d95B4CD` | `0xcdf144d1f2ca398ece1a8b718c690347d673e5121479318fcc0d23d3523844ec` | [View](https://pharos.socialscan.io/address/0x3636F1BBcc56D1b5a22F8B778494D1553d95B4CD) | ✅ |

See [DEPLOYMENTS.md](./DEPLOYMENTS.md) for full details.

To deploy your own:

```bash
cp .env.example .env   # add PRIVATE_KEY
forge build
forge test
SIMULATE_ONLY=1 bash skill/scripts/deploy-testnet.sh   # simulate first
bash skill/scripts/deploy-testnet.sh                    # broadcast
```

Get testnet PHRS from the [Pharos Faucet](https://testnet.pharosnetwork.xyz).

## MCP Server

The Pharos MCP Server exposes **10 executable tools** for AI agents to interact with the Pharos blockchain. It runs as a stdio-based MCP server compatible with Claude Desktop and other MCP hosts.

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

### Quick Start

```bash
cd mcp-server
npm install
export PRIVATE_KEY=0x...
export PHAROS_TESTNET_RPC_URL=https://atlantic.dplabs-internal.com
node index.js
```

### Security Warning

**Never hardcode your PRIVATE_KEY in any config file.** Always use environment variables or a secrets manager. The MCP server reads `PRIVATE_KEY` from the environment only and NEVER exposes it in tool output.

### Claude Desktop Integration

Add to `claude_desktop_config.json`:

```json
{
  "mcpServers": {
    "pharos": {
      "command": "node",
      "args": ["/path/to/mcp-server/index.js"],
      "env": {
        "PRIVATE_KEY": "${PRIVATE_KEY}",
        "PHAROS_TESTNET_RPC_URL": "https://atlantic.dplabs-internal.com",
        "PHAROS_MAINNET_RPC_URL": "https://rpc.pharos.xyz"
      }
    }
  }
}
```

See [mcp-server/README.md](./mcp-server/README.md) for full documentation.

## Pharos Networks

| Network | Chain ID | Explorer | Faucet |
|---|---|---|---|
| Atlantic Testnet | 688689 | [atlantic.pharosscan.xyz](https://atlantic.pharosscan.xyz) | [faucet](https://testnet.pharosnetwork.xyz) |
| Pacific Mainnet | 1672 | [pharosscan.xyz](https://pharosscan.xyz) | -- |
