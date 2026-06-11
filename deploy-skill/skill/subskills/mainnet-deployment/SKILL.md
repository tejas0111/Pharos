---
name: pharos-mainnet-deployment
description: Prepare, broadcast, and verify Pharos contract deployments on mainnet. Use when the user says: deploy to mainnet, mainnet release, verify on mainnet, PHAROS_MAINNET_RPC_URL.
---

# Pharos Mainnet Deployment

Use when the user wants a Pharos mainnet deployment or mainnet release.

## Workflow

1. Confirm the contract artifact, mainnet RPC, signer, verification target, and release assumptions.
2. Start from `scripts/deploy-mainnet.sh` for Foundry, `scripts/deploy-mainnet-hardhat.sh` for Hardhat deploy, and `scripts/verify-mainnet-hardhat.sh` for Hardhat verification, or use the repo's existing deploy flow.
3. Present the plan and ask for explicit approval before broadcast.
4. Broadcast, capture the address and tx hash, then verify the result.

## Output

- mainnet deployment plan
- deploy command
- verification command
- explorer link

## Gate

High risk. Do not broadcast before approval.

## Prompt

Use this when the user says:

- "Deploy this contract to Pharos mainnet"
- "Prepare the mainnet release"
