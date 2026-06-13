---
name: pharos-upgrade-patterns
description: "Design and implement contract upgrade patterns on Pharos: UUPS, Transparent proxy, Beacon proxy. Cover storage slot safety, multi-sig ownership transfer, timelocks, and Pharos Safes. Use when the user says: upgrade, proxy, UUPS, transparent proxy, beacon proxy, storage collision, upgradeability, proxy pattern, EIP-1967, EIP-1822, EIP-2535, diamond, initializable, reinitializer, storage gap, multi-sig ownership, timelock, Safe, safe wallet, master copy, ownership transfer. Do NOT use for: writing initial contracts (use solidity-authoring), general architecture (use contract-architecture), or migration planning (use migration-and-backward-compatibility). See also: contract-architecture (design), migration-and-backward-compatibility (migration path), security-audit (proxy security review)."
metadata:
  audience: developer
  version: 1.0.0
  category: upgrade
---

# Upgrade Patterns

Design and implement contract upgrade patterns on Pharos: UUPS, Transparent proxy, Beacon proxy. Cover storage slot safety, multi-sig ownership transfer, timelocks, and Pharos Safes.

## When to Use

upgrade, proxy, UUPS, transparent proxy, beacon proxy, storage collision, upgradeability, proxy pattern, EIP-1967, EIP-1822, EIP-2535, diamond, initializable, reinitializer, storage gap, multi-sig ownership, timelock, Safe, safe wallet, master copy, ownership transfer

## When NOT to Use

- **Writing initial contracts** — If the user is building a contract from scratch without upgrade considerations, use `solidity-authoring` for the initial implementation.
- **General architecture design** — If the request is about system modularization, inheritance trees, or interface design unrelated to upgrade paths, use `contract-architecture`.
- **Migration planning** — If the user needs to migrate state from an old contract to a new one (not a proxy upgrade), use `migration-and-backward-compatibility`.
- **Simple contract changes** — If the user wants to tweak a single function without affecting storage, a direct redeploy or `solidity-authoring` edit is more appropriate.
- **Diamond (EIP-2535) exploration** — If the user is unfamiliar with upgrade patterns and just exploring, route to `contract-architecture` for a broader design discussion first.

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

- **Query:** "Set up a UUPS proxy for my staking contract on Pharos" → **Action:** Generate UUPS proxy + implementation v1, add initializable pattern with `__Staking_init`, configure proxy admin owner, write upgrade script with `upgradeTo` call.
- **Query:** "Design a Beacon proxy pattern for multiple token contracts" → **Action:** Deploy Beacon contract, implement token implementations (v1, v2) pointing to Beacon, generate multi-sig controller for Beacon upgrade, document storage gap recommendations.
- **Query:** "Plan a safe upgrade with storage gap and multi-sig ownership" → **Action:** Audit existing storage layout, propose v2 storage with gaps at explicit slots, generate Safe transaction for proxy admin transfer, write timelock delay between proposal and execution.
- **Query:** "Transfer proxy admin to a Pharos Safe multi-sig" → **Action:** Generate `transferOwnership` calldata to Pharos Safe (`0x41675C099F32341bf84BFc5382aF534df5C7461a`), prepare Safe transaction batch, test on testnet before mainnet.
- **Query:** "Add a timelock between upgrade proposal and execution" → **Action:** Integrate `TimelockController` between proxy admin and multi-sig, configure delay (e.g., 48h), generate `schedule` + `execute` flow, document cancellation roles.

## Verification

Deploy proxy + v1 on testnet, initialize, verify state. Deploy v2, upgrade via proxy admin, verify state preserved and new functions work. Run `forge inspect` for storage layout compatibility.

## Related

contract-architecture (design), migration-and-backward-compatibility (migration path), security-audit (proxy security review)
