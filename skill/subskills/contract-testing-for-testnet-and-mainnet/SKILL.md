---
name: pharos-contract-testing-for-testnet-and-mainnet
description: "Design Pharos contract test coverage and environment-aware checks for testnet (Atlantic 688689) and mainnet (Pacific 1672). Use when planning network-specific testing, fork tests, environment-aware test suites, or testnet vs mainnet contract validation for Pharos. Keywords: contract testing, testnet tests, mainnet tests, fork tests, network fork, Pharos, Atlantic, Pacific, 688689, 1672, Foundry, forge, anvil, environment-aware, integration testing."
metadata:
  audience: developer
  version: 1.0.0
  category: testing
slash: true
---

# Contract Testing for Testnet and Mainnet

Design contract test coverage and environment-aware checks for both network contexts.

## When to Use

contract testing, testnet tests, mainnet tests, network-specific testing, environment-aware tests, fork tests, network fork

## When NOT to Use

general unit test generation (use test-generation), or planning deployment (use deployment-for-testnet-and-mainnet)

## Workflow

1. Separate local unit coverage from network-aware checks.
2. Plan how testnet and mainnet constraints differ.
3. Show the test plan and ask for approval before generating tests.
4. Write tests or checks that make the network boundary explicit.

## Output

- test matrix
- network coverage plan
- fixture notes
- verification command

## Examples

- "Design contract tests that cover both testnet and mainnet assumptions"
- "Plan the network-specific test checks for this deployment flow"
- "Write fork tests that validate mainnet behavior against a local fork"

## Verification

forge test --fork-url <network> or hardhat network fork tests.

## Related

testing-strategy (general planning), deployment-for-testnet-and-mainnet (deploy counterpart)
