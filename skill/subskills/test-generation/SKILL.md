---
name: pharos-test-generation
description: "Write unit, integration, or end-to-end tests for Pharos contracts and dapps from the chosen strategy. Use when generating tests, adding test files, creating fixtures, or writing mock data for Pharos Solidity contracts (Foundry/Hardhat) or frontend components. Keywords: write tests, generate tests, fixtures, mock data, unit test, integration test, e2e test, Foundry, Hardhat, Solidity, Pharos, forge test, hardhat test, wagmi, viem."
metadata:
  audience: developer
  version: 1.0.0
  category: testing
slash: true
---

# Test Generation

Write unit, integration, or end-to-end tests from the chosen strategy.

## When to Use

write tests, generate tests, fixtures, mock data, test files, add tests for, test this function, unit test, integration test

## When NOT to Use

planning what to test (use testing-strategy first), or debugging a failure (use bug-finding-and-debugging)

## Workflow

1. Use the approved test strategy and identify concrete cases.
2. Draft the tests with readable setup and assertions.
3. Show the test plan and ask if the cases are correct.
4. Generate the tests and verify they fail or pass as intended.

## Output

- test files
- fixtures
- assertions
- coverage notes

## Examples

- "Generate tests for the withdraw path and failure branches"
- "Create UI tests for transaction preview states"
- "Write Foundry tests for a staking contract's edge cases"

## Verification

forge test or npx hardhat test or npm test. Confirm tests pass (or fail as expected for TDD).

## Related

testing-strategy (planning), contract-testing-for-testnet-and-mainnet (network-specific), bug-finding-and-debugging (fixing failures)
