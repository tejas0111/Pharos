---
name: pharos-rwa-compliance
description: "Implement Real-World Asset (RWA) patterns on Pharos: whitelist-based transfer control, stablecoin depeg protection (oracle-triggered circuit breaker), redemption queues, liquidity reserves (5-10% buffer), NAV-based pricing, legal isolation (SPV), Supra DORA + Chainlink oracles. Use when the user says: RWA, real-world asset, tokenized asset, stablecoin, depeg protection, circuit breaker, whitelist transfer, redemption queue, liquidity reserve, NAV pricing, SPV, legal isolation, Supra DORA, compliance, transfer restriction, KYC, accredited investor, security token, regulated token, MiCA, SEC. Do NOT use for: standard ERC-20/721 development (use solidity-authoring), DeFi protocol design (use contract-architecture), or security review (use security-audit). See also: contract-architecture (system design), security-audit (compliance security review), upgrade-patterns (RWA contract upgrades)."
metadata:
  audience: developer
  version: 1.0.0
  category: rwa
---

# RWA Compliance

Implement Real-World Asset (RWA) patterns on Pharos: whitelist-based transfer control, stablecoin depeg protection, redemption queues, liquidity reserves, NAV-based pricing, legal isolation.

## When to Use

RWA, real-world asset, tokenized asset, stablecoin, depeg protection, circuit breaker, whitelist transfer, redemption queue, liquidity reserve, NAV pricing, SPV, legal isolation, Supra DORA, compliance, transfer restriction, KYC, accredited investor, security token, regulated token, MiCA, SEC

## When NOT to Use

- **Standard ERC-20/721 development** — If the user needs a plain token without whitelist transfers or compliance restrictions, use `solidity-authoring`.
- **DeFi protocol design** — If the user is building a DEX, lending pool, or yield aggregator without RWA-specific features, use `contract-architecture`.
- **Security review** — If the user wants a formal vulnerability assessment, use `security-audit` (which can review RWA contracts separately).
- **Stablecoin without RWA backing** — If the user wants a simple algorithmic or over-collateralized stablecoin (e.g., CDP-style) without real-world asset backing, use `contract-architecture`.
- **KYC/off-chain identity** — If the user needs an off-chain identity or KYC provider integration (not on-chain whitelist enforcement), route to `contract-architecture` or a dedicated identity subskill.

## Workflow

1. Implement whitelist-based transfer control: only whitelisted addresses can hold or transfer the RWA token. Use a role-based access control with a compliance officer role.
2. Add stablecoin depeg protection: oracle-triggered circuit breaker from Supra DORA and Chainlink that pauses minting/redeeming if the peg deviates beyond a threshold.
3. Build redemption queue: FIFO queue with cooldown period, proportional redemption during liquidity shortfalls, and priority for small holders.
4. Maintain liquidity reserves at 5-10% of total supply. Configure reserve rebalancing triggers.
5. Implement NAV (Net Asset Value) based pricing: on-chain NAV feed from a trusted oracle, with a grace period for oracle staleness.
6. Structure legal isolation via an SPV (Special Purpose Vehicle) contract pattern where the SPV acts as the legal wrapper for off-chain assets.

## Output

- whitelist transfer control contract (compliance module)
- stablecoin depeg circuit breaker (oracle integration)
- redemption queue contract
- liquidity reserve management contract
- NAV pricing oracle integration
- SPV isolation contract
- deployment and configuration guide

## Examples

- **Query:** "Implement a whitelist-based transfer control for a tokenized real estate fund" → **Action:** Build compliance module with `_beforeTokenTransfer` hook checking whitelist, deploy role-based access control with compliance officer role, write test for whitelisted and non-whitelisted transfers.
- **Query:** "Add stablecoin depeg protection with Supra DORA and Chainlink oracles" → **Action:** Integrate dual oracle feeds, configure depeg threshold (e.g., ±2% from peg), implement circuit breaker that pauses mint/redeem, add re-peg detection for automatic resumption.
- **Query:** "Design a redemption queue with liquidity reserve buffer" → **Action:** Build FIFO queue with cooldown period, proportional redemption logic for liquidity shortfalls, priority queue for small holders, set reserve rebalancing triggers at 5-10% of total supply.
- **Query:** "Set up NAV-based pricing for an RWA token" → **Action:** Integrate on-chain NAV feed from trusted oracle, implement `convertToShares`/`convertToAssets` with NAV, configure grace period for oracle staleness, add fallback pricing mechanism.
- **Query:** "Structure an SPV legal isolation wrapper for on-chain assets" → **Action:** Deploy SPV contract as legal wrapper for off-chain assets, configure asset segregation, document role of SPV in legal structure (bankruptcy remoteness), integrate with compliance module for accredited investor checks.

## Verification

Deploy on testnet with mock compliance roles. Test whitelist transfer restriction (non-whitelisted addresses cannot receive). Simulate depeg event and verify circuit breaker triggers. Test redemption queue processing order and reserve ratio enforcement.

## Related

contract-architecture (system design), security-audit (compliance security review), upgrade-patterns (RWA contract upgrades)
