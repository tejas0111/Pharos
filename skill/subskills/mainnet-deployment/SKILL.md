name: pharos-mainnet-deployment
description: "Prepare, simulate, broadcast, and verify Pharos contract deployments on Pacific Mainnet (chain ID: 1672). Use when deploying to mainnet, running production release, verifying contracts on mainnet explorer, or configuring PHAROS_MAINNET_RPC_URL for Pharos go-live. Keywords: deploy to mainnet, mainnet release, verify on mainnet, PHAROS_MAINNET_RPC_URL, mainnet deploy, production release, go live, Pacific mainnet, 1672, Pharos, Foundry, Hardhat, forge script, broadcast, simulation, dry-run, gate fix."
metadata:
  audience: developer
  version: 1.2.0
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

1. **Requirement Gathering**: Analyze the user's request to identify the specific task, target environment (Atlantic 688689 or Pacific 1672), and any missing context. Zero-assumption delivery.
2. **Mandatory Plan (`PLAN.md`)**: Create or update `PLAN.md` in the project root with the proposed strategy. **Wait for explicit 'Approve' or 'Proceed' from the user before taking any action.**
3. Confirm the contract artifact, mainnet RPC, signer, verification target, and release assumptions.
4. Run all pre-flight checks: RPC reachable, balance sufficient for gas, **Gate Fix check**, simulation passes, chain ID confirmed.
5. Start from scripts/deploy-mainnet.sh for Foundry or scripts/deploy-mainnet-hardhat.sh for Hardhat, or use the repo's existing deploy flow.
Forge deployment command:
```
forge script script/Deploy.s.sol --rpc-url $PHAROS_MAINNET_RPC_URL --chain-id 1672 --broadcast --verify --verifier-url $PHAROSSCAN_MAINNET_API_URL
```
Hardhat deployment command:
```
npx hardhat run scripts/deploy.ts --network pharosMainnet
```
6. Pre-deploy checklist:
- **Strict .env Check**: Verify `.env` exists in project root and contains `PRIVATE_KEY`, `PHAROSSCAN_API_KEY`, and required RPC URLs. Do NOT proceed if missing or if the user suggests using `export`.
- Multi-sig approval obtained from all required signers
- Simulation passed on testnet rehearsal (deploy to Atlantic Testnet 688689 first)
- PROS gas funded with 20% buffer above estimated cost
- **Gate Fix**: Run a frontend/contract interaction check to ensure consistency.
- **Private Key**: Ensure `${PRIVATE_KEY}` is loaded from a `.env` file; never hardcode or expose.
- Deployer wallet confirmed (address whitelisted if needed)
- Emergency rollback plan ready (previous version artifacts, revert scripts)
- Chain ID confirmed as 1672 (Pharos Pacific Mainnet)
7. Present the plan and ask for explicit approval before broadcast.
8. Simulate first (`SIMULATE_ONLY=1`), then broadcast only on explicit approval.
9. Capture the address, tx hash, and run post-deploy verification.
10. Post-deploy: verify contract on mainnet PharosScan at `https://www.pharosscan.xyz/address/<DEPLOYED_ADDRESS>` and announce deployment with the PharosScan link.
11. Log explorer URL and prompt the user to tag the release commit.
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

## Gate

High risk — two-phase execution required:

**Phase 1 — Plan (present freely):**
- Draft the `PLAN.md` with the full implementation strategy, environment-aware safeguards, and verification steps.
- Do NOT wait for approval to draft — show everything in your response before asking for confirmation
- Wait for explicit 'Approve' or 'Proceed' from the user.

**Phase 2 — Execute (wait for approval):**
- Execute the approved plan from `PLAN.md`.
- Do NOT send any onchain transactions or modify critical files until approved.
- Perform a final "Ready to Broadcast?" check for any high-risk on-chain actions.
- Wait for explicit user confirmation ("I approve", "proceed", "looks good") before taking any of the Phase 2 actions.
