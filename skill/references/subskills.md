# Subskill Reference

Extended descriptions of all 42 developer subskills. Each entry includes: trigger keywords, when to use, when NOT to use, workflow, verification commands, and cross-references to related subskills.

## Contract Work

### contract-architecture

**Design contract modules, storage layout, access control, and upgrade boundaries before code is written.**

- **Triggers**: "system design", "module boundaries", "storage layout", "access control", "upgradeability", "contract architecture", "design the architecture", "how should I structure"
- **Use when**: The user wants a plan before writing code. Architecture decisions (proxies, storage, roles) need to be made explicit.
- **Do NOT use when**: The user already has a clear architecture and wants to write code — use `solidity-authoring`. The user wants a review of existing code — use `contract-review`.
- **Workflow**: Clarify product goal and trust model → Split into modules with clear interfaces → Identify upgrade/ownership decisions → Present architecture for approval.
- **Verification**: Architecture review against requirements. No code to compile yet.
- **Cross-ref**: → `solidity-authoring` (implementation), `interface-abi-design` (surface), `migration-and-backward-compatibility` (upgrade path)

### solidity-authoring

**Write or refactor Solidity contracts with clear structure, custom errors, events, and modifiers.**

- **Triggers**: "write solidity", "implement contract", "refactor contract", "contract code", "solidity", "write a contract", "implement the staking contract"
- **Use when**: The user wants to write new Solidity code or refactor existing Solidity.
- **Do NOT use when**: The user wants a plan first — use `contract-architecture`. The user wants a review — use `contract-review`.
- **Workflow**: Capture goal, inputs, outputs, invariants → Draft contract shape (errors, events, modifiers) → Show plan → Write code after approval.
- **Verification**: `forge build` or `npx hardhat compile`. Then `forge test` for unit tests.
- **Cross-ref**: `contract-architecture` (design), `interface-abi-design` (ABI), `test-generation` (tests)

### interface-abi-design

**Define interfaces, events, errors, and typed bindings so downstream tooling can integrate cleanly.**

- **Triggers**: "abi", "interface", "events", "errors", "typed bindings", "contract surface", "define the interface", "what events should I emit"
- **Use when**: The user needs to define or refine the public surface of a contract (methods, events, errors).
- **Do NOT use when**: The user wants the full contract implementation — use `solidity-authoring`.
- **Workflow**: List methods, events, revert paths → Normalize naming → Present interface plan → Generate binding skeleton.
- **Verification**: Compile check of interface file. Type generation if using TypeChain or abitype.
- **Cross-ref**: `solidity-authoring` (full implementation), `frontend-dapp-integration` (consuming the ABI)

### protocol-integration-planning

**Plan read/write flows, approvals, and call order for integrating a protocol or contract surface.**

- **Risk**: medium (planning-only, no code changes)

- **Triggers**: "integration", "protocol flow", "call sequence", "approval flow", "contract interaction plan", "how to call", "what transactions"
- **Use when**: The user needs to plan the sequence of contract calls (reads, approvals, writes) for a specific feature.
- **Do NOT use when**: The user is writing the actual integration code — use `frontend-dapp-integration` or `solidity-authoring`.
- **Workflow**: Identify integration target and wallet flow → Sequence reads, approvals, writes, fallbacks → Call out error handling → Present plan.
- **Verification**: Manual review of the call sequence. No code changes.
- **Cross-ref**: `frontend-dapp-integration` (UI wiring), `solidity-authoring` (contract changes)

## UI Work

### frontend-dapp-integration

**Connect UI components to contract actions, state, and transaction previews.**

