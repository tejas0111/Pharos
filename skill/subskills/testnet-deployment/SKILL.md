name: pharos-testnet-deployment
description: "Prepare, simulate, broadcast, and verify Pharos contract deployments on Atlantic Testnet (chain ID: 688689). Use when deploying to testnet, running testnet rehearsal, verifying contracts on testnet explorer, or configuring PHAROS_TESTNET_RPC_URL for Pharos testnet releases. Keywords: deploy to testnet, testnet rehearsal, verify on testnet, PHAROS_TESTNET_RPC_URL, testnet deploy, testnet release, Atlantic testnet, 688689, Pharos, Foundry, Hardhat, forge script, broadcast, simulation, dry-run, gate fix."
metadata:
  audience: developer
  version: 1.2.0
  category: deployment
slash: true
---

# Testnet Deployment

Prepare, simulate, broadcast, and verify Pharos contract deployments on testnet.

## When to Use

deploy to testnet, testnet rehearsal, verify on testnet, PHAROS_TESTNET_RPC_URL, testnet deploy, testnet release, gate fix

## When NOT to Use

mainnet deployment (use mainnet-deployment), contract coding (use pharos-agent-dev-suite), or deployment prep (use deployment-and-verification in dev suite)

## Workflow

1. **Requirement Gathering**: Analyze the user's request to identify the specific task, target environment (Atlantic 688689 or Pacific 1672), and any missing context. Zero-assumption delivery.
2. **Mandatory Plan (`PLAN.md`)**: Create or update `PLAN.md` in the project root with the proposed strategy. **Wait for explicit 'Approve' or 'Proceed' from the user before taking any action.**
3. Confirm the contract artifact, testnet RPC, signer, and verification target.
4. Run pre-flight checks: RPC reachable, balance sufficient, **Gate Fix check**, simulation passes.
5. Start from scripts/deploy-testnet.sh for Foundry or scripts/deploy-testnet-hardhat.sh for Hardhat, or use the repo's existing deploy flow.
Forge deployment command:
```
forge script script/Deploy.s.sol --rpc-url $PHAROS_TESTNET_RPC_URL --chain-id 688689 --broadcast --verify --verifier-url $PHAROSSCAN_TESTNET_API_URL
```
Hardhat deployment command:
```
npx hardhat run scripts/deploy.ts --network pharosTestnet
```
6. Pre-deploy checklist:
- **Strict .env Check**: Confirm `.env` exists with `test -f .env` and check variables via `grep -q` (without printing values). NEVER print `.env` contents. Do NOT proceed if missing or if the user suggests `export`.
- Funded wallet with testnet PHRS
- Chain ID confirmed as 688689 (Atlantic Testnet)
- Gas price checked and within budget
- **Gate Fix**: Run a frontend/contract interaction check to ensure consistency.
- **Private Key**: Ensure `${PRIVATE_KEY}` is loaded from a `.env` file; never hardcode or expose.
- Previous deployment artifacts backed up (`deployments/testnet/` directory)
- Simulation passes with `SIMULATE_ONLY=1`
7. Present the plan and ask for explicit approval before broadcast.
8. Simulate first (`SIMULATE_ONLY=1`), then broadcast on approval.
9. Capture the address, tx hash, and run post-deploy verification.
10. Post-deploy: verify contract on testnet PharosScan at `https://atlantic.pharosscan.xyz/address/<DEPLOYED_ADDRESS>` and update `config/pharos.json` with the new contract address.
## Output

- testnet deployment plan (including gate fix results)
- deploy command
- verification command
- explorer link
- deployment record (address, tx hash)

## Examples

- "Deploy this contract to Pharos testnet"
- "Verify this deployment on testnet"
- "Simulate the testnet deployment before broadcasting"
- "Run gate fix before testnet deploy"

## Verification

Post-deploy: query getCode on the address, check explorer for verification, confirm state matches constructor args.

## Related

mainnet-deployment (production counterpart), pharos-agent-dev-suite/deployment-and-verification (prep work)

## Pharos-Specific

### Network Configuration

Atlantic Testnet runs on chain ID `688689` with fast ~2s block times. Unlike Ethereum, PHRS transfers do **not** provide a 2300 gas stipend — your contracts must never use `.transfer()` or `.send()`.

```bash
# RPC (rate-limited: ~30 req/s sustained, ~100 req/s burst)
PHAROS_TESTNET_RPC_URL=https://atlantic.dplabs-internal.com

# Forge deployment (use --delay 1000 between broadcast batches)
forge script script/Deploy.s.sol \
  --rpc-url $PHAROS_TESTNET_RPC_URL \
  --chain-id 688689 \
  --broadcast \
  --delay 1000
```

### Verification

PharosScan uses Blockscout under the hood. No API key needed for testnet:

```bash
forge verify-contract <ADDRESS> <CONTRACT> \
  --chain 688689 \
  --verifier blockscout \
  --verifier-url https://atlantic.pharosscan.xyz/api
```

### Rate Limits & Block Range

- `eth_getLogs` limited to **100 block range** per request
- Use `safe` and `finalized` block tags for production reads (Pharos-specific RPC tags)
- `eth_getAccount` is a Pharos-native RPC that returns balance, nonce, codeHash, and storageRoot in one call

### Example: Deploy + Verify in One Command

```bash
forge script script/Deploy.s.sol \
  --rpc-url https://atlantic.dplabs-internal.com \
  --chain-id 688689 \
  --broadcast \
  --verify \
  --verifier blockscout \
  --verifier-url https://atlantic.pharosscan.xyz/api
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
