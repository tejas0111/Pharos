---
name: pharos-protocol-integration-planning
description: "Plan Pharos protocol read/write flows, approvals, and call order for integrating contract surfaces. Use when planning integration, protocol flow, call sequences, approval flows, or transaction plans for Pharos DeFi/RealFi protocols, staking, AMM, or lending systems. Keywords: integration, protocol flow, call sequence, approval flow, contract interaction, read/write flow, Pharos, DeFi, RealFi, staking, AMM, lending, PHRS, transaction planning."
metadata:
  audience: developer
  version: 1.2.0
  category: contract
slash: true
---

# Protocol Integration Planning

Plan read/write flows, approvals, and call order for integrating a protocol or contract surface on Pharos mainnet (chain 1672, native currency PROS).

## Pharos Integration Patterns

### Price Oracle Integration (Supra DORA / Chainlink)

```solidity
// Interface for Pharos oracle feed
interface IPharosPriceFeed {
    function latestAnswer() external view returns (int256);
    function latestTimestamp() external view returns (uint256);
    function decimals() external view returns (uint8);
}

// Staleness check given Pharos ~2s block time
function getPrice(IPharosPriceFeed feed) internal view returns (uint256) {
    (uint80 roundId, int256 answer, , uint256 updatedAt, ) = feed.latestRoundData();
    require(block.timestamp - updatedAt < 30 seconds, "Stale price on Pharos");
    require(answer > 0, "Invalid price");
    return uint256(answer);
}
```

### PHRS Staking Integration Flow

```
1. Check user PROS balance (useBalance / getBalance)
2. Approve spending if ERC-20 (skip for native PROS)
3. Estimate gas: cast gas-estimate --rpc-url $PHAROS_MAINNET_RPC_URL
4. Execute stake() with msg.value in PROS
5. Wait for receipt (Pharos ~2s block time → poll every 1s)
6. Confirm state: call stakes(user) to verify
7. Emit/display PharosScan link: https://www.pharosscan.xyz/tx/{hash}
```

### Call Order for DeFi Integration on Pharos

```solidity
// 1. Approve (ERC-20) — if not native PROS
IERC20(token).approve(spender, amount);
// 2. Check allowance
require(IERC20(token).allowance(msg.sender, spender) >= amount);
// 3. Estimate total gas
uint256 gasEstimate = gasleft();
// 4. Execute swap/deposit
pool.deposit(amount);
// 5. Verify state change
require(pool.balanceOf(msg.sender) > 0);
// 6. Extract events from receipt
// 7. Link to PharosScan
```

### Error Paths on Pharos

| Error | Cause | Recovery |
|-------|-------|----------|
| "PhrsTransferFailed" | PHRS .call without gas cap | Retry with capped gas (10,000) |
| "WrongChain" | Wallet on wrong network | Switch MetaMask to 1672 |
| "gas required exceeds allowance" | Gas estimate too low | Increase gas limit |
| "Nonce too low" | Stuck pending tx | Reset MetaMask activity

## When to Use

integration, protocol flow, call sequence, approval flow, contract interaction plan, how to call, what transactions, read/write flow

## When NOT to Use

writing the actual integration code (use frontend-dapp-integration or solidity-authoring), or reviewing existing integrations (use contract-review)

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
3. Identify the integration target, wallet flow, and data dependencies.
4. Check prerequisites: verify Foundry is installed, RPC endpoints are reachable, and required env vars are set. Ask the user for any missing values before proceeding.
5. Sequence the reads, approvals, writes, and fallback paths.
6. Call out error handling, retries, and user-facing states.
7. Present the full integration plan before implementation.
## Output

- call sequence
- approval flow
- error paths
- integration checklist

## Examples

- "Plan the PHRS staking integration flow for a Pharos dashboard — approve, estimate gas, stake, confirm tx on PharosScan"
- "Map the call sequence for a Pharos lending protocol deposit with oracle price check"
- "Design the approval and read flow for a Pharos DEX swap with Supra DORA oracle"
- "Plan a multi-step DeFi integration on Pharos mainnet 1672 with error recovery paths"
- "Sequence the read/write calls for integrating a Pharos staking contract into a frontend"

## Verification

Manual review of the call sequence. Dry-run against testnet 688689: `cast estimate` then `cast send` on testnet first.

## Related

frontend-dapp-integration (UI wiring), solidity-authoring (contract changes), wallet-and-transaction-ui (user-facing states)

## Gate

High risk — two-phase execution required:

**Phase 1 — Plan (present freely):**
- Draft the `PLAN.md` with the full implementation strategy, environment-aware safeguards, and verification steps.
- Wait for explicit 'Approve' or 'Proceed' from the user.

**Phase 2 — Execute (wait for approval):**
- Execute the approved plan from `PLAN.md`.
- Do NOT Implement protocol wiring, approve token defaults, create transaction batching, or write integration code
- Perform a final "Ready to Broadcast?" check for any high-risk on-chain actions.
- Wait for explicit user confirmation ("I approve", "proceed", "looks good") before taking any of the Phase 2 actions.