- **Triggers**: "frontend", "dapp", "ui integration", "wallet connect", "view state", "transaction preview", "wire up the contract", "connect UI to contract"
- **Use when**: The user wants to connect a frontend UI to contract state and methods.
- **Do NOT use when**: The user is designing pure UI without contract interaction — use `dapp-ui-workflow`.
- **Workflow**: Map user journey and contract states → Choose minimal component tree → Show plan → Implement after approval.
- **Verification**: `npm run build`, manual flow check in browser or storybook.
- **Cross-ref**: `wagmi-viem-dapp-workflow` (integration helpers), `wallet-and-transaction-ui` (wallet states)

### wallet-and-transaction-ui

**Design wallet connection, transaction preview, status, and history screens.**

- **Triggers**: "wallet ui", "transaction ui", "preview", "status screen", "history", "connection flow", "wallet connect button", "tx modal"
- **Use when**: The user needs wallet connection UI, transaction preview modals, status indicators, or transaction history.
- **Do NOT use when**: The user is wiring contract reads/writes — use `frontend-dapp-integration`.
- **Workflow**: Identify wallet states, tx states, error states → Define screen sequence → Present UI plan → Build state machine.
- **Verification**: Component renders all states (loading, success, error, empty) in browser or storybook.
- **Cross-ref**: `frontend-dapp-integration` (data wiring), `dapp-ui-workflow` (component patterns)

## Testing & Review

### testing-strategy

**Choose the right test mix, fixtures, and coverage focus before writing tests.**

- **Triggers**: "test strategy", "coverage", "fixtures", "edge cases", "test plan", "what should I test", "test approach"
- **Use when**: The user wants to plan what to test before writing tests.
- **Do NOT use when**: The user wants to generate tests — use `test-generation`.
- **Workflow**: Identify contract/UI risks → Choose unit/integration/regression mix → Present plan → Wait for approval.
- **Verification**: Review of the test matrix. No test files yet.
- **Cross-ref**: `test-generation` (execution), `contract-testing-for-testnet-and-mainnet` (network-aware tests)

### test-generation

**Write unit, integration, or end-to-end tests from the chosen strategy.**

- **Triggers**: "write tests", "generate tests", "fixtures", "mock data", "test files", "add tests for", "test this function"
- **Use when**: The user wants concrete test files written. Assumes a strategy exists or is straightforward.
- **Do NOT use when**: The user first needs a test plan — use `testing-strategy`.
- **Workflow**: Use approved strategy → Draft test cases → Show plan → Generate tests → Verify they pass/fail as intended.
- **Verification**: `forge test` or `npx hardhat test` or `npm test`.
- **Cross-ref**: `testing-strategy` (planning), `contract-testing-for-testnet-and-mainnet` (network-specific)

### contract-review

**Review Solidity code for correctness, security, gas, and design issues.**

- **Triggers**: "review contract", "audit", "security review", "solidity review", "gas review", "check this contract", "look for bugs"
- **Use when**: The user wants a human-readable review of existing Solidity code.
- **Do NOT use when**: The user wants automated analysis or fuzzing — use Foundry's `forge test` or fuzz directly.
- **Workflow**: Read contract surface → Identify trust boundaries → Check access control, invariants, unsafe patterns → Summarize with severity.
- **Verification**: Manual review only. Optionally recommend `slither` or `forge inspect` for automated checks.
- **Cross-ref**: `bug-finding-and-debugging` (fixing issues found in review), `solidity-authoring` (patching)

### bug-finding-and-debugging

**Trace failures in compile, runtime, test, or UI behavior and propose focused fixes.**

- **Triggers**: "bug", "debug", "error", "failing build", "failing test", "runtime issue", "something is broken", "not working"
- **Use when**: The user has a specific failure and needs root cause analysis and fix.
- **Do NOT use when**: The user wants a general review without a specific failure — use `contract-review`.
- **Workflow**: Reproduce or reason from error output → Isolate root cause and smallest fix → Show fix plan → Patch → Verify.
- **Verification**: The specific failing test/command passes. Re-run the original failing command.
- **Cross-ref**: `contract-review` (review before fixing), `ci-and-build-troubleshooting` (pipeline failures)

