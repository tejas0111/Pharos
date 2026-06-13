# Pharos Pro Dev Harness

Operational reference for the Pharos dev skill suite. This document contains the detailed decision logic, risk protocol, context rules, verification hierarchy, and success criteria. The master SKILL.md holds the concise version; this is the deep reference for when the agent needs procedural detail.

## Decision Tree (Detailed)

The master skill routes to 43 developer subskills + 3 deployment subskills. Classification follows this process:

### Step 1: Broad Category

Read the user's request and map it to one of 6 categories:

| Category | Primary subskills |
|---|---|---|
| Contract Work | contract-architecture, solidity-authoring, interface-abi-design, protocol-integration-planning, upgrade-patterns, rwa-compliance |
| UI Work | frontend-dapp-integration, wallet-and-transaction-ui |
| Testing & Review | testing-strategy, test-generation, contract-review, bug-finding-and-debugging, contract-testing-for-testnet-and-mainnet |
| Framework & Tooling | framework-integration, ci-and-build-troubleshooting, repo-onboarding, dependency-upgrade-management, monorepo-workspace-management, repo-automation-and-tooling, code-review-templates-and-checklists, deployment-for-testnet-and-mainnet, nextjs-app-router-and-server-actions, react-ui-patterns-and-hooks, wagmi-viem-dapp-workflow, foundry-hardhat-contract-workflow, remix-contract-workflow, tailwind-shadcn-ui-workflow |
| Integration | cross-chain-bridge, spn-development |
| Quality & Performance | refactoring-and-code-health, performance-optimization, accessibility-review, state-management-integration, gas-optimization, security-audit |
| Shipping & Docs | deployment-and-verification, migration-and-backward-compatibility, release-notes-and-changelog, code-scaffolding-and-generation, docs-and-example-generation, localization-and-copy |
| Operations | production-ops |
| Workflow | workflow-orchestrator |

### Step 2: Narrow to a Single Subskill

Within the category, choose the narrowest subskill using the routing rules in the master SKILL.md decision tree. The rule is: **if multiple subskills match, pick the one that covers the primary request**. Mention secondary matching subskills in the plan as follow-up suggestions.

### Step 3: Gather Context

Read only the files that change the plan. See the Context Gathering Protocol in the master SKILL.md for category-specific guidance. If you cannot determine the stack after reading `package.json` and config files, ask the user rather than guessing.

### Step 4: Detect Framework

Use auto-detection from `package.json` dependencies, config files (`foundry.toml`, `hardhat.config.*`, `next.config.*`, `vite.config.ts`), and import patterns. The master SKILL.md framework detection table maps signals to detected tools.

### Step 5: Draft the Plan

The plan must be:
- Concrete (specific files, functions, commands)
- Sequenced (step 1, step 2, step 3)
- Minimal (the smallest change that satisfies the request)
- Verifiable (each step has a check)

### Step 6: Determine the Gate

Look up `approvalRequired` and `risk` in the registry (`src/registry/subskills.ts`):

| risk | approvalRequired | Behavior |
|---|---|---|
| high | true | Stop and wait for explicit confirmation before any edits |
| medium | true | Stop and wait for explicit confirmation before any edits |
| low | false | Present plan, proceed once user agrees |

If the request is ambiguous, do not improvise. Present the classification and ask for clarification.

### Step 7: Execute

Make the smallest change that solves the request. Verify immediately. Do not scope creep.

### Step 8: Verify

Use the narrowest meaningful check in this order:
1. Static check (compile, syntax, typecheck)
2. Unit test (the specific function or contract)
3. Targeted integration test (the specific flow)
4. Build (full project build)
5. Lint or typecheck (if applicable)
6. Broader regression (only if necessary)

### Step 9: Return

Return the 6-field output contract. See `output-contract.md` for the full shape.

## What Counts As Context

The minimum needed to build the right plan:

- **package files**: `package.json`, `foundry.toml`, `hardhat.config.*`, `next.config.*`, `tsconfig.json` — detect stack and dependencies
- **source files in scope**: the files the user mentions or that directly relate to the request
- **tests**: existing test patterns, test config, fixtures
- **local docs**: README, CONTRIBUTING, any `.md` files in the relevant directory
- **recent diffs or failing output**: error logs, CI output, test failure traces
- **framework config**: the config file(s) for the detected framework

Do NOT read: unrelated modules, third-party libraries (unless you need their types), vendor directories, build artifacts, node_modules, typechain outputs, deployment artifacts from other networks.

## Risk Levels (Registry Source of Truth)

Derived from `src/registry/subskills.ts`. The registry is authoritative; this list mirrors it for quick reference.

### High Risk (approvalRequired: true) — 14 subskills

