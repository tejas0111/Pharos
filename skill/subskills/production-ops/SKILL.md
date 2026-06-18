---
name: pharos-production-ops
description: "Plan and manage Pharos contract production operations: Forta bot setup monitoring Pharos RPC, Tenderly integration with Pharos mainnet, alert thresholds (PROS balance < 0.1, gas > 100 gwei, failed tx rate > 5%), emergency pause via multi-sig on Pharos, chain reorg handling (Pharos finality ~12 blocks), RPC failover, data recovery via PharosScan API. Use when setting up monitoring, incident response, or production ops for Pharos contracts. Keywords: production ops, monitoring, alerting, incident response, emergency, pause, circuit breaker, multi-sig operations, recovery, data backup, RPC rate limit, rate limiting, Forta, Tenderly, Zeroshadow, operational security, production readiness, maintenance, observability, sentry, oncall, Pharos mainnet, PharosScan."
metadata:
  audience: developer
  version: 1.2.0
  category: operations
slash: true
---

# Production Operations

Plan and manage Pharos contract production operations on Pharos mainnet (chain ID 1672): Forta bot setup monitoring Pharos RPC, Tenderly integration with Pharos mainnet, alert thresholds (PROS balance < 0.1, gas > 100 gwei, failed tx rate > 5%), emergency pause via multi-sig on Pharos, chain reorg handling (Pharos finality ~12 blocks), RPC failover, data recovery via PharosScan API.

## When to Use

production ops, monitoring, alerting, incident response, emergency, pause, circuit breaker, multi-sig operations, recovery, data backup, RPC rate limit, rate limiting, Forta, Tenderly, Zeroshadow, operational security, production readiness, maintenance, observability, sentry, oncall, chain ID 1672, Pharos mainnet, PharosScan

## When NOT to Use

- **Deployment** — If the user needs to broadcast a transaction or simulate deployment, use `deployment-and-verification` or `deployment-for-testnet-and-mainnet`.
- **Contract authoring** — If the user is writing or modifying contract code, use `solidity-authoring`.
- **Security auditing** — If the user wants a formal vulnerability assessment with findings report, use `security-audit`.
- **One-time setup without ongoing ops** — If the user just needs to deploy a contract and walk away (no monitoring, no incident response), use `deployment-and-verification` plus `post-deploy`.
- **Frontend monitoring UI** — If the user wants to build a custom monitoring dashboard (not configure Forta/Tenderly), use `frontend-dapp-integration`.

## Prerequisites
- **Security**:
    - **.env Usage**: Environment variables MUST be stored in a `.env` file in the project root. NEVER use `export VAR=...` for sensitive data.
    - **Mandatory Check**: The Agent MUST verify `.env` exists and variables are set using `grep -q` (NEVER `cat`, `head`, `tail` — those expose secrets) before any deployment or on-chain action.
    - **Git**: Ensure `.env` is listed in `.gitignore` to prevent accidental commits.

- **Git repository**: `git status` must succeed (run from repo root).
- **CI platform**: GitHub Actions configured (check `.github/workflows/` exists).
- **Foundry** (if workflows include forge commands): `forge build` must succeed.
## Workflow
- **Strict .env Check**: Confirm `.env` exists with `test -f .env` and check variables via `grep -q` (without printing values). NEVER print `.env` contents. Do NOT proceed if missing or if the user suggests `export`.

1. **Requirement Gathering**: Analyze the user's request to identify the specific task, target environment (Atlantic 688689 or Pacific 1672), and any missing context. Zero-assumption delivery.
2. **Mandatory Plan (`PLAN.md`)**: Create or update `PLAN.md` in the project root with the proposed strategy. **Wait for explicit 'Approve' or 'Proceed' from the user before taking any action.**
3. Check prerequisites: verify required tools are installed, env vars are set, and any required context is available. Ask the user for any missing values before proceeding.
4. Show the plan and ask for approval before implementing.
### 1. Forta Bot — Pharos Mainnet

```typescript
// agent/src/agent.ts — Forta detection bot for Pharos contract
import { Finding, FindingSeverity, FindingType, HandleTransaction } from "forta-agent";
import { ethers } from "ethers";

const CONTRACT_ADDRESS = "0x1234...abcd"; // deployed Pharos contract
const PHAROS_RPC = "$PHAROS_MAINNET_RPC_URL";
const provider = new ethers.JsonRpcProvider(PHAROS_RPC, 1672);

export const provideHandleTransaction = (): HandleTransaction => async (txEvent) => {
  const findings: Finding[] = [];
  if (txEvent.to !== CONTRACT_ADDRESS) return findings;

  // Monitor PROS transfers over threshold
  const phrsTransfers = txEvent.filterLog("Transfer(address,address,uint256)");
  for (const transfer of phrsTransfers) {
    if (transfer.args.value.gt(ethers.parseEther("100000"))) {
      findings.push(Finding.fromObject({
        name: "Large PROS Transfer",
        description: `${ethers.formatEther(transfer.args.value)} PROS transferred`,
        alertId: "PHAROS-LARGE-TRANSFER",
        severity: FindingSeverity.High,
        type: FindingType.Suspicious,
      }));
    }
  }
  return findings;
};
```

Test locally: `npx forta-agent run --json-rpc $PHAROS_MAINNET_RPC_URL`.