### contract-testing-for-testnet-and-mainnet

**Design contract test coverage and environment-aware checks for both network contexts.**

- **Triggers**: "contract testing", "testnet tests", "mainnet tests", "network-specific testing", "environment-aware tests"
- **Use when**: The user needs tests that differentiate between testnet and mainnet behavior (fork tests, network-specific assertions).
- **Do NOT use when**: General unit test generation — use `test-generation`.
- **Workflow**: Separate local unit coverage from network-aware checks → Plan how testnet/mainnet differ → Show plan → Generate tests after approval.
- **Verification**: `forge test --fork-url <network>` or hardhat network fork tests.
- **Cross-ref**: `testing-strategy` (general planning), `deployment-for-testnet-and-mainnet` (deploy counterpart)

## Framework & Tooling

### framework-integration

**Wire Pharos development patterns into Next.js, wagmi, viem, ethers, Foundry, Hardhat, or Remix.**

- **Triggers**: "next.js", "wagmi", "viem", "ethers", "foundry", "hardhat", "remix", "framework setup", "add pharos to"
- **Use when**: The user needs to add or configure Pharos support in a framework or toolchain.
- **Do NOT use when**: The user is already using the framework and needs a specific feature — use the workflow-specific subskill (e.g., `wagmi-viem-dapp-workflow`).
- **Workflow**: Detect framework → Map minimal integration changes → Show plan → Proceed after agreement.
- **Verification**: `npm run build` or framework-specific config check.
- **Cross-ref**: `wagmi-viem-dapp-workflow`, `foundry-hardhat-contract-workflow`, `dapp-ui-workflow`, `remix-contract-workflow`

### ci-and-build-troubleshooting

**Diagnose failing builds, type errors, lint jobs, and CI regressions with a narrow fix path.**

- **Triggers**: "ci", "build failure", "lint failure", "type error", "pipeline", "broken test job", "build is failing", "CI is red"
- **Use when**: A build, type check, lint, or CI pipeline is failing and the user needs the root cause and fix.
- **Do NOT use when**: The build passes but the user wants improvements — use `performance-optimization` or `refactoring-and-code-health`.
- **Workflow**: Read failure output → Isolate failing stage → Narrow fix to smallest change → Show plan → Apply → Verify.
- **Verification**: The exact failing command passes. Re-run the pipeline step or equivalent local command.
- **Cross-ref**: `bug-finding-and-debugging` (runtime bugs, not build failures)

### repo-onboarding

**Map the codebase, entrypoints, scripts, and conventions so future work starts from the right place.**

- **Triggers**: "onboard", "map repo", "entrypoints", "project layout", "where is the code", "how is this repo structured", "what's here"
- **Use when**: The user is new to the repo or needs a structural overview before starting work.
- **Do NOT use when**: The user already knows the repo and just needs a specific file or command.
- **Workflow**: Identify app entrypoints, scripts, top-level modules → Summarize conventions → Return concise map.
- **Verification**: N/A — read-only exploration. Optionally ask the user if the map matches expectations.
- **Cross-ref**: All other subskills (this is a prelude to any development work).

### deployment-for-testnet-and-mainnet

**Plan and validate contract deployments across testnet and mainnet with environment-aware safeguards.**

- **Triggers**: "testnet", "mainnet", "deployment", "release", "deploy flow", "network-specific deploy"
- **Use when**: The user needs to plan deployment to a specific network with environment-specific safeguards.
- **Do NOT use when**: The user is preparing deploy scripts (use `deployment-and-verification`) or ready to broadcast (requires explicit approval).
- **Workflow**: Identify target network and release assumptions → Separate testnet validation from mainnet release → Show plan → Deploy after approval.
- **Verification**: Network-aware dry run. Confirm the correct RPC, chain ID, and artifact.
- **Cross-ref**: `deployment-and-verification` (script prep), `contract-testing-for-testnet-and-mainnet` (test counterpart), `post-deploy` (post-deployment ops)

