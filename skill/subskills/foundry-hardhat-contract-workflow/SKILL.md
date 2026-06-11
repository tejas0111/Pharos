---
name: pharos-foundry-hardhat-contract-workflow
description: "Set up Solidity development workflows for Foundry or Hardhat, including tests, scripts, and local runs. Use when the user says: Foundry, Hardhat, forge, anvil, Solidity workflow, contract workflow, forge init, hardhat init, forge test, hardhat test. Do NOT use for: writing individual contracts (use solidity-authoring), or debugging build failures (use ci-and-build-troubleshooting). See also: framework-integration (initial setup), solidity-authoring (writing contracts)."
---

# Foundry and Hardhat Contract Workflow

Set up Solidity development workflows for Foundry or Hardhat, including tests, scripts, and local runs.

## When to Use

Foundry, Hardhat, forge, anvil, Solidity workflow, contract workflow, forge init, hardhat init, forge test, hardhat test

## When NOT to Use

writing individual contracts (use solidity-authoring), or debugging build failures (use ci-and-build-troubleshooting)

## Workflow

1. Identify the contract task and the local dev stack.
2. Choose the smallest Foundry or Hardhat workflow that fits the request.
3. Show the plan and proceed once it looks right.
4. Verify the workflow with the smallest useful command or file change.

## Output

- workflow plan
- script notes
- test notes
- verification command

## Examples

- "Set up a Foundry workflow for this contract repo"
- "Create the Hardhat contract workflow for tests and scripts"
- "Configure Foundry with fuzz testing and gas reporting"

## Verification

forge test or npx hardhat test.

## Related

framework-integration (initial setup), solidity-authoring (writing contracts)
