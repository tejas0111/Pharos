---
name: pharos-gas-optimization
description: "Optimize Solidity contract gas usage for Pharos-specific conditions: SALI-friendly storage layout, batch operations, DTVM dual-VM gas costing, EIP-1559 fee estimation, block gas limit of 1 billion, ~80% cheaper storage than Ethereum. Use when the user says: gas optimization, gas golf, save gas, reduce gas cost, optimize contract, gas efficient, storage optimization, batch, SALI, DTVM, gas estimation, fee estimation, block gas limit, cheaper storage, calldata optimization, EIP-1559. Do NOT use for: runtime performance optimization in frontend code (use performance-optimization), general code refactoring (use refactoring-and-code-health), or architecture design unrelated to gas (use contract-architecture). See also: performance-optimization (frontend), contract-architecture (storage layout design), refactoring-and-code-health (code structure)."
metadata:
  audience: developer
  version: 1.0.0
  category: optimization
---

# Gas Optimization

Optimize Solidity contract gas usage for Pharos-specific conditions: SALI-friendly storage layout, batch operations, DTVM dual-VM gas costing, EIP-1559 fee estimation.

## When to Use

gas optimization, gas golf, save gas, reduce gas cost, optimize contract, gas efficient, storage optimization, batch, SALI, DTVM, gas estimation, fee estimation, block gas limit, cheaper storage, calldata optimization, EIP-1559

## When NOT to Use

- **Frontend/off-chain performance** — If the user asks about JS rendering, API response times, or DB queries, use `performance-optimization` instead.
- **General code refactoring** — If the goal is readability or restructuring without gas as a concern, use `refactoring-and-code-health`.
- **Architecture design unrelated to gas** — If the discussion is about contract modularization without gas trade-offs, use `contract-architecture`.
- **Micro-optimizations without profiling** — If the user wants to replace `>` with `!=` without measuring first, suggest profiling via `forge test --gas-report`.
- **L1 Ethereum optimization** — If the user is deploying on Ethereum (not Pharos), standard Solidity gas techniques apply; this subskill is Pharos-specific (SALI, DTVM, 1B block gas limit).

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

- **Query:** "Reduce gas costs for my ERC-20 transfer function on Pharos" → **Action:** Profile via `forge test --gas-report`, identify high-cost paths (SSTORE, SLOAD), apply SALI-friendly `uint128` packing for balances, use unchecked arithmetic for known-safe operations.
- **Query:** "Optimize storage layout for Pharos SALI-friendly packing" → **Action:** Audit current storage slots, group `uint32`/`int32`/`uint128` variables into fewer slots, reorder struct fields, add explicit storage gaps for future upgrades.
- **Query:** "Add batch withdraw function to save gas on multi-user payouts" → **Action:** Design `batchWithdraw(address[], uint256[])` that processes all recipients in one transaction, compute gas savings vs individual calls, verify against Pharos block gas limit of 1 billion.
- **Query:** "Profile and optimize my staking contract gas usage" → **Action:** Set up `forge test --gas-report`, identify top consumers (stake/unstake/claim), apply Pharos optimizations (batch ops, SALI packing, calldata optimization), produce before/after comparison table.

## Verification

Run `forge test --gas-report` and compare before/after gas usage. Verify the gas-reduced functions still pass all tests.

## Related

performance-optimization (frontend), contract-architecture (storage layout design), refactoring-and-code-health (code structure)