### dependency-upgrade-management

**Upgrade packages or toolchains with version-aware compatibility checks and rollback planning.**

- **Triggers**: "dependency upgrade", "package update", "toolchain update", "version bump", "upgrade dependencies", "update packages"
- **Use when**: The user needs to upgrade one or more dependencies and wants a safe, minimal upgrade path.
- **Do NOT use when**: The user just wants to add a new dependency — use `framework-integration` or the relevant workflow subskill.
- **Workflow**: List packages to upgrade → Check compatibility risk and code changes → Show plan → Apply after approval → Verify.
- **Verification**: `npm install`/`yarn`, then `npm run build`/`npm test`.
- **Cross-ref**: `monorepo-workspace-management` (workspace-wide upgrades)

### monorepo-workspace-management

**Handle workspace boundaries, package scripts, and shared tooling in monorepos.**

- **Triggers**: "monorepo", "workspace", "turborepo", "pnpm workspace", "shared package", "workspace boundaries", "package scripts"
- **Use when**: The user wants to reorganize workspace boundaries, add/remove packages, or fix workspace scripts.
- **Do NOT use when**: Working within a single package — use the relevant feature subskill.
- **Workflow**: Map workspace structure → Identify minimum changes → Show plan → Apply → Verify affected packages.
- **Verification**: `npm run build` across all packages or `turbo run build`.
- **Cross-ref**: `dependency-upgrade-management` (package version changes)

### repo-automation-and-tooling

**Design scripts, automation flows, task runners, and local developer tooling.**

- **Triggers**: "automation", "scripts", "task runner", "makefile", "precommit", "tooling", "set up linting", "husky"
- **Use when**: The user wants to automate a repo workflow (linting on commit, build scripts, dev tooling).
- **Do NOT use when**: The user wants to modify application code — use the relevant feature subskill.
- **Workflow**: Identify repetitive task → Choose lightest automation → Show plan → Implement after agreement.
- **Verification**: Run the automated script/check and confirm it works.
- **Cross-ref**: `code-review-templates-and-checklists` (process automation, not code automation)

### code-review-templates-and-checklists

**Create review templates, PR checklists, and evaluation rubrics for better code review hygiene.**

- **Triggers**: "code review template", "pr checklist", "review rubric", "review checklist", "review notes", "PR template"
- **Use when**: The user wants a reusable checklist or template for code reviews.
- **Do NOT use when**: The user wants actual code review — use `contract-review`.
- **Workflow**: Identify audience and goals → Draft concise checklist → Show outline → Proceed after agreement.
- **Verification**: Visual review of the template.
- **Cross-ref**: `repo-automation-and-tooling` (automating PR checks)

### dapp-ui-workflow

**Build the complete UI layer of a Pharos dapp — React components, Next.js App Router pages, styling with Tailwind/shadcn, and custom hooks wired to wagmi/viem.**

- **Triggers**: "dapp ui", "frontend component", "page layout", "tailwind", "shadcn", "next.js app router", "react hook", "component design", "styling"
- **Use when**: The user is building or modifying the frontend UI layer of a Pharos dapp — components, layouts, routing, styling, and React hooks.
- **Do NOT use when**: The user needs wallet connect or tx UI patterns — use `wallet-and-transaction-ui`. Contract integration wiring — use `frontend-dapp-integration` or `wagmi-viem-dapp-workflow`.
- **Workflow**: Identify dapp UI surface → Map components/hooks/routes → Choose minimal pattern → Show plan → Implement after agreement.
- **Verification**: `npm run build` and visual rendering check.
- **Cross-ref**: `dapp-quality` (a11y, i18n, state), `wallet-and-transaction-ui` (tx UX), `frontend-dapp-integration` (contract state wiring)

### wagmi-viem-dapp-workflow

**Handle wallet connection, contract reads, writes, and dapp integration patterns using Wagmi and Viem.**

