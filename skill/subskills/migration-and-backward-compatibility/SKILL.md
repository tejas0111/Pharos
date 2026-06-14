---
name: pharos-migration-and-backward-compatibility
description: "Plan safe Pharos contract migrations, data moves, and compatibility guardrails for upgrades or rewrites. Use when planning migration paths, backward compatibility, contract upgrade strategies, data migration, breaking changes, or version upgrades for Pharos dapps. Keywords: migration, backward compatibility, upgrade path, data move, breaking change, version upgrade, migrate data, safe upgrade, Pharos, Solidity, proxy, UUPS, transparent, contract upgrade, DeFi, RealFi."
metadata:
  audience: developer
  version: 1.2.0
  category: contract
slash: true
---

# Migration and Backward Compatibility

Plan safe migrations, data moves, and compatibility guardrails for upgrades or rewrites on Pharos mainnet (chain 1672).

## Pharos-Specific Migration Patterns

### ERC-7201 Storage Layout Migration (UUPS)

```solidity
// V1 storage — Pharos Staking Pool
/// @custom:storage-location erc7201:pharos.staking.v1
contract StakingPoolV1 is Initializable, UUPSUpgradeable {
    mapping(address => uint256) public stakes;
    uint256 public totalStaked;
    uint256[48] private __gap;
}

// V2 — add lock period WITHOUT corrupting V1 storage
/// @custom:storage-location erc7201:pharos.staking.v2
contract StakingPoolV2 is StakingPoolV1 {
    /// @custom:storage-location erc7201:pharos.staking.v2
    struct StakingStorageV2 {
        mapping(address => uint256) lockEnd;
    }
    // keccak256(abi.encode(uint256(keccak256("pharos.staking.v2")) - 1)) & ~bytes32(uint256(0xff))
    bytes32 private constant V2_STORAGE_LOCATION = 0x...;
    
    function _getV2Storage() private pure returns (StakingStorageV2 storage s) {
        assembly { s.slot := V2_STORAGE_LOCATION }
    }
}
```

Verify no collision:
```bash
forge inspect StakingPoolV1 storage-layout --via-ir > v1.json
forge inspect StakingPoolV2 storage-layout --via-ir > v2.json
diff v1.json v2.json  # Only V2 additions should differ
```

### Migration Test on Testnet

```bash
# 1. Deploy V1 on testnet
forge script script/DeployV1.s.sol --rpc-url pharos_testnet --broadcast
# 2. Upgrade proxy to V2
forge script script/UpgradeToV2.s.sol --rpc-url pharos_testnet --broadcast
# 3. Verify state preserved
cast call --rpc-url https://atlantic.dplabs-internal.com $PROXY "totalStaked()"
# 4. Test new V2 functions
cast send --rpc-url https://atlantic.dplabs-internal.com $PROXY "setLockPeriod(uint256)" 86400
# 5. Confirm on PharosScan
open https://www.pharosscan.xyz/address/$PROXY
```

### Upgrade Test Script

```solidity
// test/UpgradeMigration.t.sol
function test_UpgradePreservesStakes() public {
    vm.createSelectFork("pharos_testnet");
    
    // Record V1 stakes
    address proxy = 0x...;
    StakingPoolV1 v1 = StakingPoolV1(proxy);
    uint256 preStake = v1.stakes(alice);
    
    // Upgrade to V2
    vm.prank(owner);
    StakingPoolV2 v2 = StakingPoolV2(address(proxy));
    // Use UUPS upgrade
    v2.upgradeTo(address(new StakingPoolV2()));
    
    // Verify V1 state preserved in V2
    assertEq(v2.stakes(alice), preStake);
}
```

### Rollback Plan

- Git tag the V1 deployment commit
- Store V1 implementation address for proxy rollback
- Test rollback on testnet first: `cast send $PROXY "upgradeTo(address)" $V1_IMPL`
- If data migration is irreversible (e.g., ERC-7201 moves), deploy new proxy + data migration script instead

## When to Use

migration, backward compatibility, upgrade path, data move, breaking change, version upgrade, migrate data, safe upgrade

## When NOT to Use

writing new code without migration concerns (use solidity-authoring), or deploying the migration (use deployment-and-verification)

## Prerequisites
- **Gate Fix**: Perform the mandatory "Gate Fix" check before proceeding.
- **Security**: Private keys must be stored in `.env` and accessed via `${PRIVATE_KEY}`.

- **Foundry**: `forge build` must succeed. Run `forge --version` to verify installation.
- **RPC endpoint**: Set `PHAROS_TESTNET_RPC=https://atlantic.dplabs-internal.com` or `PHAROS_MAINNET_RPC=https://rpc.pharos.xyz` in your environment or `.env`.
- **PharosScan API key**: Set `PHAROSSCAN_API_KEY` for contract verification (https://www.pharosscan.xyz).
- **Network reachability**: Run `cast chain-id --rpc-url $RPC_URL` to confirm the target network is reachable.
- **Foundry config**: `foundry.toml` should have `[rpc_endpoints]` section with `pharos_testnet` and `pharos_mainnet` entries.
## Workflow

1. **Requirement Gathering**: Analyze the user's request to identify the specific task, target environment (Atlantic 688689 or Pacific 1672), and any missing context. Zero-assumption delivery.
2. **Mandatory Plan (`PLAN.md`)**: Create or update `PLAN.md` in the project root with the proposed strategy. **Wait for explicit 'Approve' or 'Proceed' from the user before taking any action.**
3. Identify the old state, new state, and compatibility boundary.
4. Check prerequisites: verify Foundry is installed, RPC endpoints are reachable, and required env vars are set. Ask the user for any missing values before proceeding.
5. Map the migration path, fallbacks, and rollback assumptions.
6. Present the migration plan and ask for confirmation before changes.
7. Implement the smallest safe migration step after approval.
## Output

- migration plan
- compatibility notes
- rollback plan
- verification checklist

## Examples

- "Migrate Pharos staking V1 to V2 with ERC-7201 storage — test on testnet 688689 first"
- "Plan a UUPS contract upgrade migration without breaking existing PHRS stakes"
- "Design the backward compatibility layer for a Pharos protocol rewrite"
- "Map the data migration path for a PHRS token contract upgrade on mainnet 1672"
- "Write a forge test that upgrades V1→V2 and verifies state preservation"

## Verification

Migration script dry run on testnet (688689). Compatibility test with existing data. `forge inspect storage-layout` comparison before/after. PharosScan verification of upgraded proxy.

## Related

contract-architecture (designing for upgradeability), deployment-and-verification (deploying the migration)

## Gate

High risk — two-phase execution required:

**Phase 1 — Plan (present freely):**
- Draft the `PLAN.md` with the full implementation strategy, environment-aware safeguards, and verification steps.
- Wait for explicit 'Approve' or 'Proceed' from the user.

**Phase 2 — Execute (wait for approval):**
- Execute the approved plan from `PLAN.md`.
- Do NOT Change storage layout, upgrade functions, modify reinitializer logic, or deploy migration contracts
- Perform a final "Ready to Broadcast?" check for any high-risk on-chain actions.
- Wait for explicit user confirmation ("I approve", "proceed", "looks good") before taking any of the Phase 2 actions.