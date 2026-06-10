---
name: pharos-contract-architecture
description: "Design Pharos contract modules, storage layout, access control, and upgrade boundaries before code is written. Use when planning system design, module boundaries, storage layout, access control, upgradeability patterns (UUPS/transparent proxies), or contract architecture for Pharos (mainnet 1672 / testnet 688689). Keywords: contract architecture, system design, module boundaries, storage layout, access control, upgradeability, UUPS, transparent proxy, Solidity, Pharos, PHRS, DeFi, RealFi, staking, vault, AMM, lending, tokenomics."
metadata:
  audience: developer
  version: 1.2.0
  category: contract
slash: true
---

# Contract Architecture

Design contract modules, storage layout, access control, and upgrade boundaries before code is written, targeting Pharos mainnet (chain ID 1672, RPC $PHAROS_MAINNET_RPC_URL) with PHRS native currency (18 decimals).

## Pharos-Specific Architecture Patterns

### Mermaid Architecture Diagram — Staking + Rewards + Token

```mermaid
graph TD
    subgraph User
        A[EOA / Pharos Safe]
    end
    subgraph Pharos Mainnet (1672)
        B[PHRS Staking Pool]
        C[Reward Distributor]
        D[Governance Token]
        E[Timelock Controller]
        F[UUPS Proxy Admin]
    end
    A -- stake/unstake PHRS --> B
    B -- reward accounting --> C
    C -- distribute --> D
    A -- propose/execute --> E
    E -- upgrade --> F
    F -- delegatecall --> B
    F -- delegatecall --> C
    F -- delegatecall --> D
```

### UUPS Upgrade Storage Layout

```solidity
// v1 — Pharos Staking Pool
contract StakingPoolV1 is Initializable, UUPSUpgradeable, OwnableUpgradeable {
    /// @custom:storage-location erc7201:pharos.staking.v1
    struct StakingStorageV1 {
        mapping(address => uint256) stakes;
        uint256 totalStaked;
        uint256 rewardRate; // PHRS per second
    }
    // ... v1 implementation
}

// v2 — add lock period
contract StakingPoolV2 is StakingPoolV1 {
    /// @custom:storage-location erc7201:pharos.staking.v2
    struct StakingStorageV2 {
        mapping(address => uint256) lockEnd;
    }
    // ... v2 implementation
}
```

Verify storage layout with Foundry:
```bash
forge inspect StakingPoolV1 storage-layout
forge inspect StakingPoolV2 storage-layout --via-ir
```

### Access Control Matrix (Pharos Safe Integration)

| Role | Contract | Action | Threshold |
|------|----------|--------|-----------|
| User | StakingPool | stake, unstake | single EOA |
| Owner | TimelockController | upgrade proxy | 2/3 Safe signers |
| Owner | TimelockController | set reward rate | 2/3 Safe signers |
| Pauser | StakingPool | pause, unpause | 1/2 Safe signers |

Pharos Safe master copy: `0x41675C099F32341bf84BFc5382aF534df5C7461a`
Pharos Proxy Factory: `0x4e1DCf7AD4e460CfD30791CCC4F9c8a4f820ec67`

### Concrete Architecture Flow — PHRS DeFi Protocol

```
Pharos Mainnet (1672)
├── StakingPool (UUPS)
│   ├── stake() — receive PHRS
│   ├── unstake() — pull-over-push with gas cap
│   └── getReward() — claim PHRS rewards
├── RewardDistributor (UUPS)
│   ├── notifyRewardAmount() — owner only
│   └── earned(address) — view
├── GovernanceToken (ERC-20)
│   ├── mint() — timelock only
│   └── delegate() — voting
├── TimelockController
│   └── minDelay = 2 days
└── PharosSafe (2/3 multi-sig)
    └── owner of TimelockController
```

## When to Use

system design, module boundaries, storage layout, access control, upgradeability, contract architecture, how should I structure, design the architecture

