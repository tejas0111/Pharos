---
name: pharos-rwa-compliance
description: "Implement Real-World Asset (RWA) patterns on Pharos: whitelist-based transfer control, stablecoin depeg protection (oracle-triggered circuit breaker), redemption queues, liquidity reserves (5-10% buffer), NAV-based pricing, legal isolation (SPV), Supra DORA + Chainlink oracles. Use when the user says: RWA, real-world asset, tokenized asset, stablecoin, depeg protection, circuit breaker, whitelist transfer, redemption queue, liquidity reserve, NAV pricing, SPV, legal isolation, Supra DORA, compliance, transfer restriction, KYC, accredited investor, security token, regulated token, MiCA, SEC. Do NOT use for: standard ERC-20/721 development (use solidity-authoring), DeFi protocol design (use contract-architecture), or security review (use security-audit). See also: contract-architecture (system design), security-audit (compliance security review), upgrade-patterns (RWA contract upgrades)."
---

# RWA Compliance

Implement Real-World Asset (RWA) patterns on Pharos: whitelist-based transfer control, stablecoin depeg protection, redemption queues, liquidity reserves, NAV-based pricing, legal isolation.

## When to Use

RWA, real-world asset, tokenized asset, stablecoin, depeg protection, circuit breaker, whitelist transfer, redemption queue, liquidity reserve, NAV pricing, SPV, legal isolation, Supra DORA, compliance, transfer restriction, KYC, accredited investor, security token, regulated token, MiCA, SEC

## When NOT to Use

standard ERC-20/721 development (use solidity-authoring), DeFi protocol design (use contract-architecture), or security review (use security-audit)

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

- "Implement a whitelist-based transfer control for a tokenized real estate fund"
- "Add stablecoin depeg protection with Supra DORA and Chainlink oracles"
- "Design a redemption queue with liquidity reserve buffer"
- "Set up NAV-based pricing for an RWA token"
- "Structure an SPV legal isolation wrapper for on-chain assets"

## Verification

Deploy on testnet with mock compliance roles. Test whitelist transfer restriction (non-whitelisted addresses cannot receive). Simulate depeg event and verify circuit breaker triggers. Test redemption queue processing order and reserve ratio enforcement.

## Related

contract-architecture (system design), security-audit (compliance security review), upgrade-patterns (RWA contract upgrades)
