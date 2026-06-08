---
name: pharos-protocol-integration-planning
description: Plan protocol read/write call sequences, token approvals, and integration flows. Use when the user says: integration, protocol flow, call sequence, approval flow, contract interaction.
---

# Protocol Integration Planning

Use when the user needs a call sequence or integration plan for a protocol or contract surface.

## Workflow

1. Identify the target, wallet flow, and data dependencies.
2. Sequence the reads, approvals, writes, and fallback paths.
3. Call out error handling, retries, and user-facing states.
4. Present the full integration plan before implementation.

## Output

- call sequence
- approval flow
- error paths
- integration checklist

## Gate

High risk. Do not implement protocol wiring before approval.
