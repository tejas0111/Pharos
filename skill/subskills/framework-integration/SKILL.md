---
name: pharos-framework-integration
description: "Wire Pharos development patterns into Next.js, wagmi, viem, ethers, Foundry, Hardhat, or Remix. Use when setting up framework integration, adding Pharos to existing projects, configuring toolchains, or initializing development environments for Pharos dapps. Keywords: Next.js, Wagmi, Viem, ethers, Foundry, Hardhat, Remix, framework setup, add Pharos, configure, integration setup, Pharos, 688689, 1672, Atlantic, Pacific, RPC, toolchain."
metadata:
  audience: developer
  version: 1.2.0
  category: tooling
slash: true
---

# Framework Integration

Wire Pharos development patterns into Next.js, wagmi, viem, ethers, Foundry, Hardhat, or Remix.

## When to Use

Next.js, Wagmi, Viem, ethers, Foundry, Hardhat, Remix, framework setup, add Pharos to, configure, integration setup

## When NOT to Use

working within an already-configured framework (use the workflow-specific subskill, e.g., wagmi-viem-dapp-workflow)

## Prerequisites
- **Gate Fix**: Perform the mandatory "Gate Fix" check before proceeding.
- **Security**:
    - **.env Usage**: Environment variables MUST be stored in a `.env` file in the project root. NEVER use `export VAR=...` for sensitive data.
    - **Mandatory Check**: The Agent MUST verify `.env` exists and variables are set using `grep -q` (NEVER `cat`, `head`, `tail` — those expose secrets) before any deployment or on-chain action.
    - **Git**: Ensure `.env` is listed in `.gitignore` to prevent accidental commits.

- **Node.js**: >=18. Run `node --version` to verify.
- **pnpm**: installed. Run `pnpm --version` to verify (or npm/yarn if your project uses those).
- **Dependencies**: Run `pnpm install` (or `npm install`) before proceeding.
- **Chain config**: Pharos chain (mainnet 1672 / Atlantic Testnet 688689) must be configured in wagmi or viem. See `shared/pharosChain.ts` for the canonical config.
- **RPC endpoint**: Ensure your app's RPC URL points to `$PHAROS_MAINNET_RPC_URL` (mainnet) or `$PHAROS_TESTNET_RPC_URL` (testnet).
- **Wallet**: A browser wallet (MetaMask, WalletConnect, etc.) with the Pharos network added for testing.
## Workflow
- **Strict .env Check**: Confirm `.env` exists with `test -f .env` and check variables via `grep -q` (without printing values). NEVER print `.env` contents. Do NOT proceed if missing or if the user suggests `export`.

1. **Requirement Gathering**: Analyze the user's request to identify the specific task, target environment (Atlantic 688689 or Pacific 1672), and any missing context. Zero-assumption delivery.
2. **Mandatory Plan (`PLAN.md`)**: Create or update `PLAN.md` in the project root with the proposed strategy. **Wait for explicit 'Approve' or 'Proceed' from the user before taking any action.**
3. Detect the framework and current app shape.
4. Check prerequisites: verify Node.js/pnpm are installed, dependencies are installed, and network config is correct. Ask the user for any missing values before proceeding.
5. Map the minimal integration changes and config updates.
6. Present the plan and ask for approval before implementation.
7. Verify the integration with the smallest useful build or config check.
## Output

- integration checklist
- config changes
- setup steps
- verification command

## Examples

- "Add Wagmi and Viem wiring to this Next.js app with RainbowKit provider"
- "Prepare a Foundry project for contract development on Pharos using foundry.toml"
- "Configure Hardhat with Pharos network definitions for chain ID 1672 and 688689"
- "Set up RainbowKit, wagmi, and viem in a new Next.js 14 App Router project targeting Pharos mainnet"
- "Add Pharos chain config to an existing RainbowKit dapp"

## Pharos Chain Reference

Mainnet and Testnet chain configuration shared across all frameworks:

```typescript
const pharosMainnet = {
  chainId: 1672,
  name: 'Pharos Mainnet',
  rpcUrl: '$PHAROS_MAINNET_RPC_URL',
  nativeCurrency: { name: 'PHRS', symbol: 'PHRS', decimals: 18 },
  explorer: 'https://www.pharosscan.xyz',
}

const pharosTestnet = {
  chainId: 688689,
  name: 'Pharos Testnet',
  rpcUrl: '$PHAROS_TESTNET_RPC_URL',
  nativeCurrency: { name: 'PHRS', symbol: 'PHRS', decimals: 18 },
  explorer: 'https://www.pharosscan.xyz',
}
```

## ethers.js Setup

```typescript
import { ethers } from 'ethers'

const provider = new ethers.JsonRpcProvider('$PHAROS_MAINNET_RPC_URL', {
  chainId: 1672,
  name: 'pharos-mainnet',
})

const signer = new ethers.Wallet('PRIVATE_KEY', provider)

const contract = new ethers.Contract(
  '0xYourPharosContractAddress',
  ['function balanceOf(address owner) view returns (uint256)'],
  provider
)

const balance = await contract.balanceOf('0xUserAddress')
```

## Viem Client

