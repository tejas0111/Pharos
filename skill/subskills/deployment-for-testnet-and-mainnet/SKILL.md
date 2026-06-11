---
name: pharos-deployment-for-testnet-and-mainnet
description: Plan and validate contract deployments across testnet and mainnet with environment-aware safeguards and release checklists. Use when the user says: testnet, mainnet, deployment, release, deploy flow.
---

# Deployment for Testnet and Mainnet

Use when the user needs a safe deployment plan for both Pharos networks.

## Workflow

1. Identify the target network, deployment artifact, and release assumptions.
2. Separate testnet validation from mainnet release steps.
3. Show the deployment plan and ask for explicit approval.
4. Use the smallest safe verification step after deployment.

## Output

- network plan
- deployment steps
- release checklist
- verification checklist

## Gate

High risk. Do not change deployment behavior before approval.
