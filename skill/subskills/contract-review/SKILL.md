---
name: pharos-contract-review
description: "Review Solidity code for correctness, security, gas, and design issues. Use when the user says: review contract, audit, security review, Solidity review, gas review, check this contract, look for bugs, security audit. Do NOT use for: fixing specific bugs (use bug-finding-and-debugging), writing new code (use solidity-authoring), or automated analysis (use forge test or slither directly). See also: bug-finding-and-debugging (fixing issues), solidity-authoring (patching)."
---

# Contract Review

Review Solidity code for correctness, security, gas, and design issues.

## When to Use

review contract, audit, security review, Solidity review, gas review, check this contract, look for bugs, security audit

## When NOT to Use

fixing specific bugs (use bug-finding-and-debugging), writing new code (use solidity-authoring), or automated analysis (use forge test or slither directly)

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

## Examples

- "Review this vault contract for access-control mistakes"
- "Audit this mint function for reentrancy and supply bugs"
- "Check this upgradeable proxy pattern for storage collision risks"

## Verification

Manual review only. Optionally recommend slither or forge inspect for automated checks.

## Related

bug-finding-and-debugging (fixing issues), solidity-authoring (patching)
