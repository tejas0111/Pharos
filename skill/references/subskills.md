# Subskill Reference

Extended descriptions of all 35 developer subskills. Each entry includes: trigger keywords, when to use, when NOT to use, workflow, verification commands, and cross-references to related subskills.

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
- **Do NOT use when**: The user is designing pure UI without contract interaction — use `react-ui-patterns-and-hooks` or `tailwind-shadcn-ui-workflow`.
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
- **Cross-ref**: `frontend-dapp-integration` (data wiring), `react-ui-patterns-and-hooks` (component patterns)

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
- **Cross-ref**: `wagmi-viem-dapp-workflow`, `foundry-hardhat-contract-workflow`, `nextjs-app-router-and-server-actions`, `remix-contract-workflow`, `tailwind-shadcn-ui-workflow`

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
- **Do NOT use when**: The user is preparing deploy scripts (use `deployment-and-verification`) or ready to broadcast (hand off to `pharos-agent-deploy-suite`).
- **Workflow**: Identify target network and release assumptions → Separate testnet validation from mainnet release → Show plan → Deploy after approval.
- **Verification**: Network-aware dry run. Confirm the correct RPC, chain ID, and artifact.
- **Cross-ref**: `deployment-and-verification` (script prep), `contract-testing-for-testnet-and-mainnet` (test counterpart), `pharos-agent-deploy-suite` (broadcast)

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

### nextjs-app-router-and-server-actions

**Handle Next.js App Router, route handlers, server actions, and RSC patterns.**

- **Triggers**: "next.js app router", "server actions", "route handlers", "rsc", "nextjs", "layout", "loading.tsx", "error.tsx"
- **Use when**: The user is working with Next.js App Router patterns, server actions, or React Server Components.
- **Do NOT use when**: Using Next.js Pages Router — this subskill is App Router only.
- **Workflow**: Map route, server, client boundaries → Choose minimal App Router pattern → Show plan → Implement after agreement.
- **Verification**: `npm run build` and manual route navigation.
- **Cross-ref**: `react-ui-patterns-and-hooks` (client components), `wagmi-viem-dapp-workflow` (contract integration)

### react-ui-patterns-and-hooks

**Improve React hooks, component boundaries, and client-side UI patterns.**

- **Triggers**: "react hooks", "component pattern", "context", "state hook", "ui patterns", "custom hook", "component design"
- **Use when**: The user wants help with React component architecture, custom hooks, or rendering patterns.
- **Do NOT use when**: The user is working with dapp-specific patterns — use `wagmi-viem-dapp-workflow` or `frontend-dapp-integration`.
- **Workflow**: Identify state and rendering pattern → Suggest smallest React pattern → Show plan → Implement after agreement.
- **Verification**: `npm run build` and component rendering check.
- **Cross-ref**: `state-management-integration` (global state), `frontend-dapp-integration` (dapp-specific)

### wagmi-viem-dapp-workflow

**Handle wallet connection, contract reads, writes, and dapp integration patterns using Wagmi and Viem.**

- **Triggers**: "wagmi", "viem", "wallet connect", "contract read", "contract write", "dapp workflow", "useContractRead", "useContractWrite"
- **Use when**: The user needs Wagmi/Viem configuration, hooks, or contract integration patterns.
- **Do NOT use when**: The user needs a full frontend layout — use `tailwind-shadcn-ui-workflow` or `react-ui-patterns-and-hooks`.
- **Workflow**: Map contract and wallet interactions → Choose minimal Wagmi/Viem pattern → Show plan → Verify config.
- **Verification**: Config validation in dev tools, component renders without errors.
- **Cross-ref**: `frontend-dapp-integration` (UI wiring), `nextjs-app-router-and-server-actions` (routing)

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

### tailwind-shadcn-ui-workflow

**Design and implement polished UI flows using Tailwind and shadcn/ui patterns.**

- **Triggers**: "tailwind", "shadcn", "ui workflow", "design system", "component styles", "tailwindcss", "shadcn/ui", "daisyui"
- **Use when**: The user needs Tailwind CSS or shadcn/ui component implementation.
- **Do NOT use when**: The user needs logic or state wiring — use `react-ui-patterns-and-hooks` or `frontend-dapp-integration`.
- **Workflow**: Identify UI surface and design constraints → Choose smallest Tailwind/shadcn pattern → Show plan → Implement.
- **Verification**: Visual check in browser. `npm run build`.
- **Cross-ref**: `react-ui-patterns-and-hooks` (logic), `frontend-dapp-integration` (contract wiring)

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

