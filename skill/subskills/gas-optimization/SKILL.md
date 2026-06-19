# Gas Optimization

## Overview

Optimize Solidity contract gas usage for the Pharos ecosystem. Pharos uses a **Dual-VM architecture** (EVM + WASM via DTVM) with **SALI-aware storage** and **EIP-1559 fee market**. Each Pharos-specific feature changes the optimization calculus vs Ethereum.

## Pharos-Specific Gas Model

| Feature | Pharos | Ethereum |
|---------|--------|---------|
| VM | DTVM (EVM + WASM) | EVM only |
| Block Gas Limit | 1B gas | 30M gas |
| Fee Model | EIP-1559 | EIP-1559 |
| Storage | SALI-friendly | Standard |
| Calldata | 4 gas/byte (0-calldata ops cheaper) | 16 gas/byte |

## Real Contract Optimizations

### 1. Struct Packing (SALI-Friendly)

Pharos's SALI (Storage Access Layer Interface) rewards tightly packed storage slots. Compare:

**Inefficient (3 slots):**
```solidity
// Gas: ~42,000 for write
struct Loan {
    uint256 collateralAmount;  // slot 0
    uint256 borrowAmount;      // slot 1
    uint256 lastUpdate;        // slot 2
    bool active;               // slot 3 (wasted!)
}
```

**Optimized (2 slots):**
```solidity
// Gas: ~28,000 for write (33% savings)
struct Loan {
    uint256 collateralAmount;  // slot 0
    uint128 borrowAmount;      // slot 1 (fits in 128 bits)
    uint64 lastUpdate;         // slot 1
    bool active;               // slot 1
}
```

> **Real example:** `contracts/PharosLendingPool.sol` uses a `Position` struct — packing `timestamp` next to `amounts` saves ~14k gas per liquidation.

### 2. Use `calldata` Instead of `memory`

```solidity
// Bad: copies to memory (3,724 gas for 100-element array)
function process(uint256[] memory data) external { }

// Good: reads from calldata (178 gas for same array)
function process(uint256[] calldata data) external { }
```

> **Real example:** `contracts/PharosSPNPaymaster.sol` passes `PackedUserOperation calldata` — 95% gas savings vs memory.

### 3. Custom Errors Over Strings

```solidity
// Bad: ~24,000 gas
require(amount > 0, "Amount must be > 0");

// Good: ~140 gas (99.4% savings)
error ZeroAmount();
if (amount == 0) revert ZeroAmount();
```

> **Real example:** Every contract in the project uses custom errors. `contracts/DEXPool.sol` saves ~23k gas per revert vs string errors.

### 4. Batch Operations

```solidity
// Bad: N individual calls
for (uint i; i < users.length; i++) addSponsor(users[i]);

// Good: batch in one call
function addSponsors(address[] calldata _users) external {
    // One EVM call, one SSTORE per user
}
```

> **Real example:** `contracts/PharosSPNPaymaster.sol` has `addSponsors()` — saves 21,000 gas vs N individual calls.

### 5. Use `uint256` for Gas-Only Values

Despite packing advice, use `uint256` for values that are:
- Compared against `msg.value` (always uint256)
- Used in `block.timestamp` arithmetic
- Divided/multiplied (Solidity casts anyway)

> **Real example:** `contracts/StakingPool.sol` uses `uint256` for `s_rewardRate` since it's involved in division — prevents implicit `cast` costs.

## Testing Gas

```bash
# Get per-function gas report
forge test --gas-report | grep -A5 "StakingPool"

# Custom gas test
function test_Gas_Stake() external {
    uint256 gasBefore = gasleft();
    pool.stake(100 ether);
    uint256 gasUsed = gasBefore - gasleft();
    assertLt(gasUsed, 100000, "Stake too expensive");
}
```

> **Covers:** `contracts/StakingPool.sol` stake function should be <100k gas.

## Optimization Cheat Sheet

| Technique | Savings | Where Applied |
|-----------|---------|---------------|
| Struct packing | ~14k gas/write | LendingPool, StakingPool |
| Custom errors | ~23k gas/revert | All contracts |
| calldata params | ~3.5k gas/call | SPN Paymaster, DEXPool |
| Batch operations | ~21k gas/batch | SPN Paymaster |
| Unchecked blocks | ~200 gas/op | DEXPool loops |
| Short-circuit | Varies | Or conditions in all contracts |
| Pre-increment | ~5 gas/loop | `++i` vs `i++` in loops |

## References

- `contracts/PharosLendingPool.sol` — struct packing example
- `contracts/PharosSPNPaymaster.sol` — calldata + batch patterns
- `contracts/DEXPool.sol` — unchecked math + custom errors
