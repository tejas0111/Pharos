---
name: pharos-protocol-integration-planning
description: "Plan Pharos protocol read/write flows, approvals, and call order for integrating contract surfaces. Use when planning integration, protocol flow, call sequences, approval flows, or transaction plans for Pharos DeFi/RealFi protocols, staking, AMM, or lending systems. Keywords: integration, protocol flow, call sequence, approval flow, contract interaction, read/write flow, Pharos, DeFi, RealFi, staking, AMM, lending, PROS, PHRS, transaction planning."
metadata:
  audience: developer
  version: 1.0.0
  category: contract
slash: true
---

# Protocol Integration Planning

Plan read/write flows, approvals, and call order for integrating a protocol or contract surface.

## When to Use

integration, protocol flow, call sequence, approval flow, contract interaction plan, how to call, what transactions, read/write flow

## When NOT to Use

writing the actual integration code (use frontend-dapp-integration or solidity-authoring), or reviewing existing integrations (use contract-review)

## Workflow

1. Identify the integration target, wallet flow, and data dependencies.
2. Sequence the reads, approvals, writes, and fallback paths.
3. Call out error handling, retries, and user-facing states.
4. Present the full integration plan before implementation.

## Output

- call sequence
- approval flow
- error paths
- integration checklist

## Examples

- "Plan the integration flow for a staking dashboard"
- "Map the call sequence for a lending protocol deposit flow"
- "Design the approval and read flow for a token swap UI"

## Verification

Manual review of the call sequence. No code changes.

## Related

frontend-dapp-integration (UI wiring), solidity-authoring (contract changes), wallet-and-transaction-ui (user-facing states)
