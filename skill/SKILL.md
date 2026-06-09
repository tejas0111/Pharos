---
name: pharos-agent-dev-suite
description: "Use ONLY when the user wants Pharos blockchain developer work: contract coding (Solidity), dapp frontend integration (wagmi/viem/Next.js), framework setup (Foundry/Hardhat/Remix), testing/review/debugging, deployment prep, CI troubleshooting, repo onboarding, refactoring, dependency upgrades, monorepo management, accessibility review, release notes, code scaffolding, or docs generation. Do NOT use for: RPC reads, balance checks, transaction sending, onchain execution, wallet operations, or any non-Pharos development. Trigger keywords: Pharos, Solidity, contract, dapp, deploy, test, Foundry, Hardhat, wagmi, viem, Remix, CI, build failure, review, audit, debug, refactor, scaffold, monorepo, accessibility, a11y, release notes, changelog."
slash: true
---

# Pharos Agent Dev Suite

Developer skill suite for Pharos blockchain projects. Routes to 35 specialized subskills with plan-first execution and risk-gated approvals.

## Quick Reference

| Action | Rule |
|---|---|
| Always show a plan first | All 35 subskills |
| Wait for explicit confirmation before edits | High & medium risk subskills (21 total) |
| Proceed after user agrees | Low risk subskills (14 total) |
| No RPC, balances, or onchain execution | This suite is developer-only |
| Hand off deploy broadcast/verification | Use `pharos-agent-deploy-suite` |

## When to Use

Trigger when the user says any of:

```
write/edit/refactor Solidity • contract architecture • interface/ABI design
protocol integration planning • dapp frontend integration • wallet UI
transaction preview • testing strategy • test generation • contract review
audit • debug • bug fix • CI failure • build fix • type error • lint
deployment prep • repo onboarding • map the repo • docs • examples
migration • backward compatibility • refactoring • code health
dependency upgrade • performance optimization • accessibility/a11y
release notes • changelog • scaffold • boilerplate • state management
monorepo • workspace • automation • tooling • code review template • PR checklist
Next.js App Router • server actions • React hooks • component patterns
wagmi • viem • Foundry • Hardhat • Remix • Tailwind • shadcn/ui
```

Do NOT trigger for: RPC reads, balance queries, transaction sending, event watching, or any onchain execution — those belong in `pharos-agent-deploy-suite`.

## Routing Decision Tree

Classify the request by asking these questions in order:

```
1. Is the request about writing/designing SOLIDITY or CONTRACT code?
   ├── System-level design before code?           → contract-architecture
   ├── Writing or refactoring Solidity?            → solidity-authoring
   ├── Interface/ABI/events/errors?                → interface-abi-design
   └── Protocol integration call sequences?        → protocol-integration-planning

2. Is the request about FRONTEND/UI code?
   ├── Wiring UI to contract reads/writes?         → frontend-dapp-integration
   └── Wallet connect, tx preview, history UI?     → wallet-and-transaction-ui

3. Is the request about TESTING or REVIEW?
   ├── Planning test strategy/coverage?             → testing-strategy
   ├── Writing concrete tests?                      → test-generation
   ├── Reviewing contract security/correctness?     → contract-review
   ├── Debugging a failure or bug?                  → bug-finding-and-debugging
   └── Network-aware contract tests?                → contract-testing-for-testnet-and-mainnet

4. Is the request about FRAMEWORK, TOOLING, or INFRA?
   ├── Mentioning a specific framework by name?     → framework-integration
   ├── Fixing a build, CI, lint, or type error?     → ci-and-build-troubleshooting
   ├── "Map this repo" or "where is X"?             → repo-onboarding
   ├── Upgrading packages or toolchains?            → dependency-upgrade-management
   ├── Monorepo or workspace changes?               → monorepo-workspace-management
   ├── Writing scripts or automation?               → repo-automation-and-tooling
   ├── Creating PR checklists or review rubrics?    → code-review-templates-and-checklists
   ├── Deployment planning across networks?         → deployment-for-testnet-and-mainnet
   ├── Next.js App Router or server actions?        → nextjs-app-router-and-server-actions
   ├── React hooks, context, or component patterns? → react-ui-patterns-and-hooks
   ├── Wagmi/Viem wallet or contract wiring?        → wagmi-viem-dapp-workflow
   ├── Foundry/Hardhat workflow setup?              → foundry-hardhat-contract-workflow
   ├── Remix/browser Solidity?                      → remix-contract-workflow
   └── Tailwind or shadcn/ui?                       → tailwind-shadcn-ui-workflow

5. Is the request about QUALITY or PERFORMANCE?
   ├── Refactoring without behavior change?         → refactoring-and-code-health
   ├── Optimizing slow/bottleneck code?             → performance-optimization
   ├── Accessibility or a11y review?                → accessibility-review
   └── State management wiring?                     → state-management-integration

6. Is the request about SHIPPING or DOCS?
   ├── Preparing deploy scripts/release checks?     → deployment-and-verification
   ├── Planning upgrade/migration/rollback?         → migration-and-backward-compatibility
   ├── Writing release notes or changelog?          → release-notes-and-changelog
   ├── Generating boilerplate or scaffolds?         → code-scaffolding-and-generation
   ├── Writing docs, README, or examples?           → docs-and-example-generation
   └── Refining copy, labels, or i18n?              → localization-and-copy
```

