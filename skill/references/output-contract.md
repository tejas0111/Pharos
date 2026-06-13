# Output Contract

The skill answers in a shape that is useful to both humans and automated consumers. Every response includes the same 6 fields; the payload shape adapts to the scenario.

## Required Fields

| Field | Always? | Content |
|---|---|---|
| `summary` | always | One sentence describing what was done or proposed |
| `plan` | always | Concrete, sequenced steps (already executed or proposed) |
| `assumptions` | always | Explicit decisions, unknowns, or defaults the user should confirm |
| `files` | always | File paths affected or commands to run |
| `verification` | always | How the result was or will be checked |
| `approvalQuestion` | when gated | "Is this plan correct?" or "Proceed with this change?" |

## Standard Payload Shape

```json
{
  "subskill": "contract-review",
  "risk": "high",
  "approvalRequired": true,
  "summary": "Short sentence describing what was done",
  "plan": ["Step 1: read the file", "Step 2: identify the issue", "Step 3: propose the fix"],
  "assumptions": ["Assumption 1 about the context", "Assumption 2 about user intent"],
  "files": ["src/Contract.sol"],
  "verification": ["forge test --match-path test/Contract.t.sol"],
  "approvalQuestion": "Is this plan correct, or would you like changes?"
}
```

## Scenario-Specific Payloads

### High risk, awaiting approval (pre-execution)

Use when the subskill is high or medium risk and you need the user to confirm before editing.

```json
{
  "subskill": "solidity-authoring",
  "risk": "high",
  "approvalRequired": true,
  "summary": "Proposed implementation plan for Staking.sol with deposit, withdraw, and reward distribution",
  "plan": [
    "Define Staking.sol with stake/unstake/claim functions and custom errors",
    "Add access control via onlyOwner for reward rate updates",
    "Implement pull-over-push for withdrawals (checks-effects-interactions)",
    "Write forge tests for deposit, withdraw, and edge cases"
  ],
  "assumptions": [
    "Token contract address will be passed as constructor arg",
    "Reward rate is set by owner and can be updated",
    "No upgradeability mechanism is needed for v1"
  ],
  "files": ["src/Staking.sol", "test/Staking.t.sol"],
  "verification": ["forge build", "forge test --match-path test/Staking.t.sol"],
  "approvalQuestion": "Does this plan look right? I'll implement Staking.sol and its tests after your confirmation."
}
```

### Medium risk, awaiting approval

```json
{
  "subskill": "refactoring-and-code-health",
  "risk": "medium",
  "approvalRequired": true,
  "summary": "Proposed refactor of TokenDashboard to separate data fetching from rendering",
  "plan": [
    "Extract data fetching into a useTokenData hook",
    "Create a TokenBalance display component",
    "Update TokenDashboard to compose the hook and component"
  ],
  "assumptions": [
    "The RPC endpoint and contract ABI remain unchanged",
    "No behavior change in the rendered output"
  ],
  "files": [
    "components/TokenDashboard.tsx",
    "hooks/useTokenData.ts",
    "components/TokenBalance.tsx"
  ],
  "verification": ["npm test", "npm run build"],
  "approvalQuestion": "Proceed with this refactor as described?"
}
```

### Low risk, informing the user (post-execution)

Use when the subskill is low risk and you have already made the change (or the change is trivially safe).

```json
{
  "subskill": "release-notes-and-changelog",
  "risk": "low",
  "approvalRequired": false,
  "summary": "Drafted changelog entry for v1.2.0 in CHANGELOG.md",
  "plan": [
    "Scanned commits since v1.1.0 tag",
    "Categorized changes into Features, Fixes, and Chores",
    "Appended entry to CHANGELOG.md in keepachangelog format"
  ],
  "assumptions": [
    "All unreleased commits since last tag should be included",
    "Using keepachangelog format as existing convention"
  ],
  "files": ["CHANGELOG.md"],
  "verification": ["Review the formatted entry visually"],
  "approvalQuestion": "Does this changelog entry look right?"
}
```

### Read-only exploration (no changes)

Use when the subskill does not modify any files (e.g., repo-onboarding, contract-review with findings only).

