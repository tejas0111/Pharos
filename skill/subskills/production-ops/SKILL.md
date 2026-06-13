---
name: pharos-production-ops
description: "Plan and manage Pharos contract production operations: monitoring (Forta/Tenderly), alerting, incident response (Zeroshadow), multi-sig operations, emergency pause, data recovery, RPC rate limits (eth_getLogs: 100 blocks, trace_filter: 500 block limit). Use when the user says: production ops, monitoring, alerting, incident response, emergency, pause, circuit breaker, multi-sig operations, recovery, data backup, RPC rate limit, rate limiting, Forta, Tenderly, Zeroshadow, operational security, production readiness, maintenance, observability, sentry, oncall. Do NOT use for: deployment (use deployment-and-verification or deploy-suite), contract authoring (use solidity-authoring), or security auditing (use security-audit). See also: deployment-and-verification (post-deploy setup), security-audit (threat model), upgrade-patterns (emergency upgrade path)."
---

# Production Operations

Plan and manage Pharos contract production operations: monitoring (Forta/Tenderly), alerting, incident response (Zeroshadow), multi-sig operations, emergency pause, data recovery.

## When to Use

production ops, monitoring, alerting, incident response, emergency, pause, circuit breaker, multi-sig operations, recovery, data backup, RPC rate limit, rate limiting, Forta, Tenderly, Zeroshadow, operational security, production readiness, maintenance, observability, sentry, oncall

## When NOT to Use

deployment (use deployment-and-verification or deploy-suite), contract authoring (use solidity-authoring), or security auditing (use security-audit)

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

- "Set up Forta monitoring for my Pharos staking contract"
- "Create a Tenderly alert for large withdrawals from the vault"
- "Design the emergency pause mechanism for the lending protocol"
- "Write incident response runbook for Zeroshadow integration"
- "Plan around Pharos RPC rate limits for indexer"

## Verification

Test alert triggers on testnet. Verify emergency pause works end-to-end. Dry-run multi-sig transaction on testnet Safe.

## Related

deployment-and-verification (post-deploy setup), security-audit (threat model), upgrade-patterns (emergency upgrade path)