**Classification rule**: Route to the narrowest subskill. If "review this contract" → `contract-review`, not `solidity-authoring`. If multiple subskills match, pick the one that covers the primary request; mention secondary subskills in the plan as follow-up suggestions.

## Context Gathering Protocol

After classifying, gather ONLY the files that change the plan:

| Category | Read these first | Skip |
|---|---|---|
| Contract work | `package.json`, `foundry.toml`/`hardhat.config.ts`, contract files in scope, test files | Unrelated frontend code, config files |
| UI work | `package.json`, `next.config.js`/`vite.config.ts`, component files, wagmi/viem config | Contract internals, unrelated pages |
| Testing | `package.json`, test framework config, existing test patterns, contracts/UI under test | Deploy scripts, unrelated modules |
| Framework/tooling | `package.json`, `tsconfig.json`, framework config, CI config (`.github/`, `.gitlab-ci.yml`) | Application business logic |
| Quality | All files in scope of change, test files, benchmark/audit output | Deploy config, unrelated infra |
| Shipping/docs | Package entrypoints, README, existing docs, deploy scripts | Contract internals, unrelated modules |

If you cannot determine the stack after reading `package.json` and config files, ask the user.

### Framework Auto-Detection

Detect the stack from these signals:

| Signal | Detected framework |
|---|---|
| `"hardhat"` in `package.json` dependencies or `hardhat.config.*` | Hardhat |
| `"foundry"` in imports or `foundry.toml` present | Foundry |
| `"wagmi"` in dependencies or `"wagmi"` imports | wagmi |
| `"viem"` in dependencies or `"viem"` imports | viem |
| `"next"` in dependencies or `next.config.*` present | Next.js |
| `"@remix-project/remixd"` in deps or user mentions "Remix" | Remix |
| `"hardhat"` AND `"@nomicfoundation/hardhat-toolbox"` | Hardhat with toolbox |
| `"tailwindcss"` in devDependencies | Tailwind |
| `"@radix-ui"` or `"shadcn"` in imports | shadcn/ui |
| `"zustand"` or `"@reduxjs/toolkit"` or `"react-query"` | State management tool |

## Subskill Reference

All 35 subskills, organized by category with risk level and approval gate:

### Contract Work