| Subskill | Why |
|---|---|
| contract-architecture | System design decisions affect all downstream code |
| solidity-authoring | Writes/refactors deployed contract code |
| contract-review | Security and correctness findings |
| bug-finding-and-debugging | Modifies contract or critical UI logic |
| deployment-and-verification | Prepares deploy scripts and release flows |
| migration-and-backward-compatibility | Plans upgrades and data moves |
| deployment-for-testnet-and-mainnet | Network-aware deployment planning |
| ci-and-build-troubleshooting | Changes build config, CI pipelines, or type settings |
| cross-chain-bridge | Cross-chain value transfer requires careful planning |
| upgrade-patterns | Proxy misconfiguration can freeze funds |
| security-audit | Audit prep is time-sensitive; missed issues have real cost |
| production-ops | Production monitoring gaps can cause missed incidents |
| spn-development | SPN configuration affects network resources |
| rwa-compliance | Compliance errors have legal and regulatory consequences |

### Medium Risk (approvalRequired: true) — 14 subskills

| Subskill | Why |
|---|---|
| interface-abi-design | Contract surface changes affect consumers |
| frontend-dapp-integration | Wires UI to contract state |
| wallet-and-transaction-ui | Handles wallet states and tx previews |
| protocol-integration-planning | Defines call sequences and approval flows (planning-only) |
| testing-strategy | Defines test coverage and fixtures |
| test-generation | Writes concrete tests |
| contract-testing-for-testnet-and-mainnet | Network-specific test design |
| refactoring-and-code-health | Changes code structure (behavior-preserving) |
| dependency-upgrade-management | Changes package versions |
| performance-optimization | Modifies code paths |
| accessibility-review | Changes UI behavior |
| state-management-integration | Wires state tools |
| monorepo-workspace-management | Changes workspace boundaries |
| gas-optimization | Optimizations are low-risk but change contract bytecode |

### Low Risk (approvalRequired: false) — 15 subskills

| Subskill | Why |
|---|---|
| framework-integration | Config-only or add-only changes |
| repo-onboarding | Read-only exploration |
| repo-automation-and-tooling | Non-deployed automation |
| code-review-templates-and-checklists | Documentation-only |
| nextjs-app-router-and-server-actions | UI routing patterns |
| react-ui-patterns-and-hooks | Component patterns |
| wagmi-viem-dapp-workflow | Integration patterns |
| foundry-hardhat-contract-workflow | Workflow setup |
| remix-contract-workflow | Browser workflow |
| tailwind-shadcn-ui-workflow | Styling patterns |
| release-notes-and-changelog | Documentation-only |
| code-scaffolding-and-generation | Creates new files, no existing code change |
| docs-and-example-generation | Documentation-only |
| localization-and-copy | Text-only changes |
| workflow-orchestrator | Planning meta-subskill, no code changes on its own |

## What Not To Do

- Do not switch into RPC, balances, or transaction execution — hand off to `pharos-agent-deploy-suite`.
- Do not guess the stack when the repo already says what it is.
- Do not make large unrelated refactors while fixing a small issue.
- Do not treat a risky change as a no-risk change — verify the subskill's risk level in the registry.
- Do not skip the plan stage — always present a plan, even for low-risk subskills.
- Do not improvise when the request is ambiguous — ask for clarification.
- Do not chain subskills in parallel — handle one at a time, sequentially.
- Do not read the entire repo — gather only the minimum context.
- Do not hardcode RPC URLs, chain IDs, private keys, or API endpoints.

## Output Shape

Every response must include these 6 fields:

1. **Summary** — one sentence describing what was done
2. **Plan** — concrete, sequenced steps taken or proposed
3. **Assumptions** — explicit decisions or unknowns the user should confirm
4. **Files or Artifacts** — paths or commands involved
5. **Verification** — how the result was or will be checked
6. **Approval Question** — "Is this plan correct?" when gated

See `references/output-contract.md` for full payload shapes and edge case examples.

## Verification Order

Always prefer the smallest useful verification:

1. **Static check**: compile, syntax, typecheck — fastest feedback
2. **Unit test**: single function or contract method
3. **Targeted integration test**: specific flow across module boundaries
4. **Build**: full project build
5. **Lint or typecheck**: code style and type safety
6. **Broader regression**: only when the change has wide impact

If verification fails, stop and report the failure. Do not continue to a broader check.

## Success Standard

A good response makes it obvious:

- **What subskill was used** — the classification is clear
- **What changed** — the plan matches the execution
- **Why the plan is safe** — risk level is stated, assumptions are explicit
- **How the change was verified** — verification command or check is provided
- **What the next step should be** — follow-up suggestions are scoped

## Edge Cases

| Scenario | Response |
|---|---|
| Request matches multiple subskills equally | Pick the most specific one; mention alternatives as follow-up suggestions |
| User says "I don't know what I need" | Use repo-onboarding to map the codebase, then suggest the right subskill |
| User asks for a change that spans contract + frontend + deploy | Handle contract first, then frontend, then deploy — sequentially |
| User provides no detail ("fix this") | Read the failing output or diff, determine the subskill, present a plan |
| User contradicts the subskill classification | Apologize, re-classify, gather more context, present a revised plan |
| Deploy handoff: user asks to broadcast during dev session | Hand off to `pharos-agent-deploy-suite` with the prepared script and config |
| The repo uses an unknown framework | Ask the user: "Which framework/toolchain are you using?" |
