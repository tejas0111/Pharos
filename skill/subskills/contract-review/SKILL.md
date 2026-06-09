---
name: pharos-contract-review
description: "Review Pharos Solidity contracts for correctness, security, gas efficiency, and design issues. Use when auditing, reviewing, or checking Pharos smart contracts for vulnerabilities, gas optimization opportunities, or design flaws before deployment. Keywords: review contract, audit, security review, Solidity review, gas review, check contract, security audit, slither, solhint, Pharos, PHRS, DeFi, RealFi, ERC-20, ERC-721, ERC-1155, staking, vault, AMM, lending."
metadata:
  audience: developer
  version: 1.1.0
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
- [ ] No hardcoded old Atlantic chain ID (688689)

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
slither --rpc-url https://rpc.pharos.xyz src/Contract.sol

# Storage layout check
forge inspect Contract storage-layout --via-ir

# Gas report
forge snapshot --gas-report --fork-url https://rpc.pharos.xyz
```

## When to Use

review contract, audit, security review, Solidity review, gas review, check this contract, look for bugs, security audit

## When NOT to Use

fixing specific bugs (use bug-finding-and-debugging), writing new code (use solidity-authoring), or automated analysis (use forge test or slither directly)

## Prerequisites
- **Gate Fix**: Perform the mandatory "Gate Fix" check before proceeding.
- **Security**: private keys must be stored in `.env` and accessed via `${PRIVATE_KEY}`.

- **Foundry**: `forge build` must succeed. Run `forge --version` to verify installation.
- **RPC endpoint**: Set `PHAROS_TESTNET_RPC=https://atlantic.dplabs-internal.com` or `PHAROS_MAINNET_RPC=https://rpc.pharos.xyz` in your environment or `.env`.
- **Private key**: Set `PRIVATE_KEY` environment variable (keep this secret, never commit).
- **PharosScan API key**: Set `PHAROSSCAN_API_KEY` for contract verification (https://pharosscan.xyz).
- **Network reachability**: Run `cast chain-id --rpc-url $RPC_URL` to confirm the target network is reachable.
- **Foundry config**: `foundry.toml` should have `[rpc_endpoints]` section with `pharos_testnet` and `pharos_mainnet` entries.

## Workflow

1. Read the contract surface and identify the trust boundaries.
2. Check prerequisites: verify Foundry is installed, RPC endpoints are reachable, and required env vars are set. Ask the user for any missing values before proceeding.
3. Look for access-control issues, invariants, and unsafe assumptions.
4. Summarize findings with severity and evidence.
5. Present the review and ask whether to patch the issues.

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

Manual review only. Run `slither --rpc-url https://rpc.pharos.xyz` and `forge inspect storage-layout` for automated checks.

## Related

bug-finding-and-debugging (fixing issues), solidity-authoring (patching), security-audit (formal audit), performance-optimization (gas review)

## Gate

High risk — two-phase execution required:

**Phase 1 — Plan (present freely):**
- Present the full findings report with severity breakdown, evidence, and fix recommendations — show everything in your response
- Do NOT wait for approval to draft — show everything in your response before asking for confirmation

**Phase 2 — Execute (wait for approval):**
- Do NOT Patch findings, modify contract code, or implement fixes
- Wait for explicit user confirmation ("I approve", "proceed", "looks good") before taking any of the Phase 2 actions