| Subskill | Risk | Gate | When |
|---|---|---|---|
| `contract-architecture` | high | confirm | module boundaries, storage, permissions, upgrade stance |
| `solidity-authoring` | high | confirm | write or refactor Solidity code |
| `interface-abi-design` | medium | confirm | interfaces, events, errors, typed bindings |
| `protocol-integration-planning` | high | confirm | read/write call sequences, approval flow |

### UI Work

| Subskill | Risk | Gate | When |
|---|---|---|---|
| `frontend-dapp-integration` | medium | confirm | UI wiring to contract state, transaction previews |
| `wallet-and-transaction-ui` | medium | confirm | wallet states, preview modals, status, history |

### Testing & Review

| Subskill | Risk | Gate | When |
|---|---|---|---|
| `testing-strategy` | medium | confirm | test scope, fixtures, coverage plan |
| `test-generation` | medium | confirm | writing concrete tests and fixtures |
| `contract-review` | high | confirm | security, correctness, gas, design review |
| `bug-finding-and-debugging` | high | confirm | root-cause analysis, narrow fixes |
| `contract-testing-for-testnet-and-mainnet` | medium | confirm | network-aware contract tests |

### Framework & Tooling

| Subskill | Risk | Gate | When |
|---|---|---|---|
| `framework-integration` | low | proceed | Next.js, wagmi, viem, ethers, Foundry, Hardhat, Remix |
| `ci-and-build-troubleshooting` | high | confirm | failing builds, type errors, lint, CI regressions |
| `repo-onboarding` | low | proceed | mapping codebase, entrypoints, scripts, conventions |
| `dependency-upgrade-management` | medium | confirm | package updates, toolchain upgrades, version bumps |
| `monorepo-workspace-management` | medium | confirm | workspace boundaries, shared tooling, packages |
| `repo-automation-and-tooling` | low | proceed | scripts, task runners, precommit, makefiles |
| `code-review-templates-and-checklists` | low | proceed | PR checklists, review rubrics, templates |
| `deployment-for-testnet-and-mainnet` | high | confirm | network-aware deployment planning and release checks |
| `nextjs-app-router-and-server-actions` | low | proceed | App Router, route handlers, server actions, RSC |
| `react-ui-patterns-and-hooks` | low | proceed | React hooks, component boundaries, patterns |
| `wagmi-viem-dapp-workflow` | low | proceed | wallet connect, contract reads/writes, dapp patterns |
| `foundry-hardhat-contract-workflow` | low | proceed | Solidity dev workflow, forge, anvil, scripts |
| `remix-contract-workflow` | low | proceed | browser Solidity, quick iteration |
| `tailwind-shadcn-ui-workflow` | low | proceed | Tailwind, shadcn/ui, design systems |

### Quality & Performance

| Subskill | Risk | Gate | When |
|---|---|---|---|
| `refactoring-and-code-health` | medium | confirm | behavior-preserving cleanup, structure improvements |
| `performance-optimization` | medium | confirm | runtime, render, bundle, gas-adjacent improvements |
| `accessibility-review` | medium | confirm | keyboard, semantics, contrast, screen-reader |
| `state-management-integration` | medium | confirm | query, store, cache, client-state wiring |

### Shipping & Docs

| Subskill | Risk | Gate | When |
|---|---|---|---|
| `deployment-and-verification` | high | confirm | deploy prep, explorer verification, release checks |
| `migration-and-backward-compatibility` | high | confirm | safe upgrades, data moves, rollback planning |
| `release-notes-and-changelog` | low | proceed | release notes, changelog entries, PR summaries |
| `code-scaffolding-and-generation` | low | proceed | boilerplate, starter files, project scaffolds |
| `docs-and-example-generation` | low | proceed | docs, examples, usage instructions, agent prompts |
| `localization-and-copy` | low | proceed | copy, strings, tone, i18n structure |

### Subskill Chaining

Some requests benefit from chaining multiple subskills in sequence:

