---
name: pharos-upgrade-patterns
description: "Design and implement contract upgrade patterns on Pharos: UUPS, Transparent proxy, Beacon proxy. Cover storage slot safety, multi-sig ownership transfer, timelocks, and Pharos Safes. Use when the user says: upgrade, proxy, UUPS, transparent proxy, beacon proxy, storage collision, upgradeability, proxy pattern, EIP-1967, EIP-1822, EIP-2535, diamond, initializable, reinitializer, storage gap, multi-sig ownership, timelock, Safe, safe wallet, master copy, ownership transfer. Do NOT use for: writing initial contracts (use solidity-authoring), general architecture (use contract-architecture), or migration planning (use migration-and-backward-compatibility). See also: contract-architecture (design), migration-and-backward-compatibility (migration path), security-audit (proxy security review)."
---

# Upgrade Patterns

Design and implement contract upgrade patterns on Pharos: UUPS, Transparent proxy, Beacon proxy. Cover storage slot safety, multi-sig ownership transfer, timelocks, and Pharos Safes.

## When to Use

upgrade, proxy, UUPS, transparent proxy, beacon proxy, storage collision, upgradeability, proxy pattern, EIP-1967, EIP-1822, EIP-2535, diamond, initializable, reinitializer, storage gap, multi-sig ownership, timelock, Safe, safe wallet, master copy, ownership transfer

## When NOT to Use

writing initial contracts (use solidity-authoring), general architecture (use contract-architecture), or migration planning (use migration-and-backward-compatibility)

## Workflow

1. Choose the upgrade pattern based on trust model and gas requirements: UUPS (cheapest deploy, complex logic in implementation), Transparent (simple, higher overhead), Beacon (many proxies, shared logic).
2. Design storage layout with gaps, explicit slots, and append-only patterns. Never reorder or remove existing variables.
3. Implement the proxy and implementation contracts with initializable pattern and access control.
4. Configure multi-sig ownership via Pharos Safe (master copy: 0x41675C099F32341bf84BFc5382aF534df5C7461a) and optional timelock.
5. Test upgrade flow on testnet: deploy proxy, deploy v2 implementation, upgrade, verify state preservation.

## Output

- proxy contract (UUPS, Transparent, or Beacon)
- implementation contracts (v1, v2 with storage diff)
- upgrade script (Foundry or Hardhat)
- multi-sig ownership transfer transaction data
- storage layout audit report

## Examples

- "Set up a UUPS proxy for my staking contract on Pharos"
- "Design a Beacon proxy pattern for multiple token contracts"
- "Plan a safe upgrade with storage gap and multi-sig ownership"
- "Transfer proxy admin to a Pharos Safe multi-sig"
- "Add a timelock between upgrade proposal and execution"

## Verification

Deploy proxy + v1 on testnet, initialize, verify state. Deploy v2, upgrade via proxy admin, verify state preserved and new functions work. Run `forge inspect` for storage layout compatibility.

## Related

contract-architecture (design), migration-and-backward-compatibility (migration path), security-audit (proxy security review)
