---
name: pharos-contract-review
description: "Review Pharos Solidity contracts for correctness, security, gas efficiency, and design issues. Use when auditing, reviewing, or checking Pharos smart contracts for vulnerabilities, gas optimization opportunities, or design flaws before deployment. Keywords: review contract, audit, security review, Solidity review, gas review, check contract, security audit, slither, solhint, Pharos, PHRS, DeFi, RealFi, ERC-20, ERC-721, ERC-1155, staking, vault, AMM, lending."
metadata:
  audience: developer
  version: 1.2.0
  category: contract
slash: true
---

# Contract Review

Review Solidity code for correctness, security, gas, and design issues on Pharos mainnet (chain 1672).

## Pharos-Specific Review Checklist

### ⚠️ Critical — PHRS Gas Stipend

PHRS has **no 2300 gas stipend** on `.call{value:}` — full gas is forwarded.
- [ ] All `.call{value:}` statements include a `gas` limit (recommended: 10,000)
- [ ] Pull-over-push pattern used for withdrawals
- [ ] Unstake/withdraw functions are not in loops

### Severity Rubric

| Severity | Definition | Example |
|----------|------------|---------|
| **Critical** | Loss of funds, permanent brick | Missing gas cap on PHRS `.call`, uninitialized UUPS |
| **High** | Broken invariant, locked funds | Wrong chain ID, missing access control |
| **Medium** | Unexpected behavior under edge case | Storage gap in wrong position, missing event |
| **Low** | Informational, gas inefficiency | Unused import, non-optimal packing |
| **Gas** | Optimization opportunity | Redundant SLOAD, unbounded loop |

### Chain ID Validation

- [ ] Constructor or initializer checks `block.chainid == 1672` (mainnet) or `688689` (testnet)
- [ ] Deploy script validates chain ID before broadcast
- [ ] No hardcoded deprecated chain ID (688688) — current Atlantic testnet is 688689

### UUPS / Upgradeable Storage Collision

- [ ] Contract has `uint256[50] private __gap` as last state variable
- [ ] ERC-7201 namespace used for versioned storage (`@custom:storage-location`)
- [ ] `_authorizeUpgrade(address)` implemented with `onlyOwner`
- [ ] Proxy admin is a multi-sig (Pharos Safe)
- [ ] Storage layout verified: `forge inspect Contract storage-layout`

### Access Control

- [ ] Critical functions guarded by `onlyOwner` or role-based access
- [ ] Owner is a multi-sig (Pharos Safe: `0x41675C099F32341bf84BFc5382aF534df5C7461a`)
- [ ] `renounceOwnership()` is overridden to disallow or warn
- [ ] Proxy upgrade authority is timelocked (>2 days)

### Automated Tools

```bash
# Static analysis
slither --rpc-url $PHAROS_MAINNET_RPC_URL src/Contract.sol

# Storage layout check
forge inspect Contract storage-layout --via-ir

# Gas report
forge snapshot --gas-report --fork-url $PHAROS_MAINNET_RPC_URL
```

## When to Use

review contract, audit, security review, Solidity review, gas review, check this contract, look for bugs, security audit

## When NOT to Use

fixing specific bugs (use bug-finding-and-debugging), writing new code (use solidity-authoring), or automated analysis (use forge test or slither directly)

## Prerequisites
- **Security**:
    - **.env Usage**: Environment variables MUST be stored in a `.env` file in the project root. NEVER use `export VAR=...` for sensitive data.
    - **Mandatory Check**: The Agent MUST verify `.env` exists and variables are set using `grep -q` (NEVER `cat`, `head`, `tail` — those expose secrets) before any deployment or on-chain action.
    - **Git**: Ensure `.env` is listed in `.gitignore` to prevent accidental commits.

- **Foundry**: `forge build` must succeed. Run `forge --version` to verify installation.
- **RPC endpoint**: Set `PHAROS_TESTNET_RPC=$PHAROS_TESTNET_RPC_URL` or `PHAROS_MAINNET_RPC=$PHAROS_MAINNET_RPC_URL` in your environment or `.env`.
- **PharosScan API key**: Set `PHAROSSCAN_API_KEY` for contract verification (https://www.pharosscan.xyz).
- **Network reachability**: Run `cast chain-id --rpc-url $RPC_URL` to confirm the target network is reachable.
- **Foundry config**: `foundry.toml` should have `[rpc_endpoints]` section with `pharos_testnet` and `pharos_mainnet` entries.
## Workflow
- **Strict .env Check**: Confirm `.env` exists with `test -f .env` and check variables via `grep -q` (without printing values). NEVER print `.env` contents. Do NOT proceed if missing or if the user suggests `export`.

1. **Requirement Gathering**: Analyze the user's request to identify the specific task, target environment (Atlantic 688689 or Pacific 1672), and any missing context. Zero-assumption delivery.
2. **Mandatory Plan (`PLAN.md`)**: Create or update `PLAN.md` in the project root with the proposed strategy. **Wait for explicit 'Approve' or 'Proceed' from the user before taking any action.**
3. Read the contract surface and identify the trust boundaries.
4. Check prerequisites: verify Foundry is installed, RPC endpoints are reachable, and required env vars are set. Ask the user for any missing values before proceeding.
5. Look for access-control issues, invariants, and unsafe assumptions.
6. Summarize findings with severity and evidence.
7. Present the review and ask whether to patch the issues.
## Output

- findings list
- severity assessment
- evidence notes
- patch priorities

## Examples

- "Review this Pharos staking contract for PHRS gas stipend issues and chain ID validation on mainnet 1672"
- "Audit this UUPS upgradeable vault for storage collision risks on Pharos mainnet"
- "Check this Pharos ERC-20 contract for reentrancy and access control using forge inspect and slither"
- "Review the proxy upgrade path — is the admin a Pharos Safe multi-sig?"
- "Audit this mint function for supply bugs and PHRS transfer safety"

## Verification

Manual review only. Run `slither --rpc-url $PHAROS_MAINNET_RPC_URL` and `forge inspect storage-layout` for automated checks.

## Related

bug-finding-and-debugging (fixing issues), solidity-authoring (patching), security-audit (formal audit), performance-optimization (gas review)

## Gate

High risk — two-phase execution required:

**Phase 1 — Plan (present freely):**
- Draft the `PLAN.md` with the full implementation strategy, environment-aware safeguards, and verification steps.
- Present the full findings report with severity breakdown, evidence, and fix recommendations — show everything in your response
- Wait for explicit 'Approve' or 'Proceed' from the user.

**Phase 2 — Execute (wait for approval):**
- Execute the approved plan from `PLAN.md`.
- Do NOT Patch findings, modify contract code, or implement fixes
- Perform a final "Ready to Broadcast?" check for any high-risk on-chain actions.
- Wait for explicit user confirmation ("I approve", "proceed", "looks good") before taking any of the Phase 2 actions.