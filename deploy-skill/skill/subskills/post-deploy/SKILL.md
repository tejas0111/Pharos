---
name: pharos-post-deploy
description: "Post-deployment operations: verify contract on explorer, transfer ownership to multi-sig, update frontend config, run integration tests against deployed contract, set up monitoring alerts, announce deployment. Use when the user says: post-deploy, post-deployment, verify contract, transfer ownership, multi-sig transfer, update frontend config, integration tests on deployed, monitoring setup, deployment announcement, tagging release, after deploy, deployment follow-up, deployment complete. Do NOT use for: actual broadcast or deployment simulation (use testnet-deployment or mainnet-deployment), deployment prep (use pharos-agent-dev-suite/deployment-and-verification), or production ops planning (use pharos-agent-dev-suite/production-ops). See also: testnet-deployment (deploy action), mainnet-deployment (deploy action), production-ops (ongoing ops)."
---

# Post-Deployment

Post-deployment operations: verify contract on explorer, transfer ownership to multi-sig, update frontend config, run integration tests against deployed contract, set up monitoring alerts, announce deployment.

## When to Use

post-deploy, post-deployment, verify contract, transfer ownership, multi-sig transfer, update frontend config, integration tests on deployed, monitoring setup, deployment announcement, tagging release, after deploy, deployment follow-up, deployment complete

## When NOT to Use

actual broadcast or deployment simulation (use testnet-deployment or mainnet-deployment), deployment prep (use pharos-agent-dev-suite/deployment-and-verification), or production ops planning (use pharos-agent-dev-suite/production-ops)

## Workflow

1. Verify contract on explorer: run source code verification on PharosScan with matching compiler version, optimization settings, and constructor args.
2. Transfer ownership to multi-sig: prepare Safe transaction (Pharos Safe master copy: 0x41675C099F32341bf84BFc5382aF534df5C7461a) to transfer proxy admin or contract ownership.
3. Update frontend config: write the deployed address, ABI, and block number to the frontend config file. Regenerate TypeChain/abitype bindings if the ABI changed.
4. Run integration tests against the deployed contract: use fork tests pointing at the real deployment or direct RPC calls to verify state.
5. Set up monitoring alerts: configure Tenderly or Forta alerts for the deployed contract (ownership changes, large transfers, pausing).
6. Announce deployment: tag the release commit (`git tag v1.0.0`), update README with deployed address and explorer link, notify team.

## Output

- verification result (explorer link, ✅ status)
- ownership transfer transaction data (Safe multi-sig)
- frontend config diff (address, ABI, block number)
- integration test results against live contract
- monitoring alert configuration
- deployment announcement (explorer URL, tag, README update)

## Examples

- "Verify the deployed token contract on PharosScan"
- "Transfer proxy ownership to Pharos Safe multi-sig"
- "Update the frontend with the new contract address and ABI"
- "Run integration tests against the live testnet deployment"
- "Set up Tenderly alerts for the newly deployed vault"
- "Tag the release and announce the mainnet deployment"

## Verification

Check explorer shows ✅ Verified. Confirm Safe transaction queue shows the ownership transfer. Run integration tests against deployed address and verify they pass. Confirm monitoring dashboard shows the contract as active.

## Related

testnet-deployment (deploy action), mainnet-deployment (deploy action), production-ops (ongoing ops)