- **Triggers**: "wagmi", "viem", "wallet connect", "contract read", "contract write", "dapp workflow", "useContractRead", "useContractWrite"
- **Use when**: The user needs Wagmi/Viem configuration, hooks, or contract integration patterns.
- **Do NOT use when**: The user needs a full frontend layout — use `dapp-ui-workflow`.
- **Workflow**: Map contract and wallet interactions → Choose minimal Wagmi/Viem pattern → Show plan → Verify config.
- **Verification**: Config validation in dev tools, component renders without errors.
- **Cross-ref**: `frontend-dapp-integration` (UI wiring), `dapp-ui-workflow` (UI components)

### foundry-hardhat-contract-workflow

**Set up Solidity development workflows for Foundry or Hardhat, including tests, scripts, and local runs.**

- **Triggers**: "foundry", "hardhat", "forge", "anvil", "solidity workflow", "contract workflow", "forge init", "hardhat init"
- **Use when**: The user needs to set up or improve their contract development workflow (compilation, testing, scripting).
- **Do NOT use when**: The user is writing individual contracts — use `solidity-authoring`.
- **Workflow**: Identify contract task and dev stack → Choose smallest workflow → Show plan → Verify.
- **Verification**: `forge test` or `npx hardhat test`.
- **Cross-ref**: `framework-integration` (initial setup), `solidity-authoring` (writing contracts)

### remix-contract-workflow

**Set up Remix-based contract development, testing, and quick iteration flows.**

- **Triggers**: "remix", "browser solidity", "quick contract iteration", "remix workflow", "remix IDE"
- **Use when**: The user is using Remix in the browser for rapid Solidity prototyping.
- **Do NOT use when**: The user needs a local environment — use `foundry-hardhat-contract-workflow`.
- **Workflow**: Identify contract task and Remix constraints → Choose smallest workflow → Show plan → Verify.
- **Verification**: Manual check in Remix IDE.
- **Cross-ref**: `foundry-hardhat-contract-workflow` (local alternative)

### dapp-quality

**Make Pharos dapps production-ready: accessibility auditing, internationalization, state management, and overall UX quality.**

- **Triggers**: "a11y", "accessibility", "i18n", "localization", "translation", "state management", "zustand", "redux", "ux quality", "dapp polish"
- **Use when**: The user needs dapp accessibility audit, multi-language support, dapp-wide state management, or general UI quality improvements.
- **Do NOT use when**: The user needs component UI patterns — use `dapp-ui-workflow`. Wallet/tx UX — use `wallet-and-transaction-ui`.
- **Workflow**: Identify quality dimension (a11y/i18n/state) → Audit current state → Propose fixes → Show plan → Implement → Verify.
- **Verification**: a11y: keyboard nav + axe-core. i18n: locale switch test. State: component render with correct data.
- **Cross-ref**: `dapp-ui-workflow` (UI components), `wallet-and-transaction-ui` (tx UX), `frontend-dapp-integration` (contract state)

## Quality & Performance

### refactoring-and-code-health

**Improve structure, readability, naming, and separation of concerns without changing behavior.**

- **Triggers**: "refactor", "code health", "cleanup", "simplify", "remove duplication", "technical debt", "restructure"
- **Use when**: The user wants to clean up code structure without changing observable behavior.
- **Do NOT use when**: The user needs a new feature — use the relevant authoring subskill. The user has a bug — use `bug-finding-and-debugging`.
- **Workflow**: Identify code smells → Propose refactor scope and behavior guarantees → Show plan → Apply after approval.
- **Verification**: No change in test results. `npm test` still passes. Diff shows no behavior change.
- **Cross-ref**: `performance-optimization` (performance-driven changes), `solidity-authoring` (contract refactors)

### performance-optimization

**Find and reduce runtime, render, bundle, or gas-adjacent inefficiencies in code paths.**