## When NOT to Use

writing concrete Solidity (use solidity-authoring), reviewing existing code (use contract-review), or deploying (use deployment-and-verification)

## Prerequisites
- **Gate Fix**: Perform the mandatory "Gate Fix" check before proceeding.
- **Security**:
    - **.env Usage**: Environment variables MUST be stored in a `.env` file in the project root. NEVER use `export VAR=...` for sensitive data.
    - **Mandatory Check**: The Agent MUST check for the existence of `.env` and valid values (especially `PRIVATE_KEY` and `PHAROSSCAN_API_KEY`) before attempting any deployment or on-chain action.
    - **Git**: Ensure `.env` is listed in `.gitignore` to prevent accidental commits.

- **Foundry**: `forge build` must succeed. Run `forge --version` to verify installation.
- **RPC endpoint**: Set `PHAROS_TESTNET_RPC=$PHAROS_TESTNET_RPC_URL` or `PHAROS_MAINNET_RPC=$PHAROS_MAINNET_RPC_URL` in your environment or `.env`.
- **PharosScan API key**: Set `PHAROSSCAN_API_KEY` for contract verification (https://www.pharosscan.xyz).
- **Network reachability**: Run `cast chain-id --rpc-url $RPC_URL` to confirm the target network is reachable.
- **Foundry config**: `foundry.toml` should have `[rpc_endpoints]` section with `pharos_testnet` and `pharos_mainnet` entries.
## Workflow
- **Strict .env Check**: Verify `.env` exists in project root and contains `PRIVATE_KEY`, `PHAROSSCAN_API_KEY`, and required RPC URLs. Do NOT proceed if missing or if the user suggests using `export`.

1. **Requirement Gathering**: Analyze the user's request to identify the specific task, target environment (Atlantic 688689 or Pacific 1672), and any missing context. Zero-assumption delivery.
2. **Mandatory Plan (`PLAN.md`)**: Create or update `PLAN.md` in the project root with the proposed strategy. **Wait for explicit 'Approve' or 'Proceed' from the user before taking any action.**
3. Clarify the product goal, trust model, and onchain constraints.
4. Check prerequisites: verify Foundry is installed, RPC endpoints are reachable, and required env vars are set. Ask the user for any missing values before proceeding.
5. Split the system into modules, interfaces, and storage responsibilities.
6. Identify upgrade, ownership, and permission decisions explicitly.
7. Present the architecture and ask for approval before implementation.
8. Include Pharos-specific address references (Safe, ProxyFactory) and PHRS gas stipend warnings.
## Output

- module map
- storage plan
- access-control plan
- risk notes
- next implementation step

## Examples

- "Design the architecture for a PHRS staking protocol on Pharos mainnet (1672) with UUPS and Safe multi-sig"
- "Propose the storage and access model for a Pharos DeFi vault with reward distribution"
- "Plan the upgrade path from StakingPoolV1 to V2 with ERC-7201 storage layout"
- "Design the module boundaries for a governance token with timelock on Pharos"

## Verification

Review the architecture against requirements. Run `forge inspect` to verify storage layout compatibility. No code to compile yet at architecture stage.

## Related

solidity-authoring (implementation), interface-abi-design (surface), migration-and-backward-compatibility (upgrade path)

## Gate

High risk — two-phase execution required:

**Phase 1 — Plan (present freely):**
- Draft the `PLAN.md` with the full implementation strategy, environment-aware safeguards, and verification steps.
- Wait for explicit 'Approve' or 'Proceed' from the user.

**Phase 2 — Execute (wait for approval):**
- Execute the approved plan from `PLAN.md`.
- Do NOT Write contract code, modify files, or generate implementation
- Perform a final "Ready to Broadcast?" check for any high-risk on-chain actions.
- Wait for explicit user confirmation ("I approve", "proceed", "looks good") before taking any of the Phase 2 actions.