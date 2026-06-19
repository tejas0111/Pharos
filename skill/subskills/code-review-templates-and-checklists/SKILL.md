# Code Review Templates & Checklists

## Overview

Standardized code review checklists for Pharos smart contracts. Every review must cover: security, gas optimization, Pharos-specific features, testing coverage, and documentation.

## Universal Review Checklist

### Security
- [ ] Custom errors used (not `require` strings) — see `contracts/DEXPool.sol` for pattern
- [ ] ReentrancyGuard inherited on all external-facing functions — see `contracts/StakingPool.sol`
- [ ] SafeERC20 used for all token transfers — see `contracts/SimpleLender.sol`
- [ ] Pull-over-push pattern enforced — see `contracts/StakingPool.sol` repay pattern
- [ ] No unprotected `selfdestruct` or `delegatecall`
- [ ] Integer overflow/underflow checked (Solidity 0.8+ safe, but unchecked blocks audited)
- [ ] Access control: `onlyOwner` or role-based, not `tx.origin`

### Gas Optimization
- [ ] Structs packed to fit in minimum slots — see `contracts/PharosLendingPool.sol Position`
- [ ] `calldata` used instead of `memory` for read-only params — see `contracts/PharosSPNPaymaster.sol`
- [ ] Unchecked arithmetic where safe — see `contracts/DEXPool.sol` `_sqrt` function
- [ ] Events emitted for all state changes
- [ ] No redundant storage reads within loops

### Pharos-Specific
- [ ] Chain ID stored as immutable — see all contracts (`i_chainId`)
- [ ] SPN Paymaster compatible (if sponsoring gas) — see `contracts/PharosSPNPaymaster.sol`
- [ ] EntryPoint checks for account abstraction — `msg.sender == i_entryPoint`
- [ ] Atlantic testnet (688689) vs Pacific mainnet (1672) handled — see deploy scripts
- [ ] zkLogin identity commitment pattern (if using identity abstraction)

### Testing
- [ ] Unit tests for all public functions
- [ ] Fuzz tests for critical math — see `test/Counter.t.sol` for pattern
- [ ] Invariant tests for supply caps — see `test/PharosERC20Invariants.t.sol`
- [ ] Edge cases: zero amounts, max uint256, reentrancy

### Deployment
- [ ] Constructor args validated against zero-address — see all constructors
- [ ] Explorable via PharosScan
- [ ] Broadcast simulation before real deploy — `forge script ... --slow`

## Pharos Contract Review Templates

### ERC-20 Token Review
```
1.  Total supply cap enforced? → PharosRWAToken.sol
2.  KYC/whitelist enforced? → RWAToken.sol
3.  Pausable for emergencies? → PharosRWAToken.sol
4.  Freeze individual accounts? → PharosRWAToken.sol
5.  EIP-2612 permits for gasless approvals?
```

### DeFi Protocol Review
```
1.  Interest rate model? (linear/kinked) → PharosLendingPool.sol
2.  Liquidation penalty configurable? → SimpleLender.sol
3.  Oracle dependency? (Pharos doesn't have native oracle)
4.  minLTV / maxLTV enforced? → PharosLendingPool.sol
```

### AMM/DEX Review
```
1.  Constant product formula (x*y=k)? → DEXPool.sol
2.  Slippage protection (`minAmountOut`)? → DEXPool.sol swap()
3.  Fee accumulators? → DEXPool.sol (0.3% default)
4.  LP token mint/burn ratio? → DEXPool.sol addLiquidity()/removeLiquidity()
```

## CI/CD Checklist

- [ ] GitHub Actions passing — check `.github/workflows/`
- [ ] `forge build` no errors
- [ ] `forge test` — all tests pass
- [ ] Slither analysis clean (if available)
- [ ] Gas report reviewed — `forge test --gas-report`
- [ ] Deployment broadcast simulated — `forge script --slow`

## References

- All contracts in `contracts/` follow these patterns
- `test/PharosERC20Invariants.t.sol` — invariant testing pattern
- `test/Counter.t.sol` — fuzz testing pattern
