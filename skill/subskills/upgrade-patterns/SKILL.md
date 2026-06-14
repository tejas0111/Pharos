---
name: pharos-upgrade-patterns
description: "Design and implement contract upgrade patterns on Pharos: UUPS, Transparent proxy, Beacon proxy. Covers Pharos-specific UUPS deployment with forge script using Pharos RPC, proxy verification on PharosScan, storage gap recommendation (50 slots for Pharos), timelock governance, and upgrade test on Pharos Atlantic Testnet fork. Use when designing or implementing upgradeable contracts on Pharos. Keywords: upgrade, proxy, UUPS, transparent proxy, beacon proxy, storage collision, upgradeability, proxy pattern, EIP-1967, EIP-1822, EIP-2535, diamond, initializable, reinitializer, storage gap, multi-sig ownership, timelock, Safe, safe wallet, master copy, ownership transfer."
metadata:
  audience: developer
  version: 1.2.0
  category: upgrade
slash: true
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
3. Choose the upgrade pattern based on trust model and gas requirements: UUPS (cheapest deploy, complex logic in implementation), Transparent (simple, higher overhead), Beacon (many proxies, shared logic).
4. Check prerequisites: verify Foundry is installed, RPC endpoints are reachable, and required env vars are set. Ask the user for any missing values before proceeding.
5. Design storage layout with gaps, explicit slots, and append-only patterns. Never reorder or remove existing variables.
6. Present the upgrade plan with storage layout diff, V2 contract code, and access control design, then ask for approval before executing (deploying, upgrading, or sending onchain transactions).
7. Write the proxy and implementation contract code with initializable pattern and access control (Phase 1 — no approval needed to draft).
8. Draft the multi-sig ownership transfer and timelock configuration (Phase 1 — prepare Safe transaction data together with the upgrade plan).
9. After user approves the plan (Phase 2), deploy, upgrade, and verify on testnet: deploy proxy, deploy v2 implementation, call upgradeTo, verify state preservation with forge test fork.
## Output

- proxy contract (UUPS, Transparent, or Beacon)
- implementation contracts (v1, v2 with storage diff)
- upgrade script (Foundry or Hardhat)
- multi-sig ownership transfer transaction data
- storage layout audit report

## Examples

- **Query:** "Set up a UUPS proxy for my Pharos staking contract" → **Action:** Generate UUPS proxy + implementation v1 using Pharos RPC (`https://rpc.pharos.xyz`), add initializable pattern with `__Staking_init` and 50-slot storage gap (`uint256[50] private __gap`), configure proxy admin owner via Pharos Safe (`0x41675C099F32341bf84BFc5382aF534df5C7461a`), write upgrade script with `upgradeTo` call, test on Atlantic Testnet fork (`forge test --fork-url https://atlantic.dplabs-internal.com`), verify both proxy and implementation on PharosScan.
- **Query:** "Design a Beacon proxy pattern for multiple token contracts" → **Action:** Deploy Beacon contract, implement token implementations (v1, v2) pointing to Beacon, generate multi-sig controller for Beacon upgrade, document storage gap recommendations.
- **Query:** "Plan a safe upgrade with storage gap and multi-sig ownership on Pharos" → **Action:** Audit existing storage layout on PharosScan (`https://atlantic.pharosscan.xyz/address/{proxyAddress}?address={implAddress}`), propose v2 storage with 50-slot gap at end of each base contract, generate Safe transaction for proxy admin transfer via Pharos Safe multisig, write timelock delay (48h mainnet, 1h testnet) between proposal and execution, test on Pharos Atlantic Testnet fork.
- **Query:** "Transfer proxy admin to a Pharos Safe multi-sig" → **Action:** Generate `transferOwnership` calldata to Pharos Safe (`0x41675C099F32341bf84BFc5382aF534df5C7461a`), prepare Safe transaction batch, test on testnet before mainnet.
- **Query:** "Add a timelock between upgrade proposal and execution" → **Action:** Integrate `TimelockController` between proxy admin and multi-sig, configure delay (e.g., 48h), generate `schedule` + `execute` flow, document cancellation roles.

## Verification

Deploy proxy + v1 on testnet, initialize, verify state. Deploy v2, upgrade via proxy admin, verify state preserved and new functions work. Run `forge inspect` for storage layout compatibility. Verify both implementation and proxy contracts on PharosScan at `https://atlantic.pharosscan.xyz/address/{contractAddress}?address={implementationAddress}` to confirm proxy pointing to correct logic.

## Pharos-Specific Upgrade Patterns

### UUPS Proxy Deployment on Pharos

Deploy a UUPS proxy on Pharos using Foundry with the Pharos RPC:

