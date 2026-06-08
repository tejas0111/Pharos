---
name: pharos-contract-testing-for-testnet-and-mainnet
description: Design contract test coverage and environment-aware checks that validate behavior across both testnet and mainnet. Use when the user says: contract testing, testnet tests, mainnet tests, network-specific testing.
---

# Contract Testing for Testnet and Mainnet

Use when the user needs network-aware contract tests or checks.

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

## Gate

High risk. Do not generate network-aware tests before approval.
