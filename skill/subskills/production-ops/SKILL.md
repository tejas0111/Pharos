---
name: pharos-production-ops
description: "Plan and manage Pharos contract production operations: monitoring (Forta/Tenderly), alerting, incident response (Zeroshadow), multi-sig operations, emergency pause, data recovery, RPC rate limits (eth_getLogs: 100 blocks, trace_filter: 500 block limit). Use when. Keywords: production ops, monitoring, alerting, incident response, emergency, pause, circuit breaker, multi-sig operations, recovery, data backup, RPC rate limit, rate limiting, Forta, Tenderly, Zeroshadow, operational security, production readiness, maintenance, observability, sentry, oncall. Do NOT use for: deployment (use deployment-and-verification or deploy-suite), contract authoring (use solidity-authoring), or security auditing (use security-audit). See also: deployment-and-verification (post-deploy setup), security-audit (threat model), upgrade-patterns (emergency upgrade path)."
metadata:
  audience: developer
  version: 1.0.0
  category: operations
slash: true
---

# Production Operations

Plan and manage Pharos contract production operations: monitoring (Forta/Tenderly), alerting, incident response (Zeroshadow), multi-sig operations, emergency pause, data recovery.

## When to Use

production ops, monitoring, alerting, incident response, emergency, pause, circuit breaker, multi-sig operations, recovery, data backup, RPC rate limit, rate limiting, Forta, Tenderly, Zeroshadow, operational security, production readiness, maintenance, observability, sentry, oncall

## When NOT to Use

- **Deployment** — If the user needs to broadcast a transaction or simulate deployment, use `deployment-and-verification` or `deploy-suite`.
- **Contract authoring** — If the user is writing or modifying contract code, use `solidity-authoring`.
- **Security auditing** — If the user wants a formal vulnerability assessment with findings report, use `security-audit`.
- **One-time setup without ongoing ops** — If the user just needs to deploy a contract and walk away (no monitoring, no incident response), use `deployment-and-verification` plus `post-deploy`.
- **Frontend monitoring UI** — If the user wants to build a custom monitoring dashboard (not configure Forta/Tenderly), use `frontend-dapp-integration`.

## Workflow

1. Set up monitoring via Forta agents (on-chain threat detection) and Tenderly (transaction monitoring, alerting, debugging).
2. Configure alerts for: large transfers, ownership changes, pause/unpause events, price oracle deviations, unusual gas spikes.
3. Establish incident response runbook via Zeroshadow: detection → triage → containment (emergency pause) → recovery → post-mortem.
4. Prepare multi-sig operations using Pharos Safe (master copy: 0x41675C099F32341bf84BFc5382aF534df5C7461a) with threshold signing.
5. Implement emergency pause mechanism in contracts with a pause guardian role (multi-sig or time-locked).
6. Document RPC rate limits: eth_getLogs limited to 100 block range, trace_filter limited to 500 blocks. Plan data recovery strategies for off-chain indexed data.

## Output

- monitoring dashboard config (Forta agents, Tenderly alerts)
- incident response runbook (Zeroshadow)
- multi-sig operations guide
- emergency pause plan and contract interface
- RPC rate limit cheat sheet
- data recovery procedure

## Examples

- **Query:** "Set up Forta monitoring for my Pharos staking contract" → **Action:** Deploy Forta agent with detection logic for stake/unstake events, large delegation changes, ownership transfers; configure alert severity levels and notification channels.
- **Query:** "Create a Tenderly alert for large withdrawals from the vault" → **Action:** Configure Tenderly Web3 Actions to monitor vault `Withdraw` events above threshold (e.g., 10k PROS), set up Slack/email notification, test with simulated transaction.
- **Query:** "Design the emergency pause mechanism for the lending protocol" → **Action:** Implement `Pausable` with pause guardian role (multi-sig), define pause-triggering conditions (oracle deviation, abnormal liquidation volume), write unpause procedure with timelock.
- **Query:** "Write incident response runbook for Zeroshadow integration" → **Action:** Document detection → triage → containment (emergency pause) → recovery → post-mortem steps, assign on-call roles, integrate Zeroshadow alert routing.
- **Query:** "Plan around Pharos RPC rate limits for indexer" → **Action:** Document limits (`eth_getLogs`: 100 blocks, `trace_filter`: 500 blocks), design pagination/backoff strategy, recommend caching layer and WebSocket subscriptions for real-time data.

## Verification

Test alert triggers on testnet. Verify emergency pause works end-to-end. Dry-run multi-sig transaction on testnet Safe.

## Related

deployment-and-verification (post-deploy setup), security-audit (threat model), upgrade-patterns (emergency upgrade path)
