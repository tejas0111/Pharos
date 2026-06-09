---
name: pharos-monorepo-workspace-management
description: "Handle workspace boundaries, package scripts, and shared tooling in Pharos monorepos. Use when managing monorepos, Turborepo, pnpm workspaces, shared packages, workspace boundaries, package scripts, or multi-package setups for Pharos dapps. Keywords: monorepo, workspace, Turborepo, pnpm workspace, shared package, workspace boundaries, package scripts, multi-package, Pharos, Solidity, TypeScript, Next.js, Foundry, Hardhat."
metadata:
  audience: developer
  version: 1.1.0
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
  rpcUrls: { default: { http: ['https://rpc.pharos.xyz'] } },
  blockExplorers: { default: { name: 'PharosScan', url: 'https://pharosscan.xyz' } },
})

export const pharosTestnet = defineChain({
  id: 688689,
  name: 'Pharos Atlantic Testnet',
  nativeCurrency: { name: 'PHRS', symbol: 'PHRS', decimals: 18 },
  rpcUrls: { default: { http: ['https://atlantic.dplabs-internal.com'] } },
  blockExplorers: { default: { name: 'PharosScan', url: 'https://pharosscan.xyz' } },
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
- **Security**: private keys must be stored in `.env` and accessed via `${PRIVATE_KEY}`.

- **Git repository**: `git status` must succeed (run from repo root).
- **CI platform**: GitHub Actions configured (check `.github/workflows/` exists).
- **CI secrets**: The following secrets must be set in your CI environment: `PHAROS_RPC_URL`, `PRIVATE_KEY`, `PHAROSSCAN_API_KEY`.
- **Foundry** (if workflows include forge commands): `forge build` must succeed.

## Workflow

0. Detect the user target network — Use `references/pharos-context.md` Network Detection table to determine if the user means testnet (688689, PHRS), mainnet (1672, PROS), or is ambiguous. If the user didn't specify, ask: 'Atlantic Testnet or Mainnet?' Adapt all following steps (RPC URLs, token symbols, deploy commands, chain IDs) to match.
1. Map the workspace structure and package boundaries.
2. Check prerequisites: verify required tools are installed, env vars are set, and any required context is available. Ask the user for any missing values before proceeding.
3. Identify the minimum workspace changes required.
4. Present the plan and ask for confirmation.
5. Apply the workspace changes and verify the affected packages.

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
