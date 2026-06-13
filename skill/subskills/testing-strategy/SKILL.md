---
name: pharos-testing-strategy
description: "Choose the right test mix, fixtures, and coverage focus for Pharos contracts and dapps before writing tests. Use when planning test strategy, coverage goals, edge cases, test plans, or deciding what to test for Pharos Solidity dapps and frontend integrations. Keywords: test strategy, coverage, fixtures, edge cases, test plan, test approach, Pharos, Solidity, Foundry, Hardhat, wagmi, viem, contract testing, dapp testing, integration testing."
metadata:
  audience: developer
  version: 1.0.0
  category: testing
slash: true
---

# Testing Strategy

Choose the right test mix, fixtures, and coverage focus before writing tests.

## When to Use

test strategy, coverage, fixtures, edge cases, test plan, what should I test, test approach, test coverage plan

## When NOT to Use

writing concrete tests (use test-generation), or running tests (that's a CI task, not a subskill)

## Workflow

1. Identify the contract, UI, or integration risks that matter most.
2. Choose unit, integration, and regression coverage appropriately.
3. Present the testing plan with explicit assumptions.
4. Wait for confirmation before generating tests or fixtures.

## Output

- test matrix
- fixture plan
- coverage goals
- regression checklist

## Examples

- "Design the test strategy for a token sale contract"
- "Plan coverage for a multi-step dapp transaction flow"
- "What should we test in this upgradeable vault contract?"

## Verification

Review of the test matrix. No test files yet.

## Related

test-generation (execution), contract-testing-for-testnet-and-mainnet (network-aware tests)
