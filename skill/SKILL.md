---
name: pharos-agent-suite
description: "Pharos blockchain developer and deployment suite for contract coding, dapp frontend integration, testing, and high-risk deployment on Pharos (Atlantic 688689 / Pacific 1672). Use when building, testing, reviewing, debugging, or broadcasting contracts with Foundry/Hardhat, or when onboarding repos, refactoring, managing monorepos, and configuring CI. Keywords: Pharos, Solidity, contract, dapp, deploy, broadcast, verify, Foundry, Hardhat, wagmi, viem, Remix, CI, build failure, review, audit, debug, refactor, scaffold, monorepo, a11y, release notes, PROS, PHRS, 688689, 1672, Atlantic, Pacific, forge, cast, PharosScan, dapp-ui, dapp-quality."
slash: true
metadata:
  audience: developer
  version: 1.2.0
  category: workflow
---

# Pharos Agent Suite

The comprehensive developer and deployment suite for Pharos blockchain projects. Routes to 39 developer subskills + 3 high-risk deployment subskills with mandatory requirement gathering and plan-first execution via `PLAN.md`.

## Core Workflow: Requirement → Plan → Execute

To ensure high-fidelity delivery and zero assumptions, follow this lifecycle for EVERY request:

1.  **Requirement Gathering (The "Check"):**
    - For first-time tasks or complex requests, list all identified requirements.
    - Ask clarifying questions for any ambiguities.
    - Offer technical suggestions if a better Pharos-specific pattern exists (e.g., using pull-over-push for PHRS).
    - **Do not proceed** until the user confirms the requirements are complete.

2.  **Mandatory Planning (`PLAN.md`):**
    - Create or update a `PLAN.md` in the project root (or current directory).
    - This file MUST contain:
        - **Goal**: Clear statement of what is being built/fixed.
        - **Pharos Context**: Network (Atlantic/Pacific), Chain ID, and Currency (PHRS/PROS).
        - **Technical Strategy**: Architecture, file changes, and logic.
        - **Testing Plan**: How the change will be verified (Foundry/Hardhat/UI).
        - **Risk Level**: Low/Medium/High.
    - Present the plan to the user and wait for explicit "Proceed" or "Approve".

3.  **Execution (Surgical & Verifiable):**
    - Implement the changes exactly as outlined in the approved `PLAN.md`.
    - For High-Risk tasks (Deploy/Broadcast/Critical Security): Prepare everything (scripts, artifacts) but **ASK AGAIN** before the final execution/broadcast.

## Quick Reference

| Action | Rule |
|---|---|
| Requirement Chk | Mandatory for all first-time or complex tasks |
| `PLAN.md` | Required for every task; must be committed or shared |
| User Approval | Mandatory before starting execution phase |
| Risk-Gated Deploy | Simulation + Approval + Final "Ready to Broadcast?" check |
| Network Truth | Atlantic (688689, PHRS) or Pacific (1672, PROS) |
| No Assumptions | If in doubt, ASK. Never guess RPCs, addresses, or logic. |

## Quick Start

```
You: "Design the architecture for a staking contract"
 → Requirement Gathering: Ask about reward tokens, staking period, and access control.
 → Plan: Create PLAN.md with the module map and storage layout.
 → Approval: Wait for "Looks good, proceed."
 → Execution: Write the Solidity files and tests.
```

## MCP Server Setup

The Pharos MCP server provides 18 on-chain tools (balanceOf, deployContract, traceTx, etc.). Set it up once before any on-chain workflow:

1. **Install dependencies** (if not already done):
   ```bash
   cd mcp-server && npm install
   ```

2. **Set environment variables** in `.env`:
   ```bash
   PRIVATE_KEY=0x...
   PHAROS_TESTNET_RPC_URL=https://atlantic.dplabs-internal.com
   PHAROS_MAINNET_RPC_URL=https://rpc.pharos.xyz
   ```

3. **Verify the server works**:
   ```bash
   node mcp-server/index.js
   ```
   It should print "Pharos MCP Server running on stdio" and list 18 registered tools.

4. **Integrate with your AI client** (one-time config):

   | Client | Config |
   |---|---|
   | Claude Desktop | Add to `claude_desktop_config.json` (see `mcp-server/README.md`) |
   | OpenCode | Add to `.opencode/mcp.json` |
   | Cursor | Add to `.cursor/mcp.json` |
   | Windsurf | Add MCP server via Settings → MCP |

   The agent can run the server locally via `node mcp-server/index.js` and connect via stdio.

5. **Run demos** (no key needed for read-only):
   ```bash
   node agent/mcp-demo.mjs        # 6 read-only tools
   node agent/cascade-demo.mjs    # skill→tool→blockchain flow
   node agent/token-workflow.mjs  # full workflow (set PRIVATE_KEY for real tx)
   ```

## When to Use

Trigger when the user says any of:

```
write/edit/refactor Solidity • contract architecture • interface/ABI design
protocol integration planning • dapp frontend integration • wallet UI
transaction preview • testing strategy • test generation • contract review
audit • debug • bug fix • CI failure • build fix • type error • lint
deployment • broadcast • testnet • mainnet • RPC • explorer • PharosScan
repo onboarding • map the repo • docs • examples • refactoring
dependency upgrade • performance optimization • accessibility/a11y
release notes • changelog • scaffold • boilerplate • monorepo
Next.js • wagmi • viem • Foundry • Hardhat • Remix • Tailwind
```

## Common Workflows

### 1. "Onboard to a Pharos project"
Use `repo-onboarding` to map the stack, entrypoints, and local conventions. Detects Foundry vs Hardhat and Pharos network targets automatically.

### 2. "Develop and Test"
Chain `contract-architecture` → `solidity-authoring` → `testing-strategy` → `test-generation`. Use `bug-finding-and-debugging` for any failures.

