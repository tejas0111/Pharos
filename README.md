# Pharos Agent Dev Suite

Pharos Agent Dev Suite is a developer-only skill package for AI agents working on Pharos-related code.

It is designed to behave like a high-signal agent skill suite rather than a generic chat assistant:

- one master skill that routes requests
- 35 focused subskills
- plan-first execution
- approval gates for higher-risk work
- structured output that downstream agents can reuse
- installation support for Codex, Claude Code, OpenClaw, and other SKILL.md-compatible agents

This package is intentionally developer-only.

- No RPC reads
- No balances
- No transaction sending
- No onchain execution
- No wallet operations

The skill focuses on contract coding, UI integration, framework setup, testing, review, debugging, deployment prep, repo mapping, and documentation.

For actual contract broadcast and verification work, use the separate deploy-capable skill package in `deploy-skill/`.
It includes separate testnet and mainnet deployment variants plus Foundry and Hardhat deploy and verify templates.

## What It Covers

- contract architecture
- Solidity authoring
- interface and ABI design
- protocol integration planning
- frontend dapp integration
- wallet and transaction UI
- framework integration
- testing strategy
- test generation
- contract review
- bug finding and debugging
- deployment and verification
- repo onboarding
- docs and example generation
- CI and build troubleshooting
- migration and backward compatibility
- refactoring and code health
- dependency upgrade management
- performance optimization
- accessibility review
- release notes and changelog
- code scaffolding and generation
- state management integration
- monorepo and workspace management
- localization and copy
- repo automation and tooling
- deployment for testnet and mainnet
- contract testing for testnet and mainnet
- code review templates and checklists
- Next.js App Router and server actions
- React UI patterns and hooks
- Wagmi and Viem dapp workflows
- Foundry and Hardhat contract workflows
- Remix contract workflows
- Tailwind and shadcn/ui workflows

## Skill Map

| Subskill | Best For | Approval Gate |
| --- | --- | --- |
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
| `repo-onboarding` | mapping the codebase and important entrypoints | optional |
| `docs-and-example-generation` | docs, examples, and usage notes | optional |
| `ci-and-build-troubleshooting` | failing builds, lint, type errors, CI regressions | required |
| `migration-and-backward-compatibility` | safe upgrades, rewrites, rollback planning | required |
| `refactoring-and-code-health` | behavior-preserving cleanup and structure improvements | required |
| `dependency-upgrade-management` | package, toolchain, and version upgrades | required |
| `performance-optimization` | runtime, render, bundle, and hot-path improvements | required |
| `accessibility-review` | keyboard, semantics, contrast, and screen-reader checks | required |
| `release-notes-and-changelog` | release notes, changelog entries, PR summaries | optional |
| `code-scaffolding-and-generation` | boilerplate, templates, and starter files | optional |
| `state-management-integration` | query, store, cache, and client state wiring | required |
| `monorepo-workspace-management` | workspace boundaries and shared tooling | required |
| `localization-and-copy` | copy, strings, tone, and localization structure | optional |
| `repo-automation-and-tooling` | scripts, automation, and local tooling | optional |
| `deployment-for-testnet-and-mainnet` | network-aware deployment planning | required |
| `contract-testing-for-testnet-and-mainnet` | network-specific contract tests and checks | required |
| `code-review-templates-and-checklists` | PR checklists and review rubrics | optional |
| `nextjs-app-router-and-server-actions` | App Router, route handlers, and server actions | optional |
| `react-ui-patterns-and-hooks` | React hooks and component patterns | optional |
| `wagmi-viem-dapp-workflow` | wallet connect and contract flow helpers | optional |
| `foundry-hardhat-contract-workflow` | Solidity dev workflows in Foundry or Hardhat | optional |
| `remix-contract-workflow` | Remix/browser Solidity workflows | optional |
| `tailwind-shadcn-ui-workflow` | Tailwind and shadcn/ui design systems | optional |

## How The Suite Works

1. Classify the request into one of the 35 subskills.
2. Gather only the stack, repo, and file context that changes the plan.
3. Draft a concrete plan before changing files.
4. Show the plan to the user.
5. For higher-risk work, wait for explicit approval before edits.
6. Make the smallest useful change.
7. Verify with the narrowest meaningful check.
8. Return a concise summary plus a structured handoff.

The agent should not jump straight into code when the task benefits from a plan.

## Installation

### Dev Suite

### Codex

Copy the `skill/` directory into your Codex skills directory:

```bash
mkdir -p ~/.codex/skills/pharos-agent-dev-suite
cp -R skill/* ~/.codex/skills/pharos-agent-dev-suite/
```

### Claude Code

```bash
mkdir -p ~/.claude/skills/pharos-agent-dev-suite
cp -R skill/* ~/.claude/skills/pharos-agent-dev-suite/
```

### OpenClaw

```bash
mkdir -p ~/.openclaw/skills/pharos-agent-dev-suite
cp -R skill/* ~/.openclaw/skills/pharos-agent-dev-suite/
```

### Deploy Skill

Copy the `deploy-skill/skill/` directory into your skills directory:

```bash
mkdir -p ~/.codex/skills/pharos-agent-deploy-suite
cp -R deploy-skill/skill/* ~/.codex/skills/pharos-agent-deploy-suite/
```

```bash
mkdir -p ~/.claude/skills/pharos-agent-deploy-suite
cp -R deploy-skill/skill/* ~/.claude/skills/pharos-agent-deploy-suite/
```

```bash
mkdir -p ~/.openclaw/skills/pharos-agent-deploy-suite
cp -R deploy-skill/skill/* ~/.openclaw/skills/pharos-agent-deploy-suite/
```

### Published Install

If this repository is published on GitHub, agents that support `npx skills add` can install it directly:

```bash
npx skills add https://github.com/<org>/<repo>
```

Replace the placeholder URL with the public repo URL.

## Verification

```bash
npm install
npm test
npm run build
npm run check
```

## Example Prompts

- Design the contract architecture for a staking protocol with access control and upgrade boundaries.
- Integrate this Next.js app with wagmi and viem for a wallet connect and transaction preview flow.
- Review this Solidity contract for security, gas, and correctness issues.
- Map this repo so I can start implementing a frontend dapp integration.
- Write the tests for this contract and show the plan before generating them.
- Create a PR checklist and code review rubric for contract changes.
- Set up a Foundry workflow for tests and scripts in this repo.
- Plan a safe deployment for testnet and mainnet with release checks.
- Design contract tests that cover both testnet and mainnet assumptions.
- Set up a Remix workflow for rapid contract iteration.
- Build the UI with Tailwind and shadcn/ui patterns.
- Deploy this contract to Pharos testnet and verify the address on the explorer.

## Repository Layout

- `skill/SKILL.md` master skill
- `skill/subskills/*/SKILL.md` focused subskills
- `skill/references/*.md` workflow and output guidance
- `skill/agents/*.yaml` agent-facing install metadata
- `deploy-skill/skill/SKILL.md` deploy-capable companion skill
- `deploy-skill/skill/subskills/*/SKILL.md` testnet and mainnet deployment variants
- `deploy-skill/skill/scripts/*.sh` Foundry and Hardhat deploy and verify templates
- `deploy-skill/skill/agents/*.yaml` deploy-skill install metadata
- `examples/*.md` prompt examples for supported agents

## Development Notes

- This package is intentionally not an RPC or wallet utility.
- High-risk subskills must present a plan and wait for approval before edits.
- Low-risk subskills still present a plan, but they can proceed once the user agrees.
