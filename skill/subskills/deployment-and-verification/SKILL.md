name: pharos-deployment-and-verification
description: "Prepare Pharos deploy scripts, env variables, explorer verification, and post-deploy checks for testnet and mainnet. Use when preparing deployment, writing deploy scripts, configuring verification, or setting up release pipelines for Pharos contracts (Atlantic testnet 688689 / mainnet 1672). Keywords: deploy, verification, explorer, release, publish contract, deploy script, verification flow, Pharos, Foundry, Hardhat, forge script, hardhat deploy, 688689, 1672, PHAROSSCAN_API_KEY, contract verification, gate fix."
metadata:
  audience: developer
  version: 1.2.0
  category: deployment
slash: true
---

# Deployment and Verification

Prepare deploy scripts, env variables, explorer verification, and post-deploy checks.

## When to Use

deploy, verification, explorer, release, publish contract, deployment prep, deploy script, verification flow, gate fix

## When NOT to Use

actually broadcasting a transaction (requires user approval before execution), or planning deployment across networks (use deployment-for-testnet-and-mainnet)

## Prerequisites
- **Gate Fix**: Perform the mandatory "Gate Fix" check before proceeding.
- **Security**:
    - **.env Usage**: Environment variables MUST be stored in a `.env` file in the project root. NEVER use `export VAR=...` for sensitive data.
    - **Mandatory Check**: The Agent MUST verify `.env` exists and variables are set using `grep -q` (NEVER `cat`, `head`, `tail` — those expose secrets) before any deployment or on-chain action.
    - **Git**: Ensure `.env` is listed in `.gitignore` to prevent accidental commits.

- **Foundry**: `forge build` must succeed. Run `forge --version` to verify installation.
- **RPC endpoint**: Set `PHAROS_TESTNET_RPC=$PHAROS_TESTNET_RPC_URL` or `PHAROS_MAINNET_RPC=$PHAROS_MAINNET_RPC_URL` in your environment or `.env`.
- **PharosScan API key**: Set `PHAROSSCAN_API_KEY` for contract verification (https://www.pharosscan.xyz).
- **Network reachability**: Run `cast chain-id --rpc-url $RPC_URL` to confirm the target network is reachable.
- **Foundry config**: `foundry.toml` should have `[rpc_endpoints]` section with `pharos_testnet` and `pharos_mainnet` entries.
## Workflow
- **Strict .env Check**: Confirm `.env` exists with `test -f .env` and check variables via `grep -q` (without printing values). NEVER print `.env` contents. Do NOT proceed if missing or if the user suggests `export`.

1. **Requirement Gathering**: Analyze the user's request to identify the specific task, target environment (Atlantic 688689 or Pacific 1672), and any missing context. Zero-assumption delivery.
2. **Mandatory Plan (`PLAN.md`)**: Create or update `PLAN.md` in the project root with the proposed strategy. **Wait for explicit 'Approve' or 'Proceed' from the user before taking any action.**
3. Confirm the deployment target, network, and required config (`config/pharos.json`).
4. Check prerequisites: verify Foundry is installed, RPC endpoints are reachable, and required env vars are set. **Gate Fix check** must be performed. Ask the user for any missing values before proceeding.
5. Draft the deploy and verification steps explicitly using Pharos-specific commands.
6. Present the plan and wait for approval before any deploy-side change.
7. Verify the deployed artifact on PharosScan and capture the outcome.
## Commands

### Foundry (Forge) — Pharos Mainnet

```bash
forge script script/Deploy.s.sol \
  --rpc-url $PHAROS_MAINNET_RPC_URL \
  --broadcast \
  --verify \
  --verifier-url $PHAROSSCAN_MAINNET_API_URL \
  --chain-id 1672
```

### Foundry (Forge) — Pharos Atlantic Testnet

```bash
forge script script/Deploy.s.sol \
  --rpc-url $PHAROS_TESTNET_RPC_URL \
  --broadcast \
  --verify \
  --verifier-url $PHAROSSCAN_TESTNET_API_URL \
  --chain-id 688689
```

### Hardhat — Pharos Mainnet

Ensure `hardhat.config.ts` has a `pharosMainnet` network entry:

```ts
pharosMainnet: {
  url: "$PHAROS_MAINNET_RPC_URL",
  chainId: 1672,
  accounts: [process.env.PRIVATE_KEY!],
}
```

Then run:

```bash
npx hardhat run scripts/deploy.ts --network pharosMainnet
```

### Hardhat — Pharos Atlantic Testnet

```ts
pharosTestnet: {
  url: "$PHAROS_TESTNET_RPC_URL",
  chainId: 688689,
  accounts: [process.env.PRIVATE_KEY!],
}
```

Then run:

```bash
npx hardhat run scripts/deploy.ts --network pharosTestnet
```

### PharosScan Verification (manual)

Flatten the contract first, then verify:

```bash
forge flatten src/MyContract.sol -o flattened/MyContract.sol
forge verify-contract \
  <DEPLOYED_ADDRESS> \
  src/MyContract.sol:MyContract \
  --chain-id 1672 \
  --verifier-url $PHAROSSCAN_MAINNET_API_URL \
  --etherscan-api-key <PHAROSSCAN_API_KEY>
```

## Pre-deploy Checklist

- [ ] Chain ID confirmed (mainnet: 1672, testnet: 688689)
- [ ] Deployer wallet funded with sufficient native token (PROS/PHRS) for gas
- [ ] Gas price checked against Pharos current average
- [ ] **Gate Fix**: Frontend/contract interaction check passed.
- [ ] `config/pharos.json` network parameters reviewed
- [ ] Private key set in `.env` (PRIVATE_KEY)
- [ ] Contract compiled without errors (`forge build` / `npx hardhat compile`)

## Post-deploy Checks

- [ ] Contract verified on PharosScan (explorer link works)
- [ ] Frontend config updated with new deployed address
- [ ] Integration tests run against deployed contract
- [ ] Deployment artifacts committed to repository

## Output

- deployment steps with Pharos RPC and chain ID
- verification checklist using PharosScan API
- env var list (PRIVATE_KEY, PHAROSSCAN_API_KEY)
- post-deploy checks

## Examples

- "Prepare the deploy and verification flow for this contract"
- "Write the release checklist for a Pharos contract rollout"
- "Set up the deploy scripts and env variables for testnet deployment"
- "Deploy my contract to Pharos mainnet and verify on PharosScan"
- "Show me the forge command to deploy and verify on Pharos"
- "Run gate fix before preparing deployment"

## Verification

Dry run with `forge script --dry-run` or `npx hardhat run scripts/deploy.ts --network hardhat`. Not a real broadcast until approved.

## Related

deployment-for-testnet-and-mainnet (network planning), post-deploy (post-deployment ops)

## Gate

High risk — two-phase execution required:

**Phase 1 — Plan (present freely):**
- Draft the `PLAN.md` with the full implementation strategy, environment-aware safeguards, and verification steps.
- Wait for explicit 'Approve' or 'Proceed' from the user.

**Phase 2 — Execute (wait for approval):**
- Execute the approved plan from `PLAN.md`.
- Do NOT Broadcast, deploy, modify deploy scripts or constructor args, or send onchain transactions
- Perform a final "Ready to Broadcast?" check for any high-risk on-chain actions.
- Wait for explicit user confirmation ("I approve", "proceed", "looks good") before taking any of the Phase 2 actions.