- **Triggers**: "performance", "optimize", "slow", "bottleneck", "bundle size", "latency", "gas optimization", "too slow"
- **Use when**: The user wants to improve speed, reduce bundle size, or optimize resource usage.
- **Do NOT use when**: The user wants readability improvements — use `refactoring-and-code-health`.
- **Workflow**: Locate bottleneck → Propose measurable optimization → Show plan → Implement → Verify improvement.
- **Verification**: Before/after metric comparison (render time, bundle size, gas estimate).
- **Cross-ref**: `refactoring-and-code-health` (non-performance structure changes)

## Shipping & Docs

### deployment-and-verification

**Prepare deploy scripts, env variables, explorer verification, and post-deploy checks.**

- **Triggers**: "deploy", "verification", "explorer", "release", "publish contract", "deployment prep"
- **Use when**: The user needs to prepare deployment artifacts, scripts, or checks before the actual broadcast.
- **Do NOT use when**: The user is ready to broadcast — requires explicit approval before execution.
- **Workflow**: Confirm deployment target and config → Draft deploy/verification steps → Show plan → Prepare artifacts after approval.
- **Verification**: Dry run or script syntax check. Not a real broadcast.
- **Cross-ref**: `deployment-for-testnet-and-mainnet` (network planning), `post-deploy` (post-deployment ops)

### migration-and-backward-compatibility

**Plan safe migrations, data moves, and compatibility guardrails for upgrades or rewrites.**

- **Triggers**: "migration", "backward compatibility", "upgrade path", "data move", "breaking change", "version upgrade"
- **Use when**: The user needs to plan a migration path with backward compatibility or rollback options.
- **Do NOT use when**: The user just wants to write new code — use the relevant authoring subskill.
- **Workflow**: Identify old state, new state, compatibility boundary → Map migration path and rollbacks → Show plan → Implement after approval.
- **Verification**: Migration script dry run. Compatibility test with existing data.
- **Cross-ref**: `contract-architecture` (designing for upgradeability), `deployment-and-verification` (deploying the migration)

### release-notes-and-changelog

**Turn a set of code changes into clear release notes, changelog entries, or PR summaries.**

- **Triggers**: "release notes", "changelog", "release summary", "pr summary", "shipping notes", "what changed"
- **Use when**: The user needs release documentation derived from code changes.
- **Do NOT use when**: The user wants live deployment — use `deployment-and-verification` and execute after approval.
- **Workflow**: Scan changes since last tag → Categorize into features, fixes, chores → Draft entry → Show for review.
- **Verification**: Visual review. No code change needed.
- **Cross-ref**: `code-scaffolding-and-generation` (file generation variant)

### code-scaffolding-and-generation

**Generate starter files, boilerplate, or project scaffolds for a new developer workflow.**

- **Triggers**: "scaffold", "starter", "boilerplate", "generate files", "template", "create a new", "initialize"
- **Use when**: The user needs new files or project structure generated from scratch.
- **Do NOT use when**: The user is editing existing code — use the relevant subskill.
- **Workflow**: Identify target structure → Draft scaffold → Show plan → Generate after agreement.
- **Verification**: File structure check. `npm run build` or `forge build`.
- **Cross-ref**: `docs-and-example-generation` (content, not structure)

### docs-and-example-generation

**Write clear docs, usage instructions, and examples for developers and agents.**

- **Triggers**: "docs", "readme", "examples", "usage instructions", "agent prompt", "guides", "documentation"
- **Use when**: The user needs documentation, README updates, or usage examples.
- **Do NOT use when**: The user needs file structure — use `code-scaffolding-and-generation`.
- **Workflow**: Identify audience and usage scenario → Draft concise docs → Show outline → Proceed after agreement.
- **Verification**: Visual review of the documentation.
- **Cross-ref**: `code-scaffolding-and-generation` (generating file structure), `release-notes-and-changelog` (release docs)

### cross-chain-bridge

