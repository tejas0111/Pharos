---
name: pharos-mainnet-deployment
description: "Prepare, simulate, broadcast, and verify Pharos contract deployments on Pacific Mainnet (chain ID: 1672). Use when deploying to mainnet, running production release, verifying contracts on mainnet explorer, or configuring PHAROS_MAINNET_RPC_URL for Pharos go-live. Keywords: deploy to mainnet, mainnet release, verify on mainnet, PHAROS_MAINNET_RPC_URL, mainnet deploy, production release, go live, Pacific mainnet, 1672, Pharos, Foundry, Hardhat, forge script, broadcast, simulation, dry-run."
metadata:
  audience: developer
  version: 1.0.0
  category: deployment
slash: true
---

# Mainnet Deployment

Prepare, simulate, broadcast, and verify Pharos contract deployments on mainnet.

## When to Use

deploy to mainnet, mainnet release, verify on mainnet, PHAROS_MAINNET_RPC_URL, mainnet deploy, production release, go live

## When NOT to Use

testnet rehearsal (use testnet-deployment first), contract coding (use pharos-agent-dev-suite), or deployment prep (use deployment-and-verification in dev suite)

## Workflow

1. Confirm the contract artifact, mainnet RPC, signer, verification target, and release assumptions.
2. Run all pre-flight checks: RPC reachable, balance sufficient for gas, simulation passes, chain ID confirmed.
3. Start from scripts/deploy-mainnet.sh for Foundry or scripts/deploy-mainnet-hardhat.sh for Hardhat, or use the repo's existing deploy flow.
4. Present the plan and ask for explicit approval before broadcast.
5. Simulate first (SIMULATE_ONLY=1), then broadcast only on explicit approval.
6. Capture the address, tx hash, and run post-deploy verification.
7. Log explorer URL and prompt the user to tag the release commit.

## Output

- mainnet deployment plan
- deploy command
- verification command
- explorer link
- deployment record (address, tx hash, block)

## Examples

- "Deploy this contract to Pharos mainnet"
- "Prepare the mainnet release"
- "Verify the mainnet deployment on explorer"

## Verification

Post-deploy: query getCode on the address, check explorer for verification, confirm state matches constructor args. Prompt for git tag.

## Related

testnet-deployment (testnet rehearsal), pharos-agent-dev-suite/deployment-and-verification (prep work)