```json
{
  "subskill": "repo-onboarding",
  "risk": "low",
  "approvalRequired": false,
  "summary": "Mapped the repo structure: Next.js app with Foundry contracts and wagmi integration",
  "plan": [
    "Read package.json, foundry.toml, and next.config.js",
    "Identified entrypoints: pages/, contracts/, and scripts/",
    "Read the deploy scripts and test configuration"
  ],
  "assumptions": [
    "User wants to start implementing a frontend dapp integration"
  ],
  "files": [
    "package.json → main dependencies: next, wagmi, viem, foundry",
    "foundry.toml → solc 0.8.23, contracts/ source dir",
    "pages/index.tsx → main app entrypoint",
    "contracts/ → contains Token.sol and Vault.sol",
    "scripts/deploy-testnet.sh → Foundry deploy script"
  ],
  "verification": ["N/A — read-only exploration"],
  "approvalQuestion": "What would you like to work on first? I can help with frontend integration, contract work, or testing."
}
```

### Multi-subskill recommendation (chaining)

Use when a single request benefits from multiple subskills.

```json
{
  "subskill": "contract-architecture",
  "risk": "high",
  "approvalRequired": true,
  "summary": "Architecture plan for a staking protocol with upgrade boundaries and access control",
  "plan": [
    "Module 1: StakingCore — stake/unstake logic, balance tracking",
    "Module 2: RewardDistributor — reward rate, claim logic",
    "Module 3: ProxyAdmin — upgradeable proxy pattern for future upgrades",
    "Follow-up: solidity-authoring for implementation, then interface-abi-design for the event/error surface"
  ],
  "assumptions": [
    "Using UUPS upgrade pattern",
    "Owner role will be a multi-sig",
    "Reward token is separate from staking token"
  ],
  "files": ["contracts/StakingCore.sol", "contracts/RewardDistributor.sol", "contracts/ProxyAdmin.sol"],
  "verification": ["Architecture review complete. Solidty authoring can begin after approval."],
  "approvalQuestion": "Does this architecture look correct? If so, I'll proceed with implementing StakingCore.sol."
}
```

### Error / blockage report

Use when something went wrong during execution.

```json
{
  "subskill": "ci-and-build-troubleshooting",
  "risk": "high",
  "approvalRequired": true,
  "summary": "Diagnosed the TypeScript build failure: type mismatch in wagmi config",
  "plan": [
    "Read the CI error output: Type 'string' is not assignable to type 'Address'",
    "Isolated the issue to config/wagmi.ts line 14: chainId variable is string instead of number",
    "Fix: add Number() wrapper or type assertion"
  ],
  "assumptions": [
    "The chainId comes from an env var which is always a numeric string"
  ],
  "files": ["config/wagmi.ts"],
  "verification": ["npm run build:types", "npm run build"],
  "approvalQuestion": "The fix is a one-line change: wrap chainId with Number(). Proceed?"
}
```

## Response Rules

1. **Summary is one sentence**. If it takes multiple sentences, it's not a summary.
2. **Plan is sequence-based**. Numbered steps or bullet points. Never a paragraph.
3. **Assumptions are explicit**. If you assumed something about the repo, toolchain, user intent, or config, state it.
4. **Files are concrete paths**. Absolute or relative from project root. Never vague like "the contract file".
5. **Verification is actionable**. A command the user can run or a manual check they can perform.
6. **Approval question is a direct yes/no**. Not a suggestion. Not a rhetorical question.
7. **`approvalQuestion` is always required.** Include it in every response. When not gated (low risk), set `approvalQuestion` to a question about whether the plan is acceptable rather than omitting it.
8. **Never include RPC URLs, private keys, or API keys** in any output field.

## Edge Cases

| Scenario | Output approach |
|---|---|
| User says "looks good" to the plan | Execute and return a post-execution payload |
| User says "no, do it differently" | Discard old plan, re-classify, present new plan |
| User says "fix it" without specifying | Use the assumption field to state what you inferred, then ask for confirmation |
| Multiple files changed | List all files in the `files` array |
| Verification takes long | Suggest the verification command; don't execute it if it's expensive |
| No files changed (read-only) | Set `files` to paths you read, not paths you changed |
