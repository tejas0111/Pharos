name: pharos-mainnet-deployment
description: "Prepare, simulate, broadcast, and verify Pharos contract deployments on Pacific Mainnet (chain ID: 1672). Use when deploying to mainnet, running production release, verifying contracts on mainnet explorer, or configuring PHAROS_MAINNET_RPC_URL for Pharos go-live. Keywords: deploy to mainnet, mainnet release, verify on mainnet, PHAROS_MAINNET_RPC_URL, mainnet deploy, production release, go live, Pacific mainnet, 1672, Pharos, Foundry, Hardhat, forge script, broadcast, simulation, dry-run, gate fix."
metadata:
  audience: developer
  version: 1.1.0
  category: deployment
slash: true
---

# Mainnet Deployment

Prepare, simulate, broadcast, and verify Pharos contract deployments on mainnet.

## When to Use

deploy to mainnet, mainnet release, verify on mainnet, PHAROS_MAINNET_RPC_URL, mainnet deploy, production release, go live, gate fix

## When NOT to Use

testnet rehearsal (use testnet-deployment first), contract coding (use pharos-agent-dev-suite), or deployment prep (use deployment-and-verification in dev suite)

## Workflow

1. Confirm the contract artifact, mainnet RPC, signer, verification target, and release assumptions.
2. Run all pre-flight checks: RPC reachable, balance sufficient for gas, **Gate Fix check**, simulation passes, chain ID confirmed.
3. Start from scripts/deploy-mainnet.sh for Foundry or scripts/deploy-mainnet-hardhat.sh for Hardhat, or use the repo's existing deploy flow.

   Forge deployment command:
   ```
   forge script script/Deploy.s.sol --rpc-url https://rpc.pharos.xyz --chain-id 1672 --broadcast --verify --verifier-url https://www.pharosscan.xyz/api
   ```

   Hardhat deployment command:
   ```
   npx hardhat run scripts/deploy.ts --network pharosMainnet
   ```

4. Pre-deploy checklist:
   - Multi-sig approval obtained from all required signers
   - Simulation passed on testnet rehearsal (deploy to Atlantic Testnet 688689 first)
   - PROS gas funded with 20% buffer above estimated cost
   - **Gate Fix**: Run a frontend/contract interaction check to ensure consistency.
   - **Private Key**: Ensure `${PRIVATE_KEY}` is loaded from a `.env` file; never hardcode or expose.
   - Deployer wallet confirmed (address whitelisted if needed)
   - Emergency rollback plan ready (previous version artifacts, revert scripts)
   - Chain ID confirmed as 1672 (Pharos Pacific Mainnet)

5. Present the plan and ask for explicit approval before broadcast.

6. Simulate first (`SIMULATE_ONLY=1`), then broadcast only on explicit approval.

7. Capture the address, tx hash, and run post-deploy verification.

8. Post-deploy: verify contract on mainnet PharosScan at `https://www.pharosscan.xyz/address/<DEPLOYED_ADDRESS>` and announce deployment with the PharosScan link.

9. Log explorer URL and prompt the user to tag the release commit.

## Output

- mainnet deployment plan (including gate fix results)
- deploy command
- verification command
- explorer link
- deployment record (address, tx hash, block)

## Examples

- "Deploy this contract to Pharos mainnet"
- "Prepare the mainnet release"
- "Verify the mainnet deployment on explorer"
- "Run gate fix before mainnet deploy"

## Verification

Post-deploy: query getCode on the address, check explorer for verification, confirm state matches constructor args. Prompt for git tag.

## Related

testnet-deployment (testnet rehearsal), pharos-agent-dev-suite/deployment-and-verification (prep work)
