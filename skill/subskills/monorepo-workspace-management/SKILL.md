---
name: pharos-monorepo-workspace-management
description: "Handle workspace boundaries, package scripts, and shared tooling in Pharos monorepos. Use when managing monorepos, Turborepo, pnpm workspaces, shared packages, workspace boundaries, package scripts, or multi-package setups for Pharos dapps. Keywords: monorepo, workspace, Turborepo, pnpm workspace, shared package, workspace boundaries, package scripts, multi-package, Pharos, Solidity, TypeScript, Next.js, Foundry, Hardhat."
metadata:
  audience: developer
  version: 1.2.0
  category: tooling
slash: true
---

# Monorepo and Workspace Management

Handle workspace boundaries, package scripts, and shared tooling in Pharos monorepos with Foundry contracts, Next.js frontend, and shared config for chain 1672.

## Pharos Monorepo Structure

```
pharos-dapp/
├── pnpm-workspace.yaml
├── package.json
├── turbo.json
├── contracts/          # Foundry project
│   ├── foundry.toml
│   ├── src/
│   └── test/
├── frontend/           # Next.js App Router
│   ├── app/
│   ├── components/
│   └── package.json
└── packages/
    └── shared/         # Shared chain config, ABIs, types
        ├── src/
        │   └── pharosChain.ts
        ├── package.json
        └── tsconfig.json
```

### pnpm-workspace.yaml

```yaml
packages:
  - "contracts"
  - "frontend"
  - "packages/*"
```

### packages/shared/src/pharosChain.ts

```typescript
import { defineChain } from 'viem'

export const pharosMainnet = defineChain({
  id: 1672,
  name: 'Pharos Mainnet',
  nativeCurrency: { name: 'PHRS', symbol: 'PHRS', decimals: 18 },
  rpcUrls: { default: { http: ['$PHAROS_MAINNET_RPC_URL'] } },
  blockExplorers: { default: { name: 'PharosScan', url: 'https://www.pharosscan.xyz' } },
})

export const pharosTestnet = defineChain({
  id: 688689,
  name: 'Pharos Atlantic Testnet',
  nativeCurrency: { name: 'PHRS', symbol: 'PHRS', decimals: 18 },
  rpcUrls: { default: { http: ['$PHAROS_TESTNET_RPC_URL'] } },
  blockExplorers: { default: { name: 'PharosScan', url: 'https://www.pharosscan.xyz' } },
})

export const PHRS_DECIMALS = 18
export const PHAROS_MAINNET_CHAIN_ID = 1672
export const PHAROS_TESTNET_CHAIN_ID = 688689
```

### frontend/next.config.js

```js
const nextConfig = {
  transpilePackages: ['@pharos-dapp/shared'],
  serverExternalPackages: ['viem'],
}
```

### turbo.json

```json
{
  "pipeline": {
    "build": {
      "dependsOn": ["^build"],
      "outputs": [".next/**", "dist/**"]
    },
    "test": {},
    "contracts:build": {
      "outputs": ["out/**"]
    }
  }
}
```

### Verification

```bash
pnpm install
pnpm build              # builds all packages
pnpm --filter contracts exec "forge build"
pnpm --filter contracts exec "forge test --fork-url pharos_testnet"
pnpm --filter frontend exec "npm run build"
```

## When to Use

monorepo, workspace, Turborepo, pnpm workspace, shared package, workspace boundaries, package scripts, multi-package

## When NOT to Use

working within a single package (use the relevant feature subskill), or adding a single dependency (use dependency-upgrade-management)

## Prerequisites
- **Gate Fix**: Perform the mandatory "Gate Fix" check before proceeding.
- **Security**:
    - **.env Usage**: Environment variables MUST be stored in a `.env` file in the project root. NEVER use `export VAR=...` for sensitive data.
    - **Mandatory Check**: The Agent MUST check for the existence of `.env` and valid values (especially `PRIVATE_KEY` and `PHAROSSCAN_API_KEY`) before attempting any deployment or on-chain action.
    - **Git**: Ensure `.env` is listed in `.gitignore` to prevent accidental commits.

- **Git repository**: `git status` must succeed (run from repo root).
- **CI platform**: GitHub Actions configured (check `.github/workflows/` exists).
- **Foundry** (if workflows include forge commands): `forge build` must succeed.
## Workflow
- **Strict .env Check**: Verify `.env` exists in project root and contains `PRIVATE_KEY`, `PHAROSSCAN_API_KEY`, and required RPC URLs. Do NOT proceed if missing or if the user suggests using `export`.

1. **Requirement Gathering**: Analyze the user's request to identify the specific task, target environment (Atlantic 688689 or Pacific 1672), and any missing context. Zero-assumption delivery.
2. **Mandatory Plan (`PLAN.md`)**: Create or update `PLAN.md` in the project root with the proposed strategy. **Wait for explicit 'Approve' or 'Proceed' from the user before taking any action.**
3. Detect the user target network — Use `references/pharos-context.md` Network Detection table to determine if the user means testnet (688689, PHRS), mainnet (1672, PROS), or is ambiguous. If the user didn't specify, ask: 'Atlantic Testnet or Mainnet?' Adapt all following steps (RPC URLs, token symbols, deploy commands, chain IDs) to match.
4. Map the workspace structure and package boundaries.
5. Check prerequisites: verify required tools are installed, env vars are set, and any required context is available. Ask the user for any missing values before proceeding.
6. Identify the minimum workspace changes required.
7. Present the plan and ask for confirmation.
8. Apply the workspace changes and verify the affected packages.
## Output

- workspace map
- package boundary notes
- script changes
- verification result

## Examples

- "Organize this repo as a pnpm monorepo with Foundry contracts, Next.js frontend, and shared Pharos chain config for 1672"
- "Fix the workspace scripts so the app and contracts build together with transpilePackages for @pharos-dapp/shared"
- "Set up Turborepo caching for this Pharos monorepo's forge build and Next.js build pipeline"
- "Create a shared pharosChain.ts package consumed by both contracts and frontend"
- "Configure pnpm workspaces with contracts/ (forge build) and frontend/ (next build) and shared types"

## Verification

pnpm build across all packages or turbo run build. forge test --fork-url pharos_testnet from root.

## Related

dependency-upgrade-management (package version changes), repo-automation-and-tooling (workspace scripts)

## Gate


**Mode A:** Low risk — read-only map.

**Mode B:** Medium risk. Show the workspace change plan (files, deps, turbo tasks) before editing; verify build/test on touched packages after apply.
