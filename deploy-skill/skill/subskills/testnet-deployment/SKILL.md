---
name: pharos-testnet-deployment
description: "Prepare, simulate, broadcast, and verify Pharos contract deployments on Atlantic Testnet (chain ID: 688689). Use when deploying to testnet, running testnet rehearsal, verifying contracts on testnet explorer, or configuring PHAROS_TESTNET_RPC_URL for Pharos testnet releases. Keywords: deploy to testnet, testnet rehearsal, verify on testnet, PHAROS_TESTNET_RPC_URL, testnet deploy, testnet release, Atlantic testnet, 688689, Pharos, Foundry, Hardhat, forge script, broadcast, simulation, dry-run."
metadata:
  audience: developer
  version: 1.0.0
  category: deployment
slash: true
---

# Testnet Deployment

Prepare, simulate, broadcast, and verify Pharos contract deployments on testnet.

## When to Use

deploy to testnet, testnet rehearsal, verify on testnet, PHAROS_TESTNET_RPC_URL, testnet deploy, testnet release

## When NOT to Use

mainnet deployment (use mainnet-deployment), contract coding (use pharos-agent-dev-suite), or deployment prep (use deployment-and-verification in dev suite)

## Workflow

1. Confirm the contract artifact, testnet RPC, signer, and verification target.
2. Run pre-flight checks: RPC reachable, balance sufficient, simulation passes.
3. Start from scripts/deploy-testnet.sh for Foundry or scripts/deploy-testnet-hardhat.sh for Hardhat, or use the repo's existing deploy flow.
4. Present the plan and ask for explicit approval before broadcast.
5. Simulate first (SIMULATE_ONLY=1), then broadcast on approval.
6. Capture the address, tx hash, and run post-deploy verification.

## Output

- testnet deployment plan
- deploy command
- verification command
- explorer link
- deployment record (address, tx hash)

## Examples

- "Deploy this contract to Pharos testnet"
- "Verify this deployment on testnet"
- "Simulate the testnet deployment before broadcasting"

## Verification

Post-deploy: query getCode on the address, check explorer for verification, confirm state matches constructor args.

## Related

mainnet-deployment (production counterpart), pharos-agent-dev-suite/deployment-and-verification (prep work)