```bash
# Deploy implementation
forge create src/MyContractV1.sol:MyContract --rpc-url https://rpc.pharos.xyz --private-key $DEPLOYER_KEY

# Deploy ERC1967Proxy pointing to implementation
forge create lib/openzeppelin-contracts/contracts/proxy/ERC1967/ERC1967Proxy.sol:ERC1967Proxy \
  --rpc-url https://rpc.pharos.xyz \
  --private-key $DEPLOYER_KEY \
  --constructor-args $IMPLEMENTATION_ADDRESS "0x"
```

For testnet, use `--rpc-url https://atlantic.dplabs-internal.com`.

### Proxy Verification on PharosScan

After deployment on Pharos, verify both contracts on PharosScan:

```bash
# Verify implementation
forge verify-contract $IMPLEMENTATION_ADDRESS src/MyContractV1.sol:MyContract \
  --verifier-url https://pharosscan.xyz/api \
  --chain-id 1672 \
  --etherscan-api-key $PHAROSSCAN_API_KEY

# Verify proxy with implementation address parameter
forge verify-contract $PROXY_ADDRESS lib/openzeppelin-contracts/contracts/proxy/ERC1967/ERC1967Proxy.sol:ERC1967Proxy \
  --verifier-url https://pharosscan.xyz/api \
  --chain-id 1672 \
  --etherscan-api-key $PHAROSSCAN_API_KEY \
  --constructor-args $(cast abi-encode "constructor(address,bytes)" $IMPLEMENTATION_ADDRESS "0x")
```

View on PharosScan at `https://pharosscan.xyz/address/{proxyAddress}?address={implementationAddress}` to confirm proxy read/write routes through the implementation.

### Storage Layout for Upgradeable Contracts

Pharos contracts must follow append-only storage patterns to avoid collisions:

- **Storage gap**: Reserve 50 storage slots (`uint256[50] private __gap`) at the end of each base contract. This exceeds the standard OpenZeppelin recommendation of 50 to accommodate Pharos's deeper inheritance trees.
- **Explicit storage slots**: Use `bytes32 private constant _MY_SLOT = keccak256("pharos.my.slot")` for singleton state to bypass linear storage entirely.
- **Never reorder or remove**: Existing variables in v1 must remain at their original slot positions in v2.

### Timelock Contract for Upgrade Governance

The Pharos TimelockController for upgrade governance — deploy your own with the Safe as proposer:

```solidity
TimelockController timelock = new TimelockController(48 hours, [safeAddress], [safeAddress], address(0));
```

Configure with:
- Minimum delay: 48 hours for mainnet, 1 hour for testnet
- Proposer role: Safe multi-sig address
- Executor role: Safe multi-sig address (can be set to `address(0)` for public execution after delay)

### Storage Gap Pattern

Include a 50-slot storage gap in every upgradeable base contract:

```solidity
// Pharos recommendation: 50 storage slots
uint256[50] private __gap;
```

This ensures that adding new state variables in derived contracts during upgrades does not shift storage slots of contracts further down the inheritance chain.

### Upgrade Test on Pharos Atlantic Testnet Fork

Always test upgrades against a Pharos Atlantic Testnet fork before mainnet:

```bash
forge test --fork-url https://atlantic.dplabs-internal.com --match-contract UpgradeTest -vvv
```

Include assertions for:
- Storage slot preservation after upgrade
- New functions in v2 work correctly
- Old functions in v1 remain accessible
- Proxy admin access control enforcement

### Hardhat Upgrade Patterns

For Hardhat-based projects on Pharos:

- Use `@openzeppelin/hardhat-upgrades` with manual multisig upgrade flow
- Deploy with `deployProxy(implFactory, args, { kind: 'uups' })` using Hardhat deploy script pointing to `https://rpc.pharos.xyz`
- Upgrade via multisig: prepare upgrade transaction with `prepareUpgrade(proxyAddress, newImplFactory)`, then execute via Pharos Safe multisig
- Verify on PharosScan using `hardhat-verify` with custom verifier URL `https://pharosscan.xyz/api`

## Related

contract-architecture (design), migration-and-backward-compatibility (migration path), security-audit (proxy security review)


## Gate

High risk — two-phase execution required:

**Phase 1 — Plan (present freely):**
- Draft the `PLAN.md` with the full implementation strategy, environment-aware safeguards, and verification steps.
- Show the exact `forge script` commands (with placeholder address), expected implementation address pattern, and `upgradeTo` calldata structure
- Present the complete upgrade transaction data for user review
- Wait for explicit 'Approve' or 'Proceed' from the user.

**Phase 2 — Execute (wait for approval):**
- Execute the approved plan from `PLAN.md`.
- Do NOT deploy new implementations, change storage layout, call `upgradeTo`, or modify `_authorizeUpgrade`
- Do NOT send any onchain transactions (deploy, verify, proxy upgrade, Safe submission)
- Perform a final "Ready to Broadcast?" check for any high-risk on-chain actions.
- Wait for explicit user confirmation ("I approve", "proceed", "looks good") before taking any of the Phase 2 actions.