### 3. "Secure and Review"
Use `contract-review` and `security-audit` to identify issues before deployment. Uses the Pharos severity rubric (Critical/High/Med/Low).

### 4. "Deploy to Testnet/Mainnet"
Use `deployment-and-verification` for prep, then `testnet-deployment` or `mainnet-deployment` for broadcasting. **Simulation is mandatory.**

### 5. "Post-Deploy & Verification"
Use `post-deploy` to capture artifacts, verify on PharosScan, and update frontend contract addresses/ABIs.

## Routing Decision Tree

Classify the request by asking these questions in order:

```
1. Is the request about BROADCASTING or DEPLOYING to a network?
   ├── Testnet / dry-run / simulation?            → testnet-deployment
   ├── Mainnet / production / go-live?            → mainnet-deployment
   └── Verification / post-deploy artifacts?       → post-deploy

2. Is the request about writing/designing SOLIDITY or CONTRACT code?
   ├── System-level design before code?           → contract-architecture
   ├── Writing or refactoring Solidity?            → solidity-authoring
   └── Interface/ABI/events/errors?                → interface-abi-design

3. Is the request about FRONTEND/UI code?
   ├── Wiring UI to contract state?                → frontend-dapp-integration
   ├── Building dapp UI components and pages?      → dapp-ui-workflow
   ├── Dapp quality (a11y, i18n, state mgmt)?      → dapp-quality
   └── Wallet connect, tx preview, history UI?     → wallet-and-transaction-ui

4. Is the request about TESTING or REVIEW?
   ├── Planning test strategy/coverage?             → testing-strategy
   ├── Writing concrete tests?                      → test-generation
   ├── Reviewing contract security/correctness?     → contract-review
   └── Debugging a failure or bug?                  → bug-finding-and-debugging

5. Is the request about FRAMEWORK, TOOLING, or INFRA?
   ├── Fixing a build, CI, lint, or type error?     → ci-and-build-troubleshooting
   ├── "Map this repo" or "where is X"?             → repo-onboarding
   ├── Upgrading packages or toolchains?            → dependency-upgrade-management
   └── Monorepo or workspace changes?               → monorepo-workspace-management
```

## Deploy Protocol

Every broadcast requires explicit approval. No exceptions.

1. **Pre-flight**:
    - **.env Check**: Verify `.env` exists and contains `PRIVATE_KEY` and necessary RPC/API URLs.
    - **Validation**: Validate RPC, Chain ID (1672/688689), Signer balance, and Compiler version.
2. **Gate Fix**: Check for and fix any 'gate' issues in the frontend/contract interaction layer before proceeding.
3. **Simulation**: Run `SIMULATE_ONLY=1` (Foundry) or Hardhat dry-run to confirm success.
4. **Approval**: Present the final command and env vars (hidden) for explicit user confirmation.
5. **Broadcast**: Execute only after approval.
6. **Verify**: Automate explorer verification on PharosScan after success.

## Troubleshooting

| Problem | Likely cause | Fix |
|---|---|---|
| Skill not triggering | Missing keywords or description frontmatter | Add keywords to `description` or `When to Use` |
| RPC connection failed | Invalid URL or firewall | Verify `PHAROS_RPC_URL` is reachable via `curl` |
| Simulation reverted | Logical error or state mismatch | Check constructor args and network state fork |
| Plan is too broad | Using general subskill instead of narrow | Route to most specific subskill (e.g. `contract-review`) |
| Env var not expanded | Using literal name instead of `${VAR}` | Use `${VAR_NAME}` syntax in config/commands |
| Mainnet deploy blocked | Safety gate or insufficient funds | Re-run balance check; ensure network is Pacific (1672) |
| Gate Fix failure | Inconsistent frontend/contract state | Run `gate-fix` diagnostic before re-attempting deploy |

## Best Practices

- **Strict .env Enforcement**:
    - **Storage**: All environment variables (especially `PRIVATE_KEY` and `PHAROSSCAN_API_KEY`) MUST be stored in a `.env` file in the project root.
    - **Mandatory Check**: The Agent MUST check for the existence of `.env` and valid values before attempting any deployment or on-chain action.
    - **No Exports**: Never instruct the user to `export VAR=...`. Instead, tell them to add the variable to `.env`.
    - **Security**: The `.env` file MUST be ignored by git.
- **Use Env Var Expansion**: Never hardcode keys. Use `${PRIVATE_KEY}` in config files. Private keys must be added to `.env` and never exposed in prompts or logs.
- **Route Narrowly**: pick the most specific subskill to avoid context bloat.
- **Plan First, Code Second**: Never make edits without showing a concrete plan first.
- **One Change at a Time**: Keep changes surgical and verifiable.
- **Testnet Rehearsal**: Always deploy to Atlantic Testnet (688689) before Mainnet (1672).
- **Verify after Every Change**: Run the narrowest check (unit test, then build, then lint).

## Pharos Network Reference

| Network | Chain ID | RPC URL | Explorer | Symbol |
|---|---|---|---|---|
| Pacific Mainnet | 1672 | `https://rpc.pharos.xyz`, `https://infra.orginstake.com/pharos/evm` | https://www.pharosscan.xyz | PROS |
| Atlantic Testnet | 688689 | `https://atlantic.dplabs-internal.com` | https://atlantic.pharosscan.xyz | PHRS |

> Full network details, wagmi configs, and Foundry/Hardhat templates are in `references/pharos-context.md` and the `config/` directory.

## Output Contract

Every response must include: **Summary, Plan, Assumptions, Files/Artifacts, Verification, and Approval Question.**

---
*Pharos Agent Suite — Powering the next generation of Pharos developers.*
