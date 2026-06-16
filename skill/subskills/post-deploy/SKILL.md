---
name: pharos-post-deploy
description: "Post-deployment operations: verify contract on explorer, transfer ownership to multi-sig, update frontend config, run integration tests against deployed contract, set up monitoring alerts, announce deployment. Use when completing a deployment on Pharos mainnet or testnet. Keywords: post-deploy, post-deployment, verify contract, transfer ownership, multi-sig transfer, update frontend config, integration tests on deployed, monitoring setup, deployment announcement, tagging release, after deploy, deployment follow-up, deployment complete."
metadata:
  audience: developer
  version: 1.2.0
  category: deployment
slash: true
---

# Post-Deployment

Post-deployment operations: verify contract on explorer, transfer ownership to multi-sig, update frontend config, run integration tests against deployed contract, set up monitoring alerts, announce deployment.

## When to Use

post-deploy, post-deployment, verify contract, transfer ownership, multi-sig transfer, update frontend config, integration tests on deployed, monitoring setup, deployment announcement, tagging release, after deploy, deployment follow-up, deployment complete

## When NOT to Use

- **Actual broadcast or deployment simulation** — If the user needs to send a deploy transaction or simulate one, use `testnet-deployment` or `mainnet-deployment`.
- **Deployment preparation** — If the user is still writing contracts and preparing for deployment, use `pharos-agent-dev-suite/deployment-and-verification`.
- **Production ops planning** — If the user needs ongoing monitoring, alerting, or incident response (not just post-deploy one-time tasks), use `pharos-agent-dev-suite/production-ops`.
- **Contract authoring** — If the user is writing or modifying contract code, use `solidity-authoring`. Post-deploy assumes contracts are already deployed.
- **Frontend development** — If the user wants to build or update a dapp frontend (not just update config with new addresses), use `frontend-dapp-integration`.

## Workflow
- **Strict .env Check**: Verify `.env` exists in project root and contains `PRIVATE_KEY`, `PHAROSSCAN_API_KEY`, and required RPC URLs. Do NOT proceed if missing or if the user suggests using `export`.

1. **Requirement Gathering**: Analyze the user's request to identify the specific task, target environment (Atlantic 688689 or Pacific 1672), and any missing context. Zero-assumption delivery.
2. **Mandatory Plan (`PLAN.md`)**: Create or update `PLAN.md` in the project root with the proposed strategy. **Wait for explicit 'Approve' or 'Proceed' from the user before taking any action.**
3. Verify contract on PharosScan:
- Search for the deployed address on `https://www.pharosscan.xyz`
- Click "Verify & Publish"
- Select the matching compiler version, EVM version, and optimization settings
- Paste the flattened source code (use `forge flatten` or `hardhat flatten`)
- Submit and confirm the status shows Verified (green checkmark)
4. Transfer ownership to multi-sig: prepare Safe transaction (Pharos Safe master copy: 0x41675C099F32341bf84BFc5382aF534df5C7461a) to transfer proxy admin or contract ownership.
```
cast send --rpc-url $PHAROS_MAINNET_RPC_URL $CONTRACT "transferOwnership(address)" $MULTISIG
```
5. Update frontend config: set environment variables for the deployed contract.
```
NEXT_PUBLIC_CONTRACT_ADDRESS=<deployed-address>
NEXT_PUBLIC_PHAROS_CHAIN_ID=1672
```
Regenerate TypeChain/abitype bindings if the ABI changed.
6. Run integration tests against the deployed contract: use fork tests pointing at the real deployment or direct RPC calls to verify state.
```
forge test --fork-url $PHAROS_MAINNET_RPC_URL --match-contract IntegrationTest -vvv
```
7. Set up monitoring alerts:
- **Forta bot:** deploy or enable a detection bot for the deployed contract monitoring ownership changes, large transfers, and pausing events
- **Tenderly webhook:** create a Tenderly Web3 Action that watches the contract address and sends notifications on key events
8. Announce deployment: tag the release commit and notify the team.
```
git tag v1.0.0
git push origin v1.0.0
```
Announcement template:
```
Deployed <ContractName> to Pharos Mainnet
Address: <deployed-address>
Explorer: https://www.pharosscan.xyz/address/<deployed-address>
Tx: <tx-hash>
```
Update README with deployed address, PharosScan link, and block number.
## Output

