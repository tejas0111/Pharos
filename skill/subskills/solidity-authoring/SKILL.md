---
name: pharos-solidity-authoring
description: "Write or refactor Solidity contracts with clear structure, custom errors, events, modifiers, and testable patterns. Use when the user says: write Solidity, implement contract, refactor contract, contract code, Solidity, write a contract, implement the staking contract, write smart contract. Do NOT use for: designing architecture (use contract-architecture), reviewing code (use contract-review), or writing tests (use test-generation). See also: contract-architecture (design), interface-abi-design (ABI), test-generation (tests)."
---

# Solidity Authoring

Write or refactor Solidity contracts with clear structure, custom errors, events, modifiers, and testable patterns.

## When to Use

write Solidity, implement contract, refactor contract, contract code, Solidity, write a contract, implement the staking contract, write smart contract

## When NOT to Use

designing architecture (use contract-architecture), reviewing code (use contract-review), or writing tests (use test-generation)

## Workflow

1. Capture the contract goal, inputs, outputs, and invariants.
2. Draft the contract shape, custom errors, events, and modifiers.
3. Present the implementation plan and ask for confirmation.
4. Write the contract in a way that is easy to test and review.

## Output

- contract draft
- event and error plan
- implementation notes
- test hooks
- invariants

## Examples

- "Write a Solidity escrow contract with refund and dispute paths"
- "Refactor this token contract to use custom errors and events"
- "Implement a staking contract with deposit, withdraw, and reward distribution"

## Verification

forge build or npx hardhat compile. Then forge test for unit tests.

## Related

contract-architecture (design), interface-abi-design (ABI), test-generation (tests)
