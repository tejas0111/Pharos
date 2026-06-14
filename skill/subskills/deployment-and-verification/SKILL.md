name: pharos-deployment-and-verification
description: "Prepare Pharos deploy scripts, env variables, explorer verification, and post-deploy checks for testnet and mainnet. Use when preparing deployment, writing deploy scripts, configuring verification, or setting up release pipelines for Pharos contracts (Atlantic testnet 688689 / mainnet 1672). Keywords: deploy, verification, explorer, release, publish contract, deploy script, verification flow, Pharos, Foundry, Hardhat, forge script, hardhat deploy, 688689, 1672, PHAROSSCAN_API_KEY, contract verification, gate fix."
metadata:
  audience: developer
  version: 1.1.0
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
- **Security**: private keys must be stored in `.env` and accessed via `${PRIVATE_KEY}`.

- **Foundry**: `forge build` must succeed. Run `forge --version` to verify installation.
- **RPC endpoint**: Set `PHAROS_TESTNET_RPC=https://atlantic.dplabs-internal.com` or `PHAROS_MAINNET_RPC=https://rpc.pharos.xyz` in your environment or `.env`.
- **Private key**: Set `PRIVATE_KEY` environment variable in `.env` (keep this secret, never commit or expose to LLM).
- **PharosScan API key**: Set `PHAROSSCAN_API_KEY` for contract verification (https://www.pharosscan.xyz).
- **Network reachability**: Run `cast chain-id --rpc-url $RPC_URL` to confirm the target network is reachable.
- **Foundry config**: `foundry.toml` should have `[rpc_endpoints]` section with `pharos_testnet` and `pharos_mainnet` entries.

## Workflow

1. Confirm the deployment target, network, and required config (`config/pharos.json`).
2. Check prerequisites: verify Foundry is installed, RPC endpoints are reachable, and required env vars are set. **Gate Fix check** must be performed. Ask the user for any missing values before proceeding.
3. Draft the deploy and verification steps explicitly using Pharos-specific commands.
4. Present the plan and wait for approval before any deploy-side change.
5. Verify the deployed artifact on PharosScan and capture the outcome.

## Commands

### Foundry (Forge) — Pharos Mainnet

```bash
forge script script/Deploy.s.sol \
  --rpc-url https://rpc.pharos.xyz \
  --broadcast \
  --verify \
  --verifier-url https://www.pharosscan.xyz/api \
  --chain-id 1672
```

### Foundry (Forge) — Pharos Atlantic Testnet

```bash
forge script script/Deploy.s.sol \
  --rpc-url https://atlantic.dplabs-internal.com \
  --broadcast \
  --verify \
  --verifier-url https://atlantic.pharosscan.xyz/api \
  --chain-id 688689
```

### Hardhat — Pharos Mainnet

Ensure `hardhat.config.ts` has a `pharosMainnet` network entry:

```ts
pharosMainnet: {
  url: "https://rpc.pharos.xyz",
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
  url: "https://atlantic.dplabs-internal.com",
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
  --verifier-url https://www.pharosscan.xyz/api \
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
- Draft the deployment plan, forge script, pre-deploy checklist, dry run command, gate fix verification, and verification steps — show the exact commands
- Do NOT wait for approval to draft — show everything in your response before asking for confirmation

**Phase 2 — Execute (wait for approval):**
- Do NOT Broadcast, deploy, modify deploy scripts or constructor args, or send onchain transactions
- Wait for explicit user confirmation ("I approve", "proceed", "looks good") before taking any of the Phase 2 actions