- verification result (explorer link, ✅ status)
- ownership transfer transaction data (Safe multi-sig)
- frontend config diff (address, ABI, block number)
- integration test results against live contract
- monitoring alert configuration
- deployment announcement (explorer URL, tag, README update)

## Examples

- **Query:** "Verify the deployed token contract on PharosScan" → **Action:** Run source code verification on PharosScan with matching compiler version, optimization settings, and constructor args; confirm ✅ Verified status.
- **Query:** "Transfer proxy ownership to Pharos Safe multi-sig" → **Action:** Prepare Safe transaction to `0x41675C099F32341bf84BFc5382aF534df5C7461a` with `transferOwnership` calldata, submit to Safe queue, test on testnet first.
- **Query:** "Update the frontend with the new contract address and ABI" → **Action:** Write deployed address, ABI, and block number to frontend config file; regenerate TypeChain/abitype bindings if ABI changed; verify frontend compiles.
- **Query:** "Run integration tests against the live testnet deployment" → **Action:** Configure fork tests pointing at deployed contract address, run full test suite against real RPC endpoint, verify all tests pass with live state.
- **Query:** "Set up Tenderly alerts for the newly deployed vault" → **Action:** Create Tenderly Web3 Action monitoring vault events (large withdrawals, ownership changes, pause), configure notification channels, test with simulated event.
- **Query:** "Tag the release and announce the mainnet deployment" → **Action:** Create git tag (`git tag v1.0.0`), push to remote, update README with deployed address and explorer link, notify team with deployment summary.

## Verification

Check explorer shows ✅ Verified. Confirm Safe transaction queue shows the ownership transfer. Run integration tests against deployed address and verify they pass. Confirm monitoring dashboard shows the contract as active.

## Related

testnet-deployment (deploy action), mainnet-deployment (deploy action), production-ops (ongoing ops)

## Pharos-Specific

### PharosScan Verification

PharosScan (powered by Blockscout) requires matching compiler settings exactly:

```bash
# Verify after deployment
forge flatten contracts/MyContract.sol > flattened.sol

# Submit via Blockscout API
forge verify-contract <ADDRESS> MyContract \
  --chain 688689 \
  --verifier blockscout \
  --verifier-url https://atlantic.pharosscan.xyz/api \
  --constructor-args $(cast abi-encode "constructor(uint256,string)" 1000 "hello")
```

### Multi-Sig on Pharos

Pharos Safe master copy: `0x41675C099F32341bf84BFc5382aF534df5C7461a`

After deployment, transfer ownership to the Safe:

```bash
# Transfer ownership (OpenZeppelin Ownable)
cast send $CONTRACT \
  "transferOwnership(address)" \
  $SAFE_ADDRESS \
  --rpc-url $PHAROS_MAINNET_RPC_URL \
  --private-key $PRIVATE_KEY
```

### Monitoring on Pharos

Pharos supports `safe` and `finalized` block tags for production monitoring:

```bash
# Check finalized block (Pharos-specific)
cast block finalized --rpc-url $PHAROS_TESTNET_RPC_URL

# Monitor specific events
cast logs --rpc-url $PHAROS_TESTNET_RPC_URL \
  --from-block finalized-100 \
  --to-block finalized \
  --address $CONTRACT \
  "Transfer(address indexed from, address indexed to, uint256 value)"
```

### Integration Tests Against Live Deployment

Use fork tests pointing at real Pharos RPC:

```bash
forge test --fork-url $PHAROS_TESTNET_RPC_URL \
  --match-contract IntegrationTest \
  --chain-id 688689 \
  -vvv
```

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
