---
name: pharos-gas-optimization
description: "Optimize Solidity contract gas usage for Pharos-specific conditions: SALI-friendly storage layout, batch operations, DTVM dual-VM gas costing, EIP-1559 fee estimation, block gas limit of 1 billion, ~80% cheaper storage than Ethereum. Use when the user says: gas optimization, gas golf, save gas, reduce gas cost, optimize contract, gas efficient, storage optimization, batch, SALI, DTVM, gas estimation, fee estimation, block gas limit, cheaper storage, calldata optimization, EIP-1559. Do NOT use for: runtime performance optimization in frontend code (use performance-optimization), general code refactoring (use refactoring-and-code-health), or architecture design unrelated to gas (use contract-architecture). See also: performance-optimization (frontend), contract-architecture (storage layout design), refactoring-and-code-health (code structure)."
---

# Gas Optimization

Optimize Solidity contract gas usage for Pharos-specific conditions: SALI-friendly storage layout, batch operations, DTVM dual-VM gas costing, EIP-1559 fee estimation.

## When to Use

gas optimization, gas golf, save gas, reduce gas cost, optimize contract, gas efficient, storage optimization, batch, SALI, DTVM, gas estimation, fee estimation, block gas limit, cheaper storage, calldata optimization, EIP-1559

## When NOT to Use

runtime performance optimization in frontend code (use performance-optimization), general code refactoring (use refactoring-and-code-health), or architecture design unrelated to gas (use contract-architecture)

## Workflow

1. Profile current gas usage via Foundry gas reports (`forge test --gas-report`) or Hardhat gas reporter.
2. Identify high-gas paths: storage writes, loops, external calls, event emissions.
3. Apply Pharos-specific optimizations: SALI-friendly packed storage (uint32/int32 for timestamps, uint128 for balances), batch operations (multi-transfer, multi-approve), calldata optimization (use bytes over arrays where possible).
4. Adjust for Pharos DTVM dual-VM costing: WASM execution has different cost curves — prefer EVM-optimized paths.
5. Estimate fees using EIP-1559 parameters and Pharos block gas limit (1 billion). Storage on Pharos is ~80% cheaper than Ethereum — prioritize storage-based caching over recomputation.

## Output

- gas report (before/after comparison)
- optimized contract code with documented gas savings
- storage layout recommendation (SALI-friendly packing)
- batch operation interfaces
- fee estimation for common transactions

## Examples

- "Reduce gas costs for my ERC-20 transfer function on Pharos"
- "Optimize storage layout for Pharos SALI-friendly packing"
- "Add batch withdraw function to save gas on multi-user payouts"
- "Profile and optimize my staking contract gas usage"

## Verification

Run `forge test --gas-report` and compare before/after gas usage. Verify the gas-reduced functions still pass all tests.

## Related

performance-optimization (frontend), contract-architecture (storage layout design), refactoring-and-code-health (code structure)
