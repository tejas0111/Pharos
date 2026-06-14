---
name: pharos-gas-optimization
description: "Optimize Solidity contract gas usage for Pharos-specific conditions: SALI-friendly storage layout, batch operations, DTVM dual-VM gas costing, EIP-1559 fee estimation, block gas limit of 1 billion, ~80% cheaper storage than Ethereum, PHRS transfer base cost, and SSTORE costs on Pharos. Use when optimizing gas costs, reducing gas usage, or profiling contract gas on Pharos. Keywords: gas optimization, gas golf, save gas, reduce gas cost, optimize contract, gas efficient, storage optimization, batch, SALI, DTVM, gas estimation, fee estimation, block gas limit, cheaper storage, calldata optimization, EIP-1559, PHRS gas cost."
metadata:
  audience: developer
  version: 1.2.0
  category: optimization
slash: true
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

## Prerequisites
- **Gate Fix**: Perform the mandatory "Gate Fix" check before proceeding.
- **Security**: Private keys must be stored in `.env` and accessed via `${PRIVATE_KEY}`.

- **Foundry**: `forge build` must succeed. Run `forge --version` to verify installation.
- **RPC endpoint**: Set `PHAROS_TESTNET_RPC=https://atlantic.dplabs-internal.com` or `PHAROS_MAINNET_RPC=https://rpc.pharos.xyz` in your environment or `.env`.
- **PharosScan API key**: Set `PHAROSSCAN_API_KEY` for contract verification (https://pharosscan.xyz).
- **Network reachability**: Run `cast chain-id --rpc-url $RPC_URL` to confirm the target network is reachable.
- **Foundry config**: `foundry.toml` should have `[rpc_endpoints]` section with `pharos_testnet` and `pharos_mainnet` entries.
## Workflow

1. **Requirement Gathering**: Analyze the user's request to identify the specific task, target environment (Atlantic 688689 or Pacific 1672), and any missing context. Zero-assumption delivery.
2. **Mandatory Plan (`PLAN.md`)**: Create or update `PLAN.md` in the project root with the proposed strategy. **Wait for explicit 'Approve' or 'Proceed' from the user before taking any action.**
3. Profile current gas usage via Foundry gas reports (`forge test --gas-report`) or Hardhat gas reporter.
4. Check prerequisites: verify Foundry is installed, RPC endpoints are reachable, and required env vars are set. Ask the user for any missing values before proceeding.
5. Identify high-gas paths: storage writes (SSTORE ~20K gas warm / ~22K gas cold on Pharos; SLOAD ~200 gas warm / ~2100 gas cold — Ethereum baseline: SLOAD 2100/100, SSTORE 22100/2900), loops, external calls, event emissions (LOG0 ~375 gas, LOG1 ~750 gas + ~375 per topic + ~8 per byte), PHRS transfers (base cost ~21K gas). SSTORE refund when clearing storage: ~4800 gas refunded.
6. Present the optimization plan with before/after estimates and ask for approval before proceeding.
7. Apply Pharos-specific optimizations: SALI-friendly packed storage (uint32/int32 for timestamps, uint128 for balances). SALI opcode costs: SLOAD ~200 gas (warm) / ~2100 gas (cold), SSTORE ~800 gas (warm) / ~2200 gas (cold), SALOAD ~100 gas, SASAVE ~400 gas, SLOT ~60 gas, SCOPE ~80 gas. Batch operations (multi-transfer, multi-approve), calldata optimization (use bytes over arrays where possible). Prefer native PHRS transfers over ERC-20 transfers for value movement (PHRS base transfer ~21K gas vs ERC-20 transfer ~35-50K gas).
8. Adjust for Pharos DTVM dual-VM costing: contracts deploy to EVM by default. WASM execution costs ~30-40% less for compute-heavy ops but ~10-15% more for storage ops. WASM is best for pure computation (hashing, merkle proofs), EVM for storage-heavy contracts (ERC-20, ERC-721). Use `--vm wasm` flag in forge for WASM target if deploying compute-intensive logic.
9. Estimate fees using EIP-1559 parameters: Pharos base fee typically 1-10 gwei, priority fee tip 0.1-1 gwei. Block gas limit is 1 billion. Use Pharos RPC for gas estimation: `cast gas-estimate --rpc-url https://rpc.pharos.xyz`. Storage on Pharos is ~80% cheaper than Ethereum — prioritize storage-based caching over recomputation. For testnet gas estimation, use: `cast gas-estimate --rpc-url https://atlantic.dplabs-internal.com`.
## Output

- gas report (before/after comparison)
- optimized contract code with documented gas savings
- storage layout recommendation (SALI-friendly packing)
- batch operation interfaces
- fee estimation for common transactions

## Examples

- **Query:** "Reduce gas costs for my ERC-20 transfer function on Pharos" → **Action:** Profile via `forge test --gas-report`, identify high-cost paths (SSTORE, SLOAD), apply SALI-friendly `uint128` packing for balances, use unchecked arithmetic for known-safe operations. Consider replacing ERC-20 transfers with native PHRS transfers where possible (PHRS base transfer ~21K gas vs ERC-20 ~35-50K gas).
- **Query:** "Optimize storage layout for Pharos SALI-friendly packing" → **Action:** Audit current storage slots, group `uint32`/`int32`/`uint128` variables into fewer slots, reorder struct fields, add explicit storage gaps for future upgrades.
- **Query:** "Add batch withdraw function to save gas on multi-user payouts" → **Action:** Design `batchWithdraw(address[], uint256[])` that processes all recipients in one transaction using native PHRS transfers, compute gas savings vs individual calls, verify against Pharos block gas limit of 1 billion.
- **Query:** "Profile and optimize my staking contract gas usage" → **Action:** Set up `forge test --gas-report`, identify top consumers (stake/unstake/claim), apply Pharos optimizations (batch ops, SALI packing, calldata optimization), produce before/after comparison table.

## Verification

Run `forge test --gas-report` and compare before/after gas usage. For testnet-specific gas snapshots, use: `forge snapshot --rpc-url https://atlantic.dplabs-internal.com`. Cross-reference PHRS gas costs against current PHRS price for fiat cost calculations. Verify the gas-reduced functions still pass all tests.

## Related

performance-optimization (frontend), contract-architecture (storage layout design), refactoring-and-code-health (code structure)


## Gate
Medium risk. Show baseline gas report and proposed optimization before changing contract code. Do not trade safety (reentrancy, overflow) for gas savings without user approval.
