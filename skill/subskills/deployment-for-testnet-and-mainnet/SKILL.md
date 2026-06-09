---
name: pharos-deployment-for-testnet-and-mainnet
description: "Plan and validate Pharos contract deployments across testnet (Atlantic 688689) and mainnet (Pacific 1672) with environment-aware safeguards and release checklists. Use when planning testnet vs mainnet deployment strategy, release checklists, environment safeguards, or network-specific deployment flows for Pharos. Keywords: testnet, mainnet, deployment, release, deploy flow, Pharos, Atlantic, Pacific, 688689, 1672, Foundry, Hardhat, forge script, hardhat deploy, environment-aware, safeguards, checklist."
metadata:
  audience: developer
  version: 1.0.0
  category: deployment
slash: true
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
