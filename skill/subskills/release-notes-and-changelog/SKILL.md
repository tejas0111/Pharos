---
name: pharos-release-notes-and-changelog
description: "Turn Pharos code changes into clear release notes, changelog entries, or PR summaries. Use when generating release notes, changelog entries, release summaries, PR summaries, shipping notes, or version notes for Pharos dapp releases. Keywords: release notes, changelog, release summary, PR summary, shipping notes, what changed, changelog entry, version notes, Pharos, Solidity, TypeScript, Foundry, Hardhat, dapp."
metadata:
  audience: developer
  version: 1.2.0
  category: workflow
slash: true
---

# Release Notes and Changelog

Turn a set of code changes into clear release notes, changelog entries, or PR summaries for Pharos contracts and dapps on mainnet (1672) / Atlantic Testnet (688689).

## CHANGELOG.md Convention (keep-a-changelog)

```markdown
# Changelog

## [2.1.0] - 2026-06-09

### Added
- Native PHRS staking — no ERC-20 `approve` needed (PHRS is native currency on Pharos)
- Reward compounding — auto-compound `claimRewards()` into staked balance
- PharosScan verification gate — mainnet deploys require `--verifier-url $PHAROSSCAN_MAINNET_API_URL`

### Changed
- Solidity `0.8.20` → `0.8.24`
- OpenZeppelin `4.9` → `5.0` (storage layout migration required — see migration guide)
- foundry.toml — added `solc = "0.8.24"`, `ffi = true`

### Removed
- ERC-20 `IPharosStaking.approve()` — PHRS is native on Pharos, no longer wrapped

## [2.0.0] - 2026-05-01

### Added
- Initial staking contract (IPharosStaking)
- Reward distribution with 12% APR
- Deployment scripts for testnet (688689) and mainnet (1672)
- forge verify-contract with PharosScan
```

## Release Notes Template

```markdown
# Pharos Staking v2.1.0

## Overview
Native PHRS staking with auto-compound rewards.

## Upgrade Instructions (Mainnet 1672)

### Prerequisites
- **Gate Fix**: Perform the mandatory "Gate Fix" check before proceeding.
- **Security**:
    - **.env Usage**: Environment variables MUST be stored in a `.env` file in the project root. NEVER use `export VAR=...` for sensitive data.
    - **Mandatory Check**: The Agent MUST verify `.env` exists and variables are set using `grep -q` (NEVER `cat`, `head`, `tail` — those expose secrets) before any deployment or on-chain action.
    - **Git**: Ensure `.env` is listed in `.gitignore` to prevent accidental commits.

- `PHAROSSCAN_API_KEY` set in `.env`
- Safe multisig owner access
- Upgrade executor role on the proxy admin
### Steps

1. Build and verify on Atlantic Testnet (688689) first:
   ```bash
   forge build --sizes
   forge test --fork-url pharos_testnet
   forge script UpgradeStaking --rpc-url pharos_testnet --broadcast
   forge verify-contract --chain-id 688689 --verifier-url $PHAROSSCAN_TESTNET_API_URL
   ```

2. Upgrade on mainnet (1672):
   ```bash
   forge script UpgradeStaking --rpc-url pharos_mainnet --broadcast
   forge verify-contract --chain-id 1672 --verifier-url $PHAROSSCAN_MAINNET_API_URL
   ```

3. Sanity check:
   ```bash
   cast call <staking> "getStakedBalance(address)" <your-address> --rpc-url $PHAROS_MAINNET_RPC_URL
   ```

### Migration: OZ 4.9 → 5.0

- `Initializable` → uses `onlyInitializing` modifier
- `UUPSUpgradeable` → `__UUPSUpgradeable_init()` now required
- Storage: ERC-7201 namespaced storage (run `forge inspect PharosStaking storage` to verify)
- See `skill/subskills/upgrade-patterns/SKILL.md` for rollback plan

## Risk Notes

- **High**: Storage layout change — migration test must pass on testnet first
- **Medium**: PharosScan API key rotation — ensure verified before deploy gate
- **Low**: PHRS gas stipend — no 2300 stipend on Pharos; use capped pull pattern
```

## Version Bump Locations

| File | Field | Example |
|------|-------|---------|
| `contracts/foundry.toml` | `solc` | `solc = "0.8.24"` |
| `contracts/package.json` | `version` | `"version": "2.1.0"` |
| `frontend/package.json` | `version` | `"version": "2.1.0"` |
| `shared/package.json` | `version` | `"version": "2.1.0"` |

## Related

| Subskill | Why |
|---|---|
| `docs-and-example-generation` | Related documentation |
| `ci-and-build-troubleshooting` | Release pipeline |

## When NOT to Use

- **Technical documentation** — For developer docs/READMEs, use `docs-and-example-generation`.
- **Frontend copy** — For UI text/localization, use `localization-and-copy`.
- **Deployment announcements** — For deploy flow, use `deployment-and-verification`.

## Prerequisites
- **Gate Fix**: Perform the mandatory "Gate Fix" check before proceeding.
- **Security**:
    - **.env Usage**: Environment variables MUST be stored in a `.env` file in the project root. NEVER use `export VAR=...` for sensitive data.
    - **Mandatory Check**: The Agent MUST verify `.env` exists and variables are set using `grep -q` (NEVER `cat`, `head`, `tail` — those expose secrets) before any deployment or on-chain action.
    - **Git**: Ensure `.env` is listed in `.gitignore` to prevent accidental commits.

- **Project context**: You need the contract names, network targets (1672 mainnet / 688689 testnet), and version numbers relevant to the documentation.
- **Previous artifacts**: If documenting deployed contracts, you need deployment addresses, ABI files, or changelog history.
- **Target audience**: Clarify whether this is for developers, end users, or both.

## Workflow
- **Strict .env Check**: Confirm `.env` exists with `test -f .env` and check variables via `grep -q` (without printing values). NEVER print `.env` contents. Do NOT proceed if missing or if the user suggests `export`.

1. **Requirement Gathering**: Analyze the user's request to identify the specific task, target environment (Atlantic 688689 or Pacific 1672), and any missing context. Zero-assumption delivery.
2. **Mandatory Plan (`PLAN.md`)**: Create or update `PLAN.md` in the project root with the proposed strategy. **Wait for explicit 'Approve' or 'Proceed' from the user before taking any action.**
3. Review the set of changes to be documented.
4. Check prerequisites: verify required tools are installed, env vars are set, and any required context is available. Ask the user for any missing values before proceeding.
5. Write the release notes or changelog entry.
6. Show the plan and ask for approval before finalizing.
7. Verify version numbers and links.
## Examples

- "Generate changelog entry for Pharos Staking v2.1.0: native PHRS staking, OZ 5.0 upgrade, Solidity 0.8.24, PharosScan gate"
- "Draft release notes for Pharos SPN deployment v1.0.0 on testnet 688689"
- "Write PR summary for adding reward compounding to IPharosStaking"
- "Create migration guide for OZ 4.9→5.0 with storage layout verification on Pharos 1672"

## Verification

Visual review; verify version numbers match actual `foundry.toml` and `package.json` files.
## Gate


Low risk. Present changelog outline and commit sample first; edit `CHANGELOG.md` or publish release text only after user confirms version, scope, and deploy appendix accuracy.
