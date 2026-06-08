---
name: pharos-contract-review
description: Review Solidity code for security, access control, reentrancy, gas optimization, and design correctness. Use when the user says: review contract, audit, security review, Solidity review, gas review.
---

# Contract Review

Use when the user wants a code review or security pass on Solidity.

## Workflow

1. Read the contract surface and identify the trust boundaries.
2. Look for access-control issues, invariants, and unsafe assumptions.
3. Summarize findings with severity and evidence.
4. Present the review and ask whether to patch the issues.

## Output

- findings list
- severity assessment
- evidence notes
- patch priorities

## Gate

High risk. Do not patch findings before the user confirms the direction.
