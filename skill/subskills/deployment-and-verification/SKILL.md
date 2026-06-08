---
name: pharos-deployment-and-verification
description: "Prepare deploy scripts, env variables, explorer verification, and post-deploy checks. Use when the user says: deploy, verification, explorer, release, publish contract, deployment prep, deploy script, verification flow. Do NOT use for: actually broadcasting a transaction (hand off to pharos-agent-deploy-suite), or planning deployment across networks (use deployment-for-testnet-and-mainnet). See also: deployment-for-testnet-and-mainnet (network planning), pharos-agent-deploy-suite (broadcast execution)."
---

# Deployment and Verification

Prepare deploy scripts, env variables, explorer verification, and post-deploy checks.

## When to Use

deploy, verification, explorer, release, publish contract, deployment prep, deploy script, verification flow

## When NOT to Use

actually broadcasting a transaction (hand off to pharos-agent-deploy-suite), or planning deployment across networks (use deployment-for-testnet-and-mainnet)

## Workflow

1. Confirm the deployment target, network, and required config.
2. Draft the deploy and verification steps explicitly.
3. Present the plan and wait for approval before any deploy-side change.
4. Verify the deployed artifact and capture the outcome.

## Output

- deployment steps
- verification checklist
- env var list
- post-deploy checks

## Examples

- "Prepare the deploy and verification flow for this contract"
- "Write the release checklist for a Pharos contract rollout"
- "Set up the deploy scripts and env variables for testnet deployment"

## Verification

Dry run or script syntax check. Not a real broadcast.

## Related

deployment-for-testnet-and-mainnet (network planning), pharos-agent-deploy-suite (broadcast execution)