### 2. Tenderly Web3 Action — Pharos Mainnet

```typescript
// Web3 Action monitoring Pharos contract events
module.exports = async (event: any) => {
  const tx = event.transaction;
  const receipt = event.receipt;
  const logs = receipt.logs.filter((l: any) => l.address.toLowerCase() === CONTRACT_ADDRESS);
  if (logs.length === 0) return;

  for (const log of logs) {
    if (log.topics[0] === ethers.id("Paused()")) {
      await sendAlert({ message: `⚠️ Pharos contract paused at ${tx.hash}`, severity: "critical" });
    }
    if (log.topics[0] === ethers.id("OwnershipTransferred(address,address)")) {
      await sendAlert({ message: `🔑 Ownership changed on Pharos contract`, severity: "high" });
    }
  }
};
```

### 3. Alert Thresholds

- PROS wallet balance < 0.1 (mainnet deployer)
- Gas price spike > 100 gwei (above Pharos typical 1-10 gwei base fee)
- Failed transaction rate > 5% over 1 hour
- Large transfers > 100,000 PROS (native) or > 100,000 PROS in ERC-20
- Ownership changes, pause/unpause events, proxy upgrades

### 4. Incident Response Runbook

Establish via Zeroshadow: detection → triage → containment (emergency pause) → recovery → post-mortem. Include Pharos-specific handling: chain reorg detection (Pharos finality ~12 blocks, monitor for uncle blocks), RPC failover between `$PHAROS_MAINNET_RPC_URL` and backup endpoints.

### 5. Emergency Pause

Multi-sig operations using Pharos Safe (master copy: 0x41675C099F32341bf84BFc5382aF534df5C7461a) with threshold signing. Emergency pause:

```bash
cast send --rpc-url $PHAROS_MAINNET_RPC_URL --chain-id 1672 $CONTRACT "pause()" --private-key $SIGNER_KEY
```

For testnet testing:
```bash
cast send --rpc-url $PHAROS_TESTNET_RPC_URL --chain-id 688689 $CONTRACT "pause()" --private-key $TEST_KEY
```

### 6. Data Recovery via PharosScan API

Fetch historical events from old contract:

```bash
curl -X POST "https://api.www.pharosscan.xyz/pharos-mainnet/v1/explorer/command_api/account_tx" \
  -H "Content-Type: application/json" \
  -d '{"address": "0x1234...abcd", "page": 1, "offset": 50}'
```

Replay events on new contract using recovered data. Document RPC rate limits: `eth_getLogs` limited to 100 block range, `trace_filter` limited to 500 blocks.

## Output

- Forta bot config monitoring Pharos RPC
- Tenderly project configured with Pharos mainnet RPC
- alert threshold config (PROS balance, gas price, failed tx rate, large transfers)
- incident response runbook with Pharos reorg handling and RPC failover
- emergency pause command and multi-sig operations guide
- PharosScan API data recovery procedure
- RPC rate limit cheat sheet

## Examples

- **Query:** "Set up Forta monitoring for my Pharos staking contract" → **Action:** Deploy Forta detection bot monitoring Pharos RPC with detection logic for stake/unstake events, large delegation changes, ownership transfers; configure alert severity levels and notification channels.
- **Query:** "Create a Tenderly alert for large withdrawals from the vault on Pharos" → **Action:** Configure Tenderly project with Pharos mainnet RPC ($PHAROS_MAINNET_RPC_URL), create Web3 Action monitoring vault `Withdraw` events above threshold (e.g., 10,000 PROS), set up Slack/email notification, test with simulated transaction.
- **Query:** "Design the emergency pause mechanism for the lending protocol on Pharos" → **Action:** Implement `Pausable` with pause guardian role (multi-sig), emergency pause via `cast send --rpc-url $PHAROS_MAINNET_RPC_URL $CONTRACT "pause()"`, define pause-triggering conditions (oracle deviation, abnormal liquidation volume), write unpause procedure with timelock.
- **Query:** "Write incident response runbook for Zeroshadow with Pharos-specific reorg handling" → **Action:** Document detection → triage → containment (emergency pause) → recovery → post-mortem steps, include Pharos chain reorg detection (finality ~12 blocks), RPC failover between endpoints, assign on-call roles, integrate Zeroshadow alert routing.
- **Query:** "Plan around Pharos RPC rate limits for indexer" → **Action:** Document limits (`eth_getLogs`: 100 blocks, `trace_filter`: 500 blocks), design pagination/backoff strategy, recommend caching layer and WebSocket subscriptions for real-time data.
- **Query:** "Recover historical event data after Pharos contract migration" → **Action:** Use PharosScan API to fetch historical events from old contract, replay events on new contract, verify state consistency across both deployments.

## Verification

Test alert triggers on Pharos testnet. Verify emergency pause works end-to-end via multi-sig. Dry-run multi-sig transaction on testnet Safe. Confirm PharosScan shows verified contract. Validate RPC failover by disconnecting primary endpoint.

## Related

deployment-and-verification (post-deploy setup), security-audit (threat model), upgrade-patterns (emergency upgrade path)


## Gate
Medium risk. Present the monitoring plan and alert thresholds before deploying Forta bots or Tenderly monitors. Do not enable production alerts without user sign-off on severity levels.