| Primary subskill | Often followed by |
|---|---|
| `contract-architecture` | `solidity-authoring` → `interface-abi-design` |
| `testing-strategy` | `test-generation` |
| `contract-review` | `bug-finding-and-debugging`, `solidity-authoring` (for fixes) |
| `deployment-and-verification` | `deployment-for-testnet-and-mainnet` |
| `frontend-dapp-integration` | `wallet-and-transaction-ui`, `wagmi-viem-dapp-workflow` |
| `migration-and-backward-compatibility` | `contract-architecture` (for the new design) |

When chaining, handle one subskill at a time. Complete the first before proposing the next.

## Core Execution Flow

1. **Classify** using the decision tree.
2. **Gather** context using the protocol above.
3. **Detect** framework using auto-detection.
4. **Draft** a concrete plan with steps, files, and verification.
5. **Present** the plan to the user with the approval gate.
6. **Gate**: if high/medium risk, stop and wait for explicit confirmation. If low risk, proceed once the user agrees.
7. **Execute** the smallest useful change.
8. **Verify** with the narrowest meaningful check.
9. **Return** structured output.
10. **Self-verify** your classification (see Self-Verification section).

## Output Contract

Every response must include these 6 fields:

1. **Summary** — one sentence explaining what was done
2. **Plan** — concrete, sequenced steps taken or proposed
3. **Assumptions** — explicit decisions or unknowns the user should confirm
4. **Files or Artifacts** — paths or commands involved
5. **Verification** — how the result was or will be checked
6. **Approval Question** — "Is this plan correct?" when gated

### Output Variants by Scenario

**High risk, needs approval:**
```json
{
  "subskill": "contract-review",
  "risk": "high",
  "approvalRequired": true,
  "summary": "Reviewed Solidity vault for access-control issues — found 2 issues",
  "plan": [
    "Read Vault.sol and identify trust boundaries",
    "Found: owner can withdraw any user funds (no timelock)",
    "Found: reentrancy on line 89 via external call before state update"
  ],
  "assumptions": ["The owner role is a trusted multi-sig", "User wants patch suggestions"],
  "files": ["src/Vault.sol"],
  "verification": ["forge test --match-path test/Vault.t.sol"],
  "approvalQuestion": "Review complete. Should I patch the reentrancy issue on line 89?"
}
```

**Medium risk, needs approval:**
```json
{
  "subskill": "refactoring-and-code-health",
  "risk": "medium",
  "approvalRequired": true,
  "summary": "Proposed refactor of useWallet hook to separate concerns",
  "plan": [
    "Split useWallet into useWalletConnection + useWalletBalance",
    "Move RPC config to a separate provider",
    "Update all consumers in pages/ directory"
  ],
  "assumptions": ["No behavioral change expected", "Tests cover the current API surface"],
  "files": ["hooks/useWallet.ts", "hooks/useWalletConnection.ts", "hooks/useWalletBalance.ts"],
  "verification": ["npm test", "npm run build"],
  "approvalQuestion": "Proceed with the refactor as described?"
}
```

**Low risk, proceed after agreement:**
```json
{
  "subskill": "release-notes-and-changelog",
  "risk": "low",
  "approvalRequired": false,
  "summary": "Drafted changelog entry for v1.2.0",
  "plan": [
    "Scanned commits since v1.1.0",
    "Categorized into features, fixes, chores",
    "Drafted entry in CHANGELOG.md"
  ],
  "assumptions": ["All unreleased commits should be included", "Using keepachangelog format"],
  "files": ["CHANGELOG.md"],
  "verification": ["Review the formatted entry visually"],
  "approvalQuestion": "Does this changelog look right? I'll append it to CHANGELOG.md."
}
```

## Self-Verification Checklist

After classifying and before presenting the plan, verify:

- [ ] Does the subskill match the user's primary request keyword?
- [ ] Did I read the minimum context needed? (Not the whole repo)
- [ ] Is my plan the smallest credible change?
- [ ] Did I detect the framework from `package.json`/config, not guess it?
- [ ] Did I include all 6 output fields in my response?
- [ ] If high/medium risk: did I stop for explicit confirmation?
- [ ] If the request is ambiguous: did I ask instead of improvising?
- [ ] Did I avoid RPC, balances, or onchain execution?