**Plan cross-chain messaging, bridge integrations, and token transfers across supported protocols.**

- **Risk**: high (cross-chain value transfer requires careful planning)
- **Triggers**: "cross-chain", "bridge", "layerzero", "cctp", "spn mailbox", "lz", "oft", "cross-chain messaging"
- **Use when**: The user needs to integrate cross-chain messaging, configure LayerZero OFT, or plan CCTP token transfer flows.
- **Do NOT use when**: The user is working within a single chain — use the relevant contract or integration subskill.
- **Workflow**: Identify source and destination chains → Choose bridge protocol → Plan call sequence and fees → Show plan → Implement after approval.
- **Verification**: Compile check. Cross-chain integration test on testnet.
- **Cross-ref**: `spn-development` (SPN-specific cross-chain), `protocol-integration-planning` (single-chain integration), `deployment-patterns.md` (cross-chain deployment)

### upgrade-patterns

**Design and implement contract upgrade patterns: UUPS, Transparent proxy, and Beacon proxy.**

- **Risk**: high (proxy misconfiguration can freeze funds)
- **Triggers**: "upgrade", "proxy", "uups", "transparent proxy", "beacon", "upgradeable", "initializable", "deploy proxy"
- **Use when**: The user needs to design, implement, or verify an upgradeable contract pattern.
- **Do NOT use when**: The user is designing a static contract — use `contract-architecture` or `solidity-authoring`.
- **Workflow**: Identify upgrade requirements (versioned storage, access control) → Choose proxy pattern → Design storage layout → Show plan → Implement after approval.
- **Verification**: Compile check. Test upgrade path from v1 to v2.
- **Cross-ref**: `contract-architecture` (system design), `migration-and-backward-compatibility` (data migration), `deployment-patterns.md` (upgrade deployment)

### gas-optimization

**Analyze and optimize Solidity contract gas usage using SALI patterns and advanced techniques.**

- **Risk**: medium (optimizations are low-risk but change contract bytecode)
- **Triggers**: "gas", "gas optimization", "gas cost", "save gas", "expensive", "sal"
- **Use when**: The user wants to reduce gas costs in Solidity contracts through verified optimization patterns.
- **Do NOT use when**: The user needs general performance improvements — use `performance-optimization`.
- **Workflow**: Identify high-gas operations (loops, storage, calls) → Apply SALI patterns → Show gas savings estimate → Implement after approval.
- **Verification**: `forge test --gas-report` or Hardhat gas reporter. Compare before/after gas estimates.
- **Cross-ref**: `performance-optimization` (non-gas performance), `contract-review` (gas found in review), `solidity-authoring` (applying optimizations)

### security-audit

**Prepare for and conduct security audit readiness reviews of Solidity contracts.**

- **Risk**: high (audit prep is time-sensitive; missed issues have real cost)
- **Triggers**: "audit", "security audit", "audit prep", "audit readiness", "formal verification", "code freeze"
- **Use when**: The user needs to prepare for a security audit or review audit readiness.
- **Do NOT use when**: The user wants a casual code review — use `contract-review`.
- **Workflow**: Identify audit scope and threat model → Freeze code → Run static analysis → Generate audit readiness report → Present findings.
- **Verification**: Slither, solhint, forge test, manual review against checklist.
- **Cross-ref**: `contract-review` (pre-audit review), `gas-optimization` (gas findings), `bug-finding-and-debugging` (fixing issues)

### production-ops

**Set up monitoring, alerting, and incident response for deployed Pharos contracts.**

- **Risk**: high (production monitoring gaps can cause missed incidents)
- **Triggers**: "monitoring", "alerting", "incident response", "production ops", "contract monitoring", "event tracking", "uptime"
- **Use when**: The user needs operational tooling for live contracts — event monitoring, alert rules, dashboards.
- **Do NOT use when**: The user is deploying new contracts — use `deployment-and-verification` or the deploy suite.
- **Workflow**: Identify contract events and critical paths → Choose monitoring approach → Set up alerting rules → Show plan → Implement after approval.
- **Verification**: Deploy monitoring config, verify alerts trigger on test events.
- **Cross-ref**: `deployment-and-verification` (deploy prep), `pharos-ecosystem.md` (RPC, explorers)

