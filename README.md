# Pharos Agent Dev Suite

Developer skill package for AI agents building on Pharos (Atlantic Testnet 688689 / Pacific Mainnet 1672).

- **46 focused subskills** — architecture, Solidity, deployment, frontend, security, and more
- **Plan-first execution** — agents draft a plan before touching code
- **Approval gates** — higher-risk work requires explicit confirmation
- **Structured output** — downstream agents can reuse results

## Install

```bash
npx skills add https://github.com/tejas0111/Pharos
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
  SKILL.md              # master skill — routing and orchestration
  subskills/*/SKILL.md  # 46 focused subskills
  references/*.md       # workflow and output guidance
  scripts/*.sh          # deploy and verify scripts
.env.example            # environment variable template
```

## Pharos Networks

| Network | Chain ID | Explorer |
|---|---|---|
| Atlantic Testnet | 688689 | [atlantic.pharosscan.xyz](https://atlantic.pharosscan.xyz) |
| Pacific Mainnet | 1672 | [pharosscan.xyz](https://pharosscan.xyz) |
