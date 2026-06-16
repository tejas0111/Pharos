---
name: pharos-repo-onboarding
description: "Map Pharos codebase entrypoints, scripts, and conventions so future work starts from the right place. Use when onboarding, mapping repo structure, finding entrypoints, understanding project layout, or getting a codebase tour before Pharos development. Keywords: onboard, map repo, entrypoints, project layout, codebase tour, repo structure, Pharos, Solidity, Foundry, monorepo, smart contract, dapp."
metadata:
  audience: developer
  version: 1.2.0
  category: workflow
slash: true
---

# Repo Onboarding

Map the codebase, entrypoints, scripts, and conventions so future work starts from the right place.

## Typical Pharos Monorepo Layout

```
pharos-dapp/
├── contracts/                  # Foundry project
│   ├── foundry.toml            # solc, optimizer, [rpc_endpoints]
│   ├── src/                    # Solidity contracts
│   │   └── PharosStaking.sol
│   ├── script/                 # Deploy scripts
│   │   └── Deploy.s.sol
│   ├── test/                   # Forge tests
│   │   └── PharosStaking.t.sol
│   └── out/                    # Build artifacts (gitignored)
├── frontend/                   # Next.js App Router
│   ├── app/
│   ├── components/
│   ├── package.json            # wagmi + viem + RainbowKit
│   └── next.config.js          # transpilePackages of shared
├── shared/
│   └── shared/                 # Shared types, ABIs, chain config
│       └── src/
│           └── pharosChain.ts  # defineChain for 1672 / 688689
├── pnpm-workspace.yaml
├── turbo.json
└── .env                        # PRIVATE_KEY, PHAROSSCAN_API_KEY, RPC URLs
```

## Key Commands

```bash
# Build
forge build --sizes
pnpm build                      # monorepo build

# Test (fork from testnet 688689)
forge test --fork-url pharos_testnet
forge test --fork-url pharos_testnet --match-path test/PharosStaking.t.sol

# Gas
forge snapshot --fork-url pharos_testnet

# Deploy
forge script script/Deploy.s.sol --rpc-url pharos_testnet --broadcast
forge script script/Deploy.s.sol --rpc-url pharos_mainnet --broadcast --verify

# Verify
forge verify-contract --chain-id 688689 --verifier-url $PHAROSSCAN_TESTNET_API_URL \
  --etherscan-api-key $PHAROSSCAN_API_KEY <addr> src/Contract.sol:Contract

# Frontend
pnpm --filter frontend dev
pnpm --filter frontend build
```

## Network Quick Reference

| Network | Chain ID | RPC | Explorer |
|---------|----------|-----|----------|
| Mainnet | 1672 | `$PHAROS_MAINNET_RPC_URL` | https://www.pharosscan.xyz |
| Atlantic Testnet | 688689 | `$PHAROS_TESTNET_RPC_URL` | https://atlantic.pharosscan.xyz |

## Env Template

```bash
PRIVATE_KEY=0x...
PHAROSSCAN_API_KEY=...
PHAROS_MAINNET_RPC=$PHAROS_MAINNET_RPC_URL
PHAROS_TESTNET_RPC=$PHAROS_TESTNET_RPC_URL
```

## Related

| Subskill | Why |
|---|---|
| `framework-integration` | Stack detection |
| `solidity-authoring` | Contract exploration |

## When NOT to Use

- **Making changes** — For modifying code or config, use the relevant feature subskill after onboarding is complete.
- **Scaffolding** — For generating boilerplate files, use `code-scaffolding-and-generation`.

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
3. Detect the user target network — Use `references/pharos-context.md` Network Detection table to determine if the user means testnet (688689, PHRS), mainnet (1672, PROS), or is ambiguous. If the user didn't specify, ask: 'Atlantic Testnet or Mainnet?' Adapt all following steps (RPC URLs, token symbols, deploy commands, chain IDs) to match.
4. Map the codebase entrypoints, scripts, and conventions.
5. Check prerequisites: verify required tools are installed, env vars are set, and any required context is available. Ask the user for any missing values before proceeding.
6. Present the repo map to the user and confirm understanding.
7. Show the plan and ask for approval before proceeding.
## Examples

- "Map this Pharos monorepo so I can start dapp integration work — show contracts/, frontend/, shared/ layout"
- "Show the important files and commands for this Pharos Foundry + Next.js project"
- "What's the structure of this Pharos project? Show foundry.toml, chain configs, and deploy scripts"

## Verification

N/A — read-only exploration. Optionally ask the user if the map matches expectations.
## Gate


Low risk. Present the repo map and open questions first; proceed to implementation only after the user confirms the map is accurate.
