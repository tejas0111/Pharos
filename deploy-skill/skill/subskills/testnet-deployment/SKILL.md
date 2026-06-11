---
name: pharos-testnet-deployment
description: Prepare, broadcast, and verify Pharos contract deployments on testnet. Use when the user says: deploy to testnet, testnet rehearsal, verify on testnet, PHAROS_TESTNET_RPC_URL.
---

# Pharos Testnet Deployment

Use when the user wants a Pharos testnet deployment or testnet-only deploy rehearsal.

## Workflow

1. Confirm the contract artifact, testnet RPC, signer, and verification target.
2. Start from `scripts/deploy-testnet.sh` for Foundry, `scripts/deploy-testnet-hardhat.sh` for Hardhat deploy, and `scripts/verify-testnet-hardhat.sh` for Hardhat verification, or use the repo's existing deploy flow.
3. Present the plan and ask for explicit approval before broadcast.
4. Broadcast, capture the address and tx hash, then verify the result.

## Output

- testnet deployment plan
- deploy command
- verification command
- explorer link

## Gate

High risk. Do not broadcast before approval.

## Prompt

Use this when the user says:

- "Deploy this contract to Pharos testnet"
- "Verify this deployment on testnet"