### spn-development

**Develop and integrate Special Processing Networks (SPNs) on Pharos.**

- **Risk**: high (SPN configuration affects network resources)
- **Triggers**: "spn", "special processing network", "spn development", "spn integration", "pharos spn", "appchain"
- **Use when**: The user needs to design, develop, or integrate an SPN on Pharos.
- **Do NOT use when**: The user is building a standard contract — use the relevant contract subskill.
- **Workflow**: Identify SPN requirements and scaling needs → Design SPN architecture → Plan integration with main chain → Show plan → Implement after approval.
- **Verification**: SPN deployment test on testnet. Cross-chain message test.
- **Cross-ref**: `cross-chain-bridge` (cross-chain messaging), `pharos-ecosystem.md` (SPN contracts)

### rwa-compliance

**Design and implement Real World Asset (RWA) compliance patterns for Pharos tokens.**

- **Risk**: high (compliance errors have legal and regulatory consequences)
- **Triggers**: "rwa", "real world asset", "compliance", "tokenization", "kyc", "accredited investor", "security token"
- **Use when**: The user needs to implement compliance-aware tokenization for real-world assets.
- **Do NOT use when**: The user needs a standard ERC-20/721 — use `solidity-authoring`.
- **Workflow**: Identify compliance requirements (jurisdiction, investor tiers) → Design compliance controls → Plan tokenization → Show plan → Implement after approval.
- **Verification**: Compliance rule tests. Role-based access verification.
- **Cross-ref**: `contract-architecture` (system design), `solidity-authoring` (implementation), `contract-review` (compliance review)

### workflow-orchestrator

**Orchestrate multi-step development workflows by chaining subskills in sequence.**

- **Risk**: low (planning meta-subskill, no code changes on its own)
- **Triggers**: "orchestrate", "workflow", "multi-step", "end to end", "full pipeline", "automate workflow"
- **Use when**: The user wants to run a multi-step workflow that spans multiple subskills (e.g., design → implement → test → deploy).
- **Do NOT use when**: The request fits a single subskill — route to that subskill directly.
- **Workflow**: Identify end-to-end goal → Break into sequential steps → Map each step to a subskill → Present orchestration plan → Execute one step at a time.
- **Verification**: Each step verified independently before the next begins.
- **Cross-ref**: All subskills (this is a meta-subskill for chaining them)

## Subskill Families

The 39 subskills are grouped into three families for organizational clarity:

- **Repo automation and maintenance**: repo-onboarding, repo-automation-and-tooling, dependency-upgrade-management, monorepo-workspace-management, code-review-templates-and-checklists
- **Framework-specific implementation**: framework-integration, wagmi-viem-dapp-workflow, foundry-hardhat-contract-workflow, remix-contract-workflow, dapp-ui-workflow, dapp-quality
- **Review, release, and authoring**: contract-review, bug-finding-and-debugging, deployment-and-verification, migration-and-backward-compatibility, release-notes-and-changelog, code-scaffolding-and-generation, docs-and-example-generation

## Classification Rule

The master skill routes to **the narrowest subskill** that can solve the request without inventing extra work. If the user says "review this contract", route to `contract-review`, not `solidity-authoring`. If the user says "set up tests for this", route to `testing-strategy` first (plan), then offer `test-generation` (execution) as a follow-up.

When an intent is ambiguous between subskills, default to the more specific one. If "improve this hook" could match `dapp-ui-workflow` or `refactoring-and-code-health`, use `dapp-ui-workflow` if it's a UI hook, or `refactoring-and-code-health` if it's a data logic hook.
