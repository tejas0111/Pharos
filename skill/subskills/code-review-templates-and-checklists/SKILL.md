# Code Review Templates & Checklists

## Overview

Standardized code review process for Pharos smart contracts. Every review must follow the universal checklist below and apply contract-specific templates where applicable.

## Severity Ratings

| Severity | Label | Definition | Action |
|----------|-------|------------|--------|
| 🔴 Critical | `C-` | Direct loss of funds or bricked contract | Must fix before any deployment |
| 🟡 High | `H-` | Incorrect behavior under edge cases | Must fix before mainnet |
| 🟢 Medium | `M-` | Gas inefficiency or poor DX | Should fix, document if deferred |
| ⚪ Low | `L-` | Style / naming / warnings | Note for cleanup |

## Sample Review Report Format

```markdown
## Review: PharosLendingPool.sol
**Reviewer:** AI Agent | **Date:** 2026-06-20

### Summary
2 critical, 1 high, 3 medium findings

### 🔴 C-1: Missing reentrancy guard on liquidate()
**File:** contracts/PharosLendingPool.sol:120
**Issue:** `liquidate()` calls `_seizeCollateral()` before updating state
```solidity
// BAD: State updated after external call
function liquidate(address user, uint256 debt) external {
    _seizeCollateral(user);  // External call before state update
    s_positions[user].borrowed -= debt;
}
```
```solidity
// GOOD: Checks-Effects-Interactions pattern
function liquidate(address user, uint256 debt) external {
    uint256 penalty = debt * s_liquidationBonus / 10000;
    s_positions[user].borrowed -= debt;  // State first
    _seizeCollateral(user, penalty);     // Then external
}
```

### 🟢 M-1: Unused variable in constructor
**File:** contracts/PharosLendingPool.sol:25
**Issue:** `_chainId` parameter is stored but never read
**Fix:** Remove parameter or use it for `chainId()` view
```

## Universal Review Checklist

### 🔒 Security (check each)
- [ ] Custom errors used instead of `require` strings (gas / DX)
- [ ] Reentrancy guard on all state-changing `external` functions
- [ ] `SafeERC20` used for all token transfers (returns checked)
- [ ] Pull-over-push pattern for withdrawals (user pulls, not contract pushes)
- [ ] Input validation: zero-address, zero-amount, bounds checks
- [ ] Access control: `onlyOwner` / `onlyRole` on all admin functions
- [ ] No `tx.origin` for authentication (use `msg.sender`)

### ⛽ Gas Optimization (check applicable)
- [ ] Structs packed to fit in fewer slots (≤ 32 bytes per field where possible)
- [ ] `calldata` instead of `memory` for read-only params
- [ ] `unchecked` blocks used safely for increment operations
- [ ] Events emitted for all state changes
- [ ] Redundant `SLOAD`s cached in local variables

### ⚓ Pharos-Specific (check each)
- [ ] `i_chainId` declared as `uint256 public immutable` for replay protection
- [ ] Storage layout compatible with SPN Paymaster (no delegatecall conflicts)
- [ ] EntryPoint address verified for AA contracts (`0x0000...a032`)
- [ ] Correct chain ID used: Atlantic (688689) vs Pacific (1672)
- [ ] zkLogin ephemeral keys use 1-hour expiry
- [ ] `vm.createSelectFork("pharos_testnet")` used in integration tests

### 🧪 Testing (check each)
- [ ] Unit test for every public/external function
- [ ] Fuzz tests for critical math (liquidation, swap, interest)
- [ ] Invariant tests for DeFi contracts (DEXPool, LendingPool, StakingPool)
- [ ] Revert paths tested (`vm.expectRevert`)
- [ ] Fork tests for multi-contract interactions

### 🚀 Deployment (check each)
- [ ] Constructor arguments validated (no zero-addresses, bounds)
- [ ] PharosScan verification configured (`--verifier-url`)
- [ ] Broadcast simulation run before real deployment
- [ ] Contract address saved to DEPLOYMENTS.md with explorer link

## Contract-Specific Templates

### ERC-20 Token
```solidity
// Things to check in ERC-20 reviews:
// 1. Supply cap enforced in mint() — cannot exceed MAX_SUPPLY
// 2. KYC/whitelist checks on transfer() and transferFrom()
// 3. Pause mechanism stops transfers and approvals
// 4. Freeze function can lock individual accounts
// 5. EIP-2612 permit() correctly handles signature verification
```

### DeFi Protocol (Lending / Staking)
```solidity
// Things to check in DeFi reviews:
// 1. Interest rate model uses correct precision (ray = 1e27)
// 2. Liquidation bonus doesn't exceed collateral
// 3. Health factor uses borrow-index-adjusted debt
// 4. Max LTV enforced on borrow(), not just withdraw()
// 5. Reserve factor prevents reserve rug
```

### AMM / DEX
```solidity
// Things to check in AMM reviews:
// 1. Constant product k = reserveA * reserveB is never destroyed
// 2. getAmountOut uses (amountIn * 997) / 1000 for 0.3% fee
// 3. Slippage protection via minAmountOut parameter
// 4. LP token mint/burn matches share of reserves
// 5. Swap reentrancy protection on all entry points
```

## CI/CD Checklist

- [ ] `forge build` passes with 0 errors
- [ ] `forge test` passes with 0 failures
- [ ] Gas report reviewed for regressions (`forge snapshot --diff`)
- [ ] `forge script` with `--broadcast` simulated first
- [ ] Slither or other static analysis clean (optional but recommended)

## Related Subskills

- `security-audit` — Deep security analysis patterns
- `contract-review` — Technical review workflow
- `testing-strategy` — How to write tests for review coverage
- `gas-optimization` — Gas-focused review patterns
