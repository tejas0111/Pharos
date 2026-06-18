---
name: pharos-dependency-upgrade-management
description: "Upgrade Pharos project packages or toolchains with version-aware compatibility checks and rollback planning. Use when upgrading dependencies, bumping package versions, updating toolchains (Foundry, Hardhat, Node), or managing npm/forge dependency updates for Pharos dapps. Keywords: dependency upgrade, package update, toolchain update, version bump, upgrade dependencies, npm update, Foundry, Hardhat, Pharos, Solidity, monorepo, compatiblity, rollback."
metadata:
  audience: developer
  version: 1.2.0
  category: tooling
slash: true
---

# Dependency Upgrade Management

Upgrade packages or toolchains with version-aware compatibility checks and rollback planning for Pharos projects.

## Common Pharos Upgrade Paths

### OpenZeppelin 4.9 → 5.0 (Breaking Changes)

| Change | OZ 4.9 | OZ 5.0 | Fix |
|--------|--------|--------|-----|
| Ownable | `import "@openzeppelin/contracts/access/Ownable.sol"` | Use `OwnableUpgradeable` for UUPS, or `Ownable2Step` | `npm install @openzeppelin/contracts-upgradeable@5.0` |
| ERC-20 `_transfer` | `_transfer(from, to, amount)` | Renamed to `_update(from, to, amount, mint/burn)` | Replace `_transfer`/`_mint`/`_burn` calls with `_update` |
| UUPS `_authorizeUpgrade` | Returns void | Added `newImplementation` param | `function _authorizeUpgrade(address) internal override onlyOwner {}` |
| ReentrancyGuard | ReentrancyGuard | Moved to utils | Update import path |
| SafeERC20 | `safeTransfer` returns bool | No change | Update import path |

```bash
# Upgrade
npm install @openzeppelin/contracts@5.0 @openzeppelin/contracts-upgradeable@5.0
# Test on Pharos testnet
forge test --fork-url $PHAROS_TESTNET_RPC_URL --chain-id 688689
```

### Forge-Std 1.8 → 1.9

```bash
forge update foundry-rs/forge-std
```

Check for changed cheatcodes: `vm.assume` → `vm.assume*` variants, `vm.skip` added.

### Solidity Pragma Bump (0.8.20 → 0.8.25+)

```bash
# Update all pragmas
find . -name "*.sol" -exec sed -i 's/pragma solidity \^0\.8\.20/pragma solidity ^0.8.25/g' {} +
# Check for new opcodes (MCOPY in 0.8.24+)
forge build
```

### Upgrade Verification on Pharos

```bash
# 1. Fork test
anvil --fork-url $PHAROS_TESTNET_RPC_URL --chain-id 688689 &
forge test --fork-url http://localhost:8545 --chain-id 688689 -vvv

# 2. PharosScan verification
forge verify-contract \
  --chain-id 1672 \
  --verifier-url https://www.pharosscan.xyz/api \
  --etherscan-api-key $PHAROSSCAN_API_KEY \
  0xNewContract src/Contract.sol:Contract
```

## When to Use

dependency upgrade, package update, toolchain update, version bump, upgrade dependencies, update packages, npm update, upgrade contract

## When NOT to Use

adding a new dependency (use framework-integration), or refactoring code to work with a new version (use refactoring-and-code-health)

## Prerequisites
- **Security**:
    - **.env Usage**: Environment variables MUST be stored in a `.env` file in the project root. NEVER use `export VAR=...` for sensitive data.
    - **Mandatory Check**: The Agent MUST verify `.env` exists and variables are set using `grep -q` (NEVER `cat`, `head`, `tail` — those expose secrets) before any deployment or on-chain action.
    - **Git**: Ensure `.env` is listed in `.gitignore` to prevent accidental commits.

- **Foundry**: `forge build` must succeed. Run `forge --version` to verify installation.
- **RPC endpoint**: Set `PHAROS_TESTNET_RPC=$PHAROS_TESTNET_RPC_URL` or `PHAROS_MAINNET_RPC=$PHAROS_MAINNET_RPC_URL` in your environment or `.env`.
- **PharosScan API key**: Set `PHAROSSCAN_API_KEY` for contract verification.
- **Network reachability**: Run `cast chain-id --rpc-url $RPC_URL` to confirm the target network is reachable.
- **Package manager**: pnpm, npm, or yarn available.
## Workflow
- **Strict .env Check**: Confirm `.env` exists with `test -f .env` and check variables via `grep -q` (without printing values). NEVER print `.env` contents. Do NOT proceed if missing or if the user suggests `export`.

1. **Requirement Gathering**: Analyze the user's request to identify the specific task, target environment (Atlantic 688689 or Pacific 1672), and any missing context. Zero-assumption delivery.
2. **Mandatory Plan (`PLAN.md`)**: Create or update `PLAN.md` in the project root with the proposed strategy. **Wait for explicit 'Approve' or 'Proceed' from the user before taking any action.**
3. List the packages or toolchain components that need changing.
4. Check prerequisites: verify required tools are installed, env vars are set, and any required context is available. Ask the user for any missing values before proceeding.
5. Check compatibility risk and any required code changes.
6. Present the upgrade plan and ask for confirmation.
7. Apply the upgrade and verify the build or tests.
## Output

- upgrade plan
- compatibility notes
- version list
- verification result

## Examples

- "Upgrade OpenZeppelin from 4.9 to 5.0 in our Pharos staking dapp — handle Ownable2Step and ERC-20 _update"
- "Plan the forge-std bump from 1.8 to 1.9 across all Pharos contracts"
- "Safely upgrade Solidity pragma from 0.8.20 to 0.8.25 across all Pharos contracts and verify with forge build"
- "Upgrade wagmi from 1.x to 2.x for the Pharos frontend and update createConfig"
- "Update viem from 1.x to 2.x and fix chain definition for Pharos mainnet 1672"

## Verification

npm install/yarn, then npm run build/npm test. For Solidity: forge build && forge test --fork-url $PHAROS_TESTNET_RPC_URL.

## Related

monorepo-workspace-management (workspace-wide upgrades), framework-integration (adding new dependencies)

## Gate

High risk — two-phase execution required:

**Phase 1 — Plan (present freely):**
- Draft the `PLAN.md` with the full implementation strategy, environment-aware safeguards, and verification steps.
- Do NOT wait for approval to draft — show everything in your response before asking for confirmation
- Wait for explicit 'Approve' or 'Proceed' from the user.

**Phase 2 — Execute (wait for approval):**
- Execute the approved plan from `PLAN.md`.
- Do NOT send any onchain transactions or modify critical files until approved.
- Perform a final "Ready to Broadcast?" check for any high-risk on-chain actions.
- Wait for explicit user confirmation ("I approve", "proceed", "looks good") before taking any of the Phase 2 actions.