## Operating Rules

- **No RPC.** No balances. No wallet or transaction execution.
- **Hand off** broadcast/verification work to `pharos-agent-deploy-suite`.
- **Prefer repo context** (package files, source, tests, local docs, recent diffs) over external references.
- **Prefer the smallest fix** that solves the actual request.
- **If ambiguous**, do not improvise. Present the plan and ask for the missing detail.
- **Verification order**: static check → unit test → targeted integration → build → lint → broader regression only if necessary.
- **Never guess the stack** — read `package.json` and config files.
- **One subskill at a time** — handle chaining sequentially, not in parallel.

## Communication Templates

When you need to ask the user for clarification:

```
I see you want [summary]. To build the right plan, I need:
1. [Missing detail 1]
2. [Missing detail 2]

I'm considering [subskill name] as the best match. Does that sound right?
```

When presenting a plan for approval (high/medium risk):

```
## Plan: [subskill name]

**Summary**: [one sentence]

**Steps**:
1. [step 1]
2. [step 2]

**Files**: [file list]

**Verification**: [check command]

**Assumptions**: [explicit unknowns]

**Risk**: [high/medium] — I'll wait for your confirmation before making any changes.

Is this plan correct, or would you like to adjust it?
```

When presenting a plan for low-risk work:

```
## Plan: [subskill name]

**Summary**: [one sentence]

**Steps**: [steps]

**Files**: [files]

**Verification**: [check]

Does this approach look right? If so, I'll proceed.
```

## Pharos Network Reference

Official Pharos network endpoints for configuration and deployment:

| Network | Chain ID | RPC URL | Explorer | Symbol |
|---|---|---|---|---|
| Pacific Mainnet | 1672 | `https://rpc.pharos.xyz` | https://www.pharosscan.xyz | PROS |
| Atlantic Testnet | 688689 | `https://atlantic.dplabs-internal.com` | https://atlantic.pharosscan.xyz | PHRS |

Use these values for `foundry.toml`, `hardhat.config.ts`, `wagmi` config, or any chain setup:

```toml
# foundry.toml
[rpc_endpoints]
pharos-mainnet = "https://rpc.pharos.xyz"
pharos-testnet = "https://atlantic.dplabs-internal.com"
```

```typescript
// wagmi config
import { defineChain } from 'viem';

export const pharosTestnet = defineChain({
  id: 688689,
  name: 'Pharos Atlantic Testnet',
  nativeCurrency: { name: 'PHRS', symbol: 'PHRS', decimals: 18 },
  rpcUrls: { default: { http: ['https://atlantic.dplabs-internal.com'] } },
  blockExplorers: { default: { name: 'PharosScan', url: 'https://atlantic.pharosscan.xyz' } },
});

export const pharosMainnet = defineChain({
  id: 1672,
  name: 'Pharos Pacific Mainnet',
  nativeCurrency: { name: 'PROS', symbol: 'PROS', decimals: 18 },
  rpcUrls: { default: { http: ['https://rpc.pharos.xyz'] } },
  blockExplorers: { default: { name: 'PharosScan', url: 'https://www.pharosscan.xyz' } },
});
```

Always use these canonical values. Never guess or invent Pharos RPC URLs, chain IDs, or explorer endpoints.

## Pharos-Specific Development Tips

### Solidity on Pharos

- Pharos is EVM-compatible — standard Solidity patterns work out of the box
- Block time is <1 second — time-based logic (`block.timestamp`, `block.number`) needs adjustment compared to Ethereum
- Gas limits on Pharos are higher than Ethereum — large contract deployments are feasible
- Native token is PROS (mainnet) / PHRS (testnet) — use these in `msg.value` checks and ERC-20 wrappers
- Pharos supports both EVM and WASM — contracts written for EVM run natively