```typescript
import { createPublicClient, http } from 'viem'
import { defineChain } from 'viem'

const pharosMainnet = defineChain({
  id: 1672,
  name: 'Pharos Mainnet',
  nativeCurrency: { name: 'PHRS', symbol: 'PHRS', decimals: 18 },
  rpcUrls: { default: { http: ['$PHAROS_MAINNET_RPC_URL'] } },
  blockExplorers: { default: { name: 'PharosScan', url: 'https://www.pharosscan.xyz' } },
})

const publicClient = createPublicClient({
  chain: pharosMainnet,
  transport: http('$PHAROS_MAINNET_RPC_URL'),
})

const blockNumber = await publicClient.getBlockNumber()
```

## Wagmi Config

See the full wagmi-viem-dapp-workflow subskill for complete `createConfig` with connectors and hooks. Minimal integration:

```typescript
import { createConfig, http } from 'wagmi'
import { pharosMainnet, pharosTestnet } from './pharosChain'

export const config = createConfig({
  chains: [pharosMainnet, pharosTestnet],
  transports: {
    [pharosMainnet.id]: http('$PHAROS_MAINNET_RPC_URL'),
    [pharosTestnet.id]: http('$PHAROS_TESTNET_RPC_URL'),
  },
})
```

## RainbowKit + Wagmi Setup (Next.js App Router)

```bash
npm i @rainbow-me/rainbowkit wagmi viem @tanstack/react-query
```

### Provider (app/providers.tsx)

```tsx
'use client'

import { WagmiProvider, http } from 'wagmi'
import { QueryClient, QueryClientProvider } from '@tanstack/react-query'
import { RainbowKitProvider, getDefaultConfig } from '@rainbow-me/rainbowkit'
import { defineChain } from 'viem'
import '@rainbow-me/rainbowkit/styles.css'

const pharosMainnet = defineChain({
  id: 1672,
  name: 'Pharos Mainnet',
  nativeCurrency: { name: 'PHRS', symbol: 'PHRS', decimals: 18 },
  rpcUrls: { default: { http: ['$PHAROS_MAINNET_RPC_URL'] } },
  blockExplorers: { default: { name: 'PharosScan', url: 'https://www.pharosscan.xyz' } },
})

const config = getDefaultConfig({
  appName: 'Pharos Dapp',
  projectId: process.env.NEXT_PUBLIC_WALLETCONNECT_PROJECT_ID!,
  chains: [pharosMainnet],
  transports: { [pharosMainnet.id]: http('$PHAROS_MAINNET_RPC_URL') },
  ssr: true,
})

const queryClient = new QueryClient()

export function Providers({ children }: { children: React.ReactNode }) {
  return (
    <WagmiProvider config={config}>
      <QueryClientProvider client={queryClient}>
        <RainbowKitProvider>{children}</RainbowKitProvider>
      </QueryClientProvider>
    </WagmiProvider>
  )
}
```

### Root Layout

```tsx
// app/layout.tsx
import { Providers } from './providers'

export default function RootLayout({ children }: { children: React.ReactNode }) {
  return (
    <html lang="en">
      <body>
        <Providers>{children}</Providers>
      </body>
    </html>
  )
}
```

### Connect Wallet Button

```tsx
// app/page.tsx
'use client'

import { ConnectButton } from '@rainbow-me/rainbowkit'

export default function Home() {
  return <ConnectButton />
}
```

### SSR Compatibility (next.config.js)

```js
// next.config.js
const nextConfig = {
  serverExternalPackages: ['viem'],
}
```

```typescript
// hardhat.config.ts
import '@nomicfoundation/hardhat-toolbox'

module.exports = {
  networks: {
    pharosMainnet: {
      url: '$PHAROS_MAINNET_RPC_URL',
      chainId: 1672,
      accounts: [process.env.PRIVATE_KEY],
    },
    pharosTestnet: {
      url: '$PHAROS_TESTNET_RPC_URL',
      chainId: 688689,
      accounts: [process.env.PRIVATE_KEY],
    },
  },
}
```

## Foundry Config

```toml
# foundry.toml
[rpc_endpoints]
pharos-mainnet = "$PHAROS_MAINNET_RPC_URL"
pharos-testnet = "$PHAROS_TESTNET_RPC_URL"

[etherscan]
pharos-mainnet = { key = "${ETHERSCAN_API_KEY}", url = "$PHAROSSCAN_MAINNET_API_URL" }
```

## Verification

npm run build or framework-specific config check.

## Related

wagmi-viem-dapp-workflow, foundry-hardhat-contract-workflow, nextjs-app-router-and-server-actions, remix-contract-workflow, tailwind-shadcn-ui-workflow

## Gate


Low risk. Present the plan and proceed once the user agrees.

### Anti-Generic Rules (framework-integration)
- Every chain config step MUST name the specific file path (e.g., `src/config/wagmi.ts`, `foundry.toml`, `hardhat.config.ts`).
- Every `defineChain` block MUST include chain IDs 688689 (testnet) or 1672 (mainnet) from pharos-context.md.
- Every install command MUST be exact (e.g., `npm install wagmi viem@2`, not generic "install deps").
- Verification MUST include both build check AND manual chain ID validation with `cast` or wallet switch.
- Do NOT suggest deprecated Atlantic (688689) unless the repo already targets it.
- Do NOT copy-paste RPC URLs from memory — always reference pharos-context.md canonical values.
