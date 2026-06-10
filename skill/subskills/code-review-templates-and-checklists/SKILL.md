---
name: pharos-code-review-templates-and-checklists
description: "Create review templates, PR checklists, and evaluation rubrics for better code review hygiene in Pharos projects. Use when building code review templates, PR checklists, review rubrics, review guidelines, or PR templates for Pharos Solidity or TypeScript repos. Keywords: code review template, PR checklist, review rubric, review notes, PR template, review guidelines, Pharos, Solidity, TypeScript, GitHub, monorepo."
metadata:
  audience: developer
  version: 1.2.0
  category: workflow
slash: true
---

# Code Review Templates and Checklists

Create review templates, PR checklists, and evaluation rubrics for Pharos Solidity contracts, deploy scripts, and dApp frontends.

## Pharos PR Template (GitHub)

```markdown
## Description
_What does this PR change for the Pharos dApp/contract?_

## Networks
- [ ] Atlantic Testnet (688689) — forge test passed
- [ ] Mainnet (1672) — forge build --sizes

## Checklist

### Solidity
- [ ] No `transfer` / `send` (PHRS has no 2300 gas stipend)
- [ ] Chain ID validated in deploy script (`block.chainid == 1672`)
- [ ] Storage gap (`__gap`) present for upgradeable contracts
- [ ] NatSpec on all public/external functions
- [ ] forge build --sizes (bytecode under limit)
- [ ] forge test --fork-url pharos_testnet (all green)

### TypeScript / Frontend
- [ ] Chain config uses correct chain ID (1672 / 688689)
- [ ] RPC URLs point to canonical endpoints (rpc.pharos.xyz / atlantic.dplabs-internal.com)
- [ ] TX lifecycle states handled (pending → success → reverted)
- [ ] PharosScan explorer links use correct network

### Deployment
- [ ] foundry.toml has [rpc_endpoints] for both networks
- [ ] forge verify-contract command includes --verifier-url https://www.pharosscan.xyz/api
- [ ] Safe multisig owner set correctly for proxy admin
- [ ] Deploy script validates chain ID before broadcast

## Verification Steps
```bash
forge test --fork-url pharos_testnet --match-path test/PharosStaking.t.sol
pnpm --filter frontend build
```

## Related Issues
_Closes #..._
```

## Review Rubric (Solidity)

| Category | 1 (Needs Work) | 3 (Acceptable) | 5 (Exemplary) |
|----------|----------------|----------------|----------------|
| **PHRS Safety** | Uses `transfer()` / `send()` | Uses pull pattern with gas cap | + checks reentrancy |
| **Chain ID** | Hardcoded constant | Modifier checks `block.chainid` | + deploy script also validates |
| **Upgradeability** | No storage gap | `__gap` present | + ERC-7201 namespaced storage |
| **Tests** | Happy path only | Fork tests + edge cases | + Fuzz + invariant |
| **Deploy** | Manual broadcast | forge script with --verify | + CI matrix for testnet+mainnet |

## Prerequisites
- **Gate Fix**: Perform the mandatory "Gate Fix" check before proceeding.
- **Security**: Private keys must be stored in `.env` and accessed via `${PRIVATE_KEY}`.

- **Project context**: You need the contract names, network targets (1672 mainnet / 688689 testnet), and version numbers relevant to the documentation.
- **Previous artifacts**: If documenting deployed contracts, you need deployment addresses, ABI files, or changelog history.
- **Target audience**: Clarify whether this is for developers, end users, or both.
## Workflow

1. **Requirement Gathering**: Analyze the user's request to identify the specific task, target environment (Atlantic 688689 or Pacific 1672), and any missing context. Zero-assumption delivery.
2. **Mandatory Plan (`PLAN.md`)**: Create or update `PLAN.md` in the project root with the proposed strategy. **Wait for explicit 'Approve' or 'Proceed' from the user before taking any action.**
3. Understand the review process and team conventions.
4. Check prerequisites: verify required tools are installed, env vars are set, and any required context is available. Ask the user for any missing values before proceeding.
5. Design the template or checklist.
6. Show the plan and ask for approval before finalizing.
7. Review and verify the template.
## Examples

- "Create a PR checklist template for Pharos Solidity contracts (PHRS safety, chain ID validation, storage gap)"
- "Design a review rubric for Pharos deployment PRs covering testnet 688689 and mainnet 1672"
- "Write a PR template for Pharos dApp frontend changes with PharosScan links and testnet validation steps"

## Verification

Visual review of the template against actual Pharos PR conventions.
## Gate


Low risk. Show the template outline first; commit to `.github/` or `docs/` after user confirms structure and length.
