---
name: pharos-repo-automation-and-tooling
description: "Design scripts, automation flows, task runners, and local developer tooling for Pharos projects. Use when setting up automation, scripts, Makefiles, precommit hooks, Husky, linting config, or dev tooling for Pharos Solidity and TypeScript repos. Keywords: automation, scripts, task runner, Makefile, precommit, tooling, linting, Husky, CI script, dev tooling, Pharos, Solidity, TypeScript, Foundry, Hardhat, monorepo."
metadata:
  audience: developer
  version: 1.2.0
  category: tooling
slash: true
---

# Repo Automation and Tooling

Design scripts, automation flows, task runners, and local developer tooling for Pharos Foundry + TypeScript monorepos.

## Pharos Makefile

```makefile
# Pharos Dev Tooling
NETWORK ?= pharos_testnet
PHRS = 1672
TESTNET = 688689

.PHONY: build test lint gas snapshot deploy verify

build:
	forge build

test:
	forge test --fork-url $(NETWORK)

test-all:
	forge test --fork-url $(NETWORK) --gas-report

lint:
	pnpm solhint contracts/src/**/*.sol
	pnpm eslint frontend/**/*.{ts,tsx}

gas:
	forge snapshot --fork-url $(NETWORK)

snapshot:
	forge snapshot --fork-url $(NETWORK) --diff

deploy-testnet:
	forge script script/Deploy.s.sol --rpc-url pharos_testnet --broadcast

deploy-mainnet:
	forge script script/Deploy.s.sol --rpc-url pharos_mainnet --broadcast --verify

verify:
	forge verify-contract --chain-id $(PHRS) --verifier-url $PHAROSSCAN_MAINNET_API_URL \
		--etherscan-api-key $$PHAROSSCAN_API_KEY $(ADDR) $(CONTRACT)

pub-abis:
	pnpm wagmi generate
	pnpm --filter @pharos-dapp/shared build
	pnpm publish shared --access public
```

## Pre-commit (Husky + lint-staged)

```json
// .husky/pre-commit
{
  "lint-staged": {
    "contracts/src/**/*.sol": "solhint",
    "frontend/**/*.{ts,tsx}": "eslint --fix",
    "*.{json,md,yaml}": "prettier --write"
  }
}
```

## Package Scripts (package.json)

```json
{
  "scripts": {
    "dev": "pnpm --filter frontend dev",
    "build": "pnpm --filter contracts exec 'forge build' && pnpm --filter @pharos-dapp/shared build && pnpm --filter frontend build",
    "test": "pnpm --filter contracts exec 'forge test --fork-url pharos_testnet'",
    "lint": "pnpm solhint contracts/src/**/*.sol && pnpm eslint frontend/",
    "gas": "pnpm --filter contracts exec 'forge snapshot --fork-url pharos_testnet'",
    "deploy:testnet": "pnpm --filter contracts exec 'forge script script/Deploy.s.sol --rpc-url pharos_testnet --broadcast'",
    "deploy:mainnet": "pnpm --filter contracts exec 'forge script script/Deploy.s.sol --rpc-url pharos_mainnet --broadcast --verify'",
    "generate": "pnpm wagmi generate"
  }
}
```

## Pharos CI Scripts

### .github/scripts/verify-pharos.sh

```bash
#!/usr/bin/env bash
set -euo pipefail

forge build --sizes
forge test --fork-url $PHAROS_TESTNET_RPC_URL --gas-report
forge verify-contract --chain-id 688689 \
  --verifier-url $PHAROSSCAN_MAINNET_API_URL \
  --etherscan-api-key "$PHAROSSCAN_API_KEY" \
  "$CONTRACT_ADDRESS" src/"$CONTRACT".sol:"$CONTRACT"
```

## Examples

- "Set up lint, test, and build commands for a Pharos Foundry + Next.js monorepo"
- "Create a Makefile with forge build, forge test --fork-url pharos_testnet, and forge snapshot"
- "Set up Husky with solhint + eslint pre-commit hooks for Pharos .sol and .ts files"
- "Create a publish-abis script that runs wagmi generate and publishes @pharos-dapp/shared"
- "Set up verify-pharos GitHub script with forge verify-contract against PharosScan API"

## Verification

Run `make build && make test` across both testnet and mainnet chain configs.

## When NOT to Use

- **CI pipeline setup** — For GitHub Actions / CI config (YAML workflows, matrix builds), use `ci-and-build-troubleshooting`.
- **Deployment scripts** — For `forge script` deploy flows with Safe multisig, use `deployment-and-verification`.
- **Monorepo structure** — For bootstrapping pnpm workspaces / Turborepo, use `monorepo-workspace-management`.

## Prerequisites
- **Gate Fix**: Perform the mandatory "Gate Fix" check before proceeding.
- **Security**:
    - **.env Usage**: Environment variables MUST be stored in a `.env` file in the project root. NEVER use `export VAR=...` for sensitive data.
    - **Mandatory Check**: The Agent MUST check for the existence of `.env` and valid values (especially `PRIVATE_KEY` and `PHAROSSCAN_API_KEY`) before attempting any deployment or on-chain action.
    - **Git**: Ensure `.env` is listed in `.gitignore` to prevent accidental commits.

- **Git repository**: `git status` must succeed (run from repo root).
- **CI platform**: GitHub Actions configured (check `.github/workflows/` exists).
- **Foundry** (if workflows include forge commands): `forge build` must succeed.
## Workflow
- **Strict .env Check**: Verify `.env` exists in project root and contains `PRIVATE_KEY`, `PHAROSSCAN_API_KEY`, and required RPC URLs. Do NOT proceed if missing or if the user suggests using `export`.

1. **Requirement Gathering**: Analyze the user's request to identify the specific task, target environment (Atlantic 688689 or Pacific 1672), and any missing context. Zero-assumption delivery.
2. **Mandatory Plan (`PLAN.md`)**: Create or update `PLAN.md` in the project root with the proposed strategy. **Wait for explicit 'Approve' or 'Proceed' from the user before taking any action.**
3. Understand the automation need and target tools.
4. Check prerequisites: verify required tools are installed, env vars are set, and any required context is available. Ask the user for any missing values before proceeding.
5. Design the script, config, or automation flow.
6. Show the plan and ask for approval before implementing.
7. Apply the changes and verify.
## Output

- Makefile with forge + lint + gas + deploy + verify targets
- package.json scripts for pnpm monorepo build chain
- Husky / lint-staged pre-commit config
- Shell scripts for PharosScan verification
- ABI publish pipeline (wagmi generate → npm publish)

## Related

code-review-templates-and-checklists (process automation), ci-and-build-troubleshooting (CI pipelines), monorepo-workspace-management (workspace bootstrapping), deployment-and-verification (deploy scripts)

## Gate


Low risk. Show the automation plan first; add scripts after the user agrees on surface and scope.
