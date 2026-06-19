---
name: pharos-refactoring-and-code-health
description: "Improve Pharos code structure, readability, naming, and separation of concerns without changing behavior. Use when refactoring, cleaning up, simplifying, removing duplication, paying down technical debt, or restructuring Pharos Solidity contracts and TypeScript dapps. Keywords: refactor, code health, cleanup, simplify, remove duplication, technical debt, restructure, readability, Pharos, Solidity, TypeScript, Next.js, React, Foundry, Hardhat."
metadata:
  audience: developer
  version: 1.2.0
  category: contract
slash: true
---

# Refactoring and Code Health

Improve structure, readability, naming, and separation of concerns without changing behavior. Includes Pharos-specific patterns for Solidity storage gaps, PHRS transfer safety, and wagmi hook parameterization.

## Pharos-Specific Refactoring Patterns

### Solidity — Add Storage Gap for Upgradeability

```solidity
// Before — no gap, next dev may corrupt storage on upgrade
contract MyContract is Initializable, UUPSUpgradeable {
    uint256 public value;
}

// After — 50-slot gap protects future upgrades
contract MyContract is Initializable, UUPSUpgradeable {
    uint256 public value;
    /// @custom:storage-gap Storage gap for upgrade safety
    // Gap MUST be last — after all state vars, before constructor
    uint256[50] private __gap;
}
```

### Solidity — Replace Full-Gas PHRS Transfer with Capped

```solidity
// Before — forwards all gas (reentrancy risk on Pharos, no 2300 stipend)
(bool sent,) = payable(to).call{value: amount}("");

// After — cap gas to limit reentrancy
(bool sent,) = payable(to).call{value: amount, gas: 10000}("");

// Better — pull-over-push
function withdraw() external {
    uint256 amount = pendingWithdrawals[msg.sender];
    pendingWithdrawals[msg.sender] = 0;
    (bool sent,) = payable(msg.sender).call{value: amount, gas: 10000}("");
    if (!sent) pendingWithdrawals[msg.sender] = amount;
}
```

### TypeScript — Parameterize Hook by Address

```typescript
// Before — coupled to useAccount (can't read other wallets)
function usePhrsBalance() {
  const { address } = useAccount()
  return useBalance({ address, chainId: 1672 })
}

// After — parameterized, reusable
function usePhrsBalance(address: `0x${string}` | undefined) {
  return useBalance({ address, chainId: 1672 })
}
```

### NatSpec Convention for Pharos Contracts

```solidity
/// @notice What this function does
/// @param param Description
/// @return Return description
/// @dev Pharos: PHRS has no 2300 gas stipend — use gas cap
/// @custom:pharos-chain 1672
```

## When to Use

refactor, code health, cleanup, simplify, remove duplication, technical debt, restructure, improve structure, readability

## When NOT to Use

adding new features (use the relevant authoring subskill), or fixing bugs (use bug-finding-and-debugging)

## Prerequisites
- **Security**:
    - **.env Usage**: Environment variables MUST be stored in a `.env` file in the project root. NEVER use `export VAR=...` for sensitive data.
    - **Mandatory Check**: The Agent MUST verify `.env` exists and variables are set using `grep -q` (NEVER `cat`, `head`, `tail` — those expose secrets) before any deployment or on-chain action.
    - **Git**: Ensure `.env` is listed in `.gitignore` to prevent accidental commits.

- **Foundry**: `forge build` must succeed. Run `forge --version` to verify installation.
- **RPC endpoint**: Set `PHAROS_TESTNET_RPC=$PHAROS_TESTNET_RPC_URL` or `PHAROS_MAINNET_RPC=$PHAROS_MAINNET_RPC_URL` in your environment or `.env`.
- **PharosScan API key**: Set `PHAROSSCAN_API_KEY` for contract verification.
- **Network reachability**: Run `cast chain-id --rpc-url $RPC_URL` to confirm the target network is reachable.
- **Tests passing**: The current test suite should pass before refactoring.
## Workflow
- **Strict .env Check**: Confirm `.env` exists with `test -f .env` and check variables via `grep -q` (without printing values). NEVER print `.env` contents. Do NOT proceed if missing or if the user suggests `export`.

1. **Requirement Gathering**: Analyze the user's request to identify the specific task, target environment (Atlantic 688689 or Pacific 1672), and any missing context. Zero-assumption delivery.
2. **Mandatory Plan (`PLAN.md`)**: Create or update `PLAN.md` in the project root with the proposed strategy. **Wait for explicit 'Approve' or 'Proceed' from the user before taking any action.**
3. Identify the code smells or maintenance costs.
4. Check prerequisites: verify required tools are installed, env vars are set, and any required context is available. Ask the user for any missing values before proceeding.
5. Propose the refactor scope and behavior guarantees.
6. Show the plan and ask if the direction is correct.
7. Refactor with tests or checks that preserve behavior.
## Output

- refactor plan
- behavior guarantees
- cleanup notes
- verification result

## Examples

- "Refactor this usePhrsBalance hook to remove the useAccount dependency for Pharos mainnet (1672)"
- "Add a storage gap and NatSpec to this Pharos upgradeable contract"
- "Clean up the duplicated address validation logic across the Pharos staking codebase"
- "Replace full-gas PHRS .call with capped gas in the Pharos vault withdraw function"
- "Extract PHRS transfer logic into a library contract"

## Verification

No change in test results. forge test and npm test still pass. Diff shows no behavior change.

## Related

performance-optimization (performance-driven changes), solidity-authoring (contract refactors)

## Gate


Medium risk. Present the refactor plan and behavior guarantees first; proceed only after the user agrees on scope.

## Pharos Refactoring Patterns

### Struct Packing (SALI Optimization)

Before (3 slots):
```solidity
struct Position {
    uint256 supplied;     // 32 bytes
    uint256 borrowed;     // 32 bytes
    uint256 timestamp;    // 32 bytes - total: 96 bytes = 3 storage slots
}
```

After (1 slot):
```solidity
struct Position {
    uint128 supplied;     // 16 bytes
    uint128 borrowed;     // 16 bytes
    uint48  timestamp;    // 6 bytes
    // Total: 38 bytes = 1 storage slot (38 < 32... actually need 2 slots)
}
```

> See: `contracts/PharosLendingPool.sol` `Position` struct

### Custom Error Migration

Before (costs ~24k gas per revert):
```solidity
require(amount > 0, "Amount must be positive");
```

After (costs ~140 gas per revert):
```solidity
error ZeroAmount();
if (amount == 0) revert ZeroAmount();
```

> Applied in: All project contracts

### Immutable Chain ID

```solidity
// contracts/PharosLendingPool.sol
uint256 public immutable i_chainId;

constructor(uint256 _chainId) {
    i_chainId = _chainId;
}
```

## Code Smells to Fix

- [ ] Hardcoded addresses → use constructor params or env vars
- [ ] No events on state changes → add events
- [ ] `memory` instead of `calldata` for read-only params → change to `calldata`
- [ ] Missing NatSpec → add `@param`, `@return`, `@dev` tags
- [ ] Redundant `SafeERC20` on known-safe tokens → can use raw `transfer`

## References

- `contracts/DEXPool.sol` — `_sqrt` helper, unchecked math
- `contracts/PharosSPNPaymaster.sol` — calldata params, batch operations
- `contracts/StakingPool.sol` — pull-over-push pattern