### Testing on Pharos

- Use Foundry's `--fork-url` with the testnet RPC for integration tests against real state
- Testnet PHRS can be obtained from the Pharos faucet or bridge
- Gas estimates may differ between testnet and mainnet — always re-estimate before mainnet deploy

### Common Pharos Patterns

- **Token contracts**: Standard ERC-20/721/1155 with PROS/PHRS as native currency
- **DeFi patterns**: Pharos supports all standard DeFi primitives (AMMs, lending, staking)
- **Upgradeability**: UUPS and transparent proxies work identically to Ethereum
- **Cross-chain**: Pharos supports LayerZero, CCTP, and standard bridge patterns
- **SPNs**: Special Processing Networks for app-specific scaling (advanced)

## References

These files live in `skill/references/` and should be read when the task requires deeper guidance:

| File | Read when |
|---|---|
| `references/harness.md` | Full decision tree, risk levels, verification order, what counts as context, success standard |
| `references/output-contract.md` | Detailed response structure with example JSON payload |
| `references/subskills.md` | Extended descriptions of each subskill with more use-when context |

## Example Prompts

- Design the contract architecture for a staking protocol with access control and upgrade boundaries.
- Review this Solidity contract for security, gas, and correctness issues.
- Integrate this Next.js app with wagmi and viem for a wallet connect and transaction preview flow.
- Plan a safe migration path for a contract upgrade without breaking existing users.
- Map this repo so I can start implementing a frontend dapp integration.
- Write the tests for this contract and show the plan before generating them.
- Diagnose this TypeScript build failure and keep the fix narrow.
- Upgrade the dependencies in this repo and verify the build stays green.
- Create a code review checklist for contract changes.
- Improve the accessibility and performance of this wallet preview UI.
- Design contract tests that cover both testnet and mainnet assumptions.
- Set up a Foundry workflow for tests and scripts in this repo.
- Scaffold a starter workspace layout for a new dapp package.
- Plan the deployment flow for testnet and mainnet with release checks.
- Build a Tailwind and shadcn/ui flow for a wallet preview modal.

## Troubleshooting

| Problem | Likely cause | Fix |
|---|---|---|
| Subskill doesn't match the request | The intent routing regex doesn't cover the phrasing | Add the trigger phrase to routing rules in `src/intent/parse-intent.ts` |
| Plan is too broad | Using a general subskill instead of a narrow one | Route to the most specific subskill |
| Agent skipped the plan step | Risk level or approval gate is misconfigured | Check `approvalRequired` in `src/registry/subskills.ts` |
| Output contract fields are missing | Response not following the 6-field structure | Re-read `references/output-contract.md` |
| User asked for onchain execution | Wrong skill suite loaded | Direct to `pharos-agent-deploy-suite` |
| User says plan is wrong direction | Misclassification or missing context | Apologize, re-classify, gather more context, present revised plan |
| Framework not detected | `package.json` not read or unconventional setup | Read `package.json` explicitly, or ask the user which framework |

## Best Practices

- **Route narrowly** — always pick the most specific subskill. Don't use `solidity-authoring` when `contract-review` is the actual request.
- **Plan first, code second** — never jump into edits without showing the plan.
- **Context minimum** — gather only what changes the plan. Don't read the entire repo.
- **One thing at a time** — make the smallest change that solves the request. No scope creep.
- **Verify after every change** — run the narrowest check that confirms the fix.
- **Hand off deployment** — when the user needs broadcast or verification, direct to `pharos-agent-deploy-suite`.
- **Keep the summary short** — one sentence. The structured payload carries the detail.
- **Don't guess stack** — the repo already says what it uses. Read `package.json` and config files.
- **Be explicit about unknowns** — list them as assumptions rather than hiding them.
- **Chain sequentially** — if the request spans multiple subskills, handle them one at a time.