### accessibility-review

**Review UI behavior for keyboard support, semantics, contrast, and screen-reader friendliness.**

- **Triggers**: "accessibility", "a11y", "keyboard", "screen reader", "contrast", "semantics", "aria", "tab order"
- **Use when**: The user needs an accessibility audit or fix for UI components.
- **Do NOT use when**: The user needs general UI patterns — use `react-ui-patterns-and-hooks` or `tailwind-shadcn-ui-workflow`.
- **Workflow**: Inspect UI for accessibility-sensitive interactions → List issues by severity → Show plan → Patch → Verify.
- **Verification**: Keyboard navigation test. axe-core or lighthouse accessibility check.
- **Cross-ref**: `react-ui-patterns-and-hooks` (component patterns), `tailwind-shadcn-ui-workflow` (styling)

### state-management-integration

**Wire app state into query, store, cache, or client-side state tools without creating drift.**

- **Triggers**: "state management", "zustand", "redux", "query client", "cache", "store", "react query", "jotai", "recoil"
- **Use when**: The user needs to integrate a state management library or pattern.
- **Do NOT use when**: Component-local state is sufficient — use `react-ui-patterns-and-hooks`.
- **Workflow**: Identify state ownership and update flow → Choose minimal tool → Show plan → Wire state → Verify.
- **Verification**: State updates correctly in components. `npm run build`.
- **Cross-ref**: `react-ui-patterns-and-hooks` (local state), `frontend-dapp-integration` (contract state)

## Shipping & Docs

### deployment-and-verification

**Prepare deploy scripts, env variables, explorer verification, and post-deploy checks.**

- **Triggers**: "deploy", "verification", "explorer", "release", "publish contract", "deployment prep"
- **Use when**: The user needs to prepare deployment artifacts, scripts, or checks before the actual broadcast.
- **Do NOT use when**: The user is ready to broadcast — hand off to `pharos-agent-deploy-suite`.
- **Workflow**: Confirm deployment target and config → Draft deploy/verification steps → Show plan → Prepare artifacts after approval.
- **Verification**: Dry run or script syntax check. Not a real broadcast.
- **Cross-ref**: `deployment-for-testnet-and-mainnet` (network planning), `pharos-agent-deploy-suite` (broadcast)

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
- **Do NOT use when**: The user wants live deployment — use `deployment-and-verification` or `pharos-agent-deploy-suite`.
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

### localization-and-copy

**Adjust product copy, labels, and localization structure for clearer user-facing text.**

- **Triggers**: "localization", "i18n", "translation", "copy", "microcopy", "labels", "strings", "text content"
- **Use when**: The user needs to improve or restructure user-facing text, labels, or localization.
- **Do NOT use when**: The user needs UI component changes — use `react-ui-patterns-and-hooks` or `tailwind-shadcn-ui-workflow`.
- **Workflow**: Identify user-facing strings → Draft improved copy → Show plan → Apply after agreement.
- **Verification**: Visual review of the text in context.
- **Cross-ref**: `accessibility-review` (inclusive language), `docs-and-example-generation` (developer docs)

## Subskill Families

The 35 subskills are grouped into three families for organizational clarity:

- **Repo automation and maintenance**: repo-onboarding, repo-automation-and-tooling, dependency-upgrade-management, monorepo-workspace-management, code-review-templates-and-checklists
- **Framework-specific implementation**: framework-integration, nextjs-app-router-and-server-actions, react-ui-patterns-and-hooks, wagmi-viem-dapp-workflow, foundry-hardhat-contract-workflow, remix-contract-workflow, tailwind-shadcn-ui-workflow
- **Review, release, and authoring**: contract-review, bug-finding-and-debugging, deployment-and-verification, migration-and-backward-compatibility, release-notes-and-changelog, code-scaffolding-and-generation, docs-and-example-generation, localization-and-copy

## Classification Rule

The master skill routes to **the narrowest subskill** that can solve the request without inventing extra work. If the user says "review this contract", route to `contract-review`, not `solidity-authoring`. If the user says "set up tests for this", route to `testing-strategy` first (plan), then offer `test-generation` (execution) as a follow-up.

When an intent is ambiguous between subskills, default to the more specific one. If "improve this hook" could match `react-ui-patterns-and-hooks` or `refactoring-and-code-health`, use `react-ui-patterns-and-hooks` if it's a UI hook, or `refactoring-and-code-health` if it's a data logic hook.
