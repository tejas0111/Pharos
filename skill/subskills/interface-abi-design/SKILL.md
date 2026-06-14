---
name: pharos-interface-abi-design
description: "Define Pharos contract interfaces, events, errors, and typed bindings so downstream tooling can integrate cleanly. Use when designing ABI surfaces, event schemas, error definitions, method signatures, or typed bindings for Pharos Solidity contracts. Keywords: ABI, interface, events, errors, typed bindings, contract surface, method signatures, Solidity, Pharos, wagmi, viem, ethers, TypeScript, codegen."
metadata:
  audience: developer
  version: 1.1.0
  category: contract
slash: true
---

# Interface and ABI Design

Define interfaces, events, errors, and typed bindings so downstream tooling can integrate cleanly on Pharos mainnet (chain ID 1672).

## Pharos Interface Patterns

### IPharosStaking (PHRS Native)

```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/// @notice PHRS staking pool interface for Pharos mainnet (1672)
interface IPharosStaking {
    // --- Errors ---
    /// @dev PHRS .call{value:} has no 2300 gas stipend — use pull-over-push
    error PhrsTransferFailed();
    error InsufficientStake(uint256 have, uint256 want);
    error WrongChain(uint256 actual, uint256 expected);

    // --- Events ---
    /// @param user staker address
    /// @param amount PHRS amount (18 decimals)
    event Staked(address indexed user, uint256 amount);
    event Unstaked(address indexed user, uint256 amount);
    event RewardClaimed(address indexed user, uint256 amount);
    event RewardRateUpdated(uint256 oldRate, uint256 newRate);

    // --- State-changing ---
    /// @notice Stake PHRS — msg.value is the stake amount
    function stake() external payable;
    /// @notice Unstake PHRS — uses pull-over-push with gas cap
    function unstake(uint256 amount) external;
    /// @notice Claim accrued PHRS rewards
    function getReward() external;
    /// @notice Owner-only: set reward rate in PHRS per second
    function setRewardRate(uint256 rate) external;

    // --- Views ---
    function stakes(address user) external view returns (uint256);
    function earned(address user) external view returns (uint256);
    function totalStaked() external view returns (uint256);
    function rewardRate() external view returns (uint256);
}
```

### IPharosRewardDistributor (Streaming)

```solidity
interface IPharosRewardDistributor {
    error NotRewardNotifier();
    error RewardTooSmall();

    event RewardAdded(uint256 reward, uint256 periodEnd);
    event RewardPaid(address indexed user, uint256 reward);

    function notifyRewardAmount(uint256 amount) external;
    function earned(address account) external view returns (uint256);
    function lastTimeRewardApplicable() external view returns (uint256);
    function rewardPerToken() external view returns (uint256);
}
```

### NatSpec Conventions for Pharos Contracts

```solidity
/// @notice one-line what this does
/// @param paramName description
/// @return returnName description
/// @dev Pharos-specific: mention PHRS gas stipend, chain ID, Safe integration
/// @custom:pharos-chain 1672 — Pharos Mainnet
```

### ABI Typed Bindings (Wagmi CLI)

```bash
# Generate typed hooks from contract ABI
npx wagmi generate \
  --config wagmi.config.ts \
  --contracts '{"PharosStaking":{"abi":"abi/PharosStaking.json","address":"0x..."}}'
```

This produces `wagmi.generated.ts` with typed `useReadPharosStakingStakes`, `useWritePharosStakingStake`, etc.

### PharosScan ABI Verification Format

```bash
# Flatten and verify — ABI must match deployed bytecode exactly
forge verify-contract \
  --chain-id 1672 \
  --verifier-url https://api.www.pharosscan.xyz/pharos-mainnet/v1/explorer/command_api/contract_verify \
  --etherscan-api-key $PHAROSSCAN_API_KEY \
  0xDeployedAddress src/IPharosStaking.sol:IPharosStaking
```

### ABI Design Rules

- **Document the target network** on every deployed ABI — Mainnet (1672, PROS) or Atlantic Testnet (688689, PHRS). Use `references/pharos-context.md` to confirm the chain ID before defining the ABI surface.
- **Token references**: All `value` fields in events or previews must explicitly reference PROS or PHRS, never ETH or generic "native".
- **Explorer links**: All transaction event data should link to `https://pharosscan.xyz/tx/{txHash}`.
- **Chain-specific artifacts**: If proxy addresses differ between testnet and mainnet, export separate JSON artifacts per chain ID (e.g., `abi/688689/StakingVault.json`, `abi/1672/StakingVault.json`).
- **Event signature verification**: Use `cast sig` to confirm event signature selectors match the deployed contract before relying on them in frontend code.
- **Deployed interface inspection**: Use `cast interface <DEPLOYED_ADDRESS> --rpc-url <rpc>` to dump the full ABI of any deployed Pharos contract.

## When to Use

ABI, interface, events, errors, typed bindings, contract surface, define the interface, what events should I emit, method signatures

## When NOT to Use

writing the full contract implementation (use solidity-authoring), or integrating the ABI into frontend (use frontend-dapp-integration)

## Prerequisites
- **Gate Fix**: Perform the mandatory "Gate Fix" check before proceeding.
- **Security**: private keys must be stored in `.env` and accessed via `${PRIVATE_KEY}`.

- **Foundry**: `forge build` must succeed. Run `forge --version` to verify installation.
- **RPC endpoint**: Set `PHAROS_TESTNET_RPC=https://atlantic.dplabs-internal.com` or `PHAROS_MAINNET_RPC=https://rpc.pharos.xyz` in your environment or `.env`.
- **Private key**: Set `PRIVATE_KEY` environment variable (keep this secret, never commit).
- **PharosScan API key**: Set `PHAROSSCAN_API_KEY` for contract verification (https://pharosscan.xyz).
- **Network reachability**: Run `cast chain-id --rpc-url $RPC_URL` to confirm the target network is reachable.
- **Foundry config**: `foundry.toml` should have `[rpc_endpoints]` section with `pharos_testnet` and `pharos_mainnet` entries.

## Workflow

1. List the methods, events, and revert paths that must be exposed.
2. Check prerequisites: verify Foundry is installed, RPC endpoints are reachable, and required env vars are set. Ask the user for any missing values before proceeding.
3. Normalize naming so frontend and backend tooling can use the same surface.
4. Show the ABI/interface plan and ask if the shape is correct.
5. Generate the interface or binding skeleton after confirmation.

## Output

- interface spec
- event list
- error list
- typed binding notes

## Examples

- "Design the ABI for IPharosStaking with stake, unstake, claimRewards"
- "Create wagmi-typed bindings for the IPharosStaking contract on Pharos"
- "Define events and errors for a Pharos NFT contract (chain ID 1672, PharosScan-verified)"

## Verification

```bash
# Confirm event signature selector matches deployed contract
cast sig "Staked(address,uint256)" --rpc-url pharos_testnet_v2

# Dump deployed contract interface
cast interface 0xDeployedAddress --rpc-url pharos_mainnet
```

Compile check of interface file. Type generation if using TypeChain or abitype.

## Related

solidity-authoring (full implementation), frontend-dapp-integration (consuming the ABI)

## Gate

High risk — two-phase execution required:

**Phase 1 — Plan (present freely):**
- Draft the interface spec, event list, error list, and typed binding notes — show the complete ABI surface
- Do NOT wait for approval to draft — show everything in your response before asking for confirmation

**Phase 2 — Execute (wait for approval):**
- Do NOT Change the ABI surface, modify interface files, or generate bindings
- Wait for explicit user confirmation ("I approve", "proceed", "looks good") before taking any of the Phase 2 actions