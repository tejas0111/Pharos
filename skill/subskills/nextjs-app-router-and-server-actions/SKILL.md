---
name: pharos-nextjs-app-router-and-server-actions
description: "Handle Next.js App Router, route handlers, server actions, and RSC patterns for Pharos dapps. Use when building Next.js App Router layouts, load/error/not-found states, Server Actions calling Pharos contracts, route handlers proxying Pharos RPC, or SSR data fetching from Pharos chain 1672. Keywords: Next.js App Router, server actions, route handlers, RSC, layout, loading, error, not-found, Next.js, Pharos, dapp, React, TypeScript, wagmi, viem, pharos mainnet, chain 1672, pharos RPC, server components, client components, SSR, pharos contract"
metadata:
  audience: developer
  version: 1.1.0
  category: frontend
slash: true
---

# Next.js App Router and Server Actions (Pharos)

Handle Next.js App Router, route handlers, server actions, and RSC patterns for Pharos dapps on chain 1672.

## When to Use

Next.js App Router, server actions, route handlers, RSC, Next.js, layout, loading.tsx, error.tsx, not-found.tsx, Pharos mainnet (chain 1672), Pharos RPC (https://rpc.pharos.xyz), wagmi provider config for Pharos, viem client for Pharos, SSR balance fetch from Pharos, Pharos contract reads via Server Actions

## When NOT to Use

Pages Router projects (this subskill is App Router only), or general React patterns (use react-ui-patterns-and-hooks)

## Prerequisites
- **Gate Fix**: Perform the mandatory "Gate Fix" check before proceeding.
- **Security**: private keys must be stored in `.env` and accessed via `${PRIVATE_KEY}`.

- **Node.js**: >=18. Run `node --version` to verify.
- **pnpm**: installed. Run `pnpm --version` to verify (or npm/yarn if your project uses those).
- **Dependencies**: Run `pnpm install` (or `npm install`) before proceeding.
- **Chain config**: Pharos chain (mainnet 1672 / Atlantic Testnet 688689) must be configured in wagmi or viem. See `packages/shared/src/pharosChain.ts` for the canonical config.
- **RPC endpoint**: Ensure your app's RPC URL points to `https://rpc.pharos.xyz` (mainnet) or `https://atlantic.dplabs-internal.com` (testnet).
- **Wallet**: A browser wallet (MetaMask, WalletConnect, etc.) with the Pharos network added for testing.

## Workflow

0. Detect the user target network — Use `references/pharos-context.md` Network Detection table to determine if the user means testnet (688689, PHRS), mainnet (1672, PROS), or is ambiguous. If the user didn't specify, ask: 'Atlantic Testnet or Mainnet?' Adapt all following steps (RPC URLs, token symbols, deploy commands, chain IDs) to match.
1. Map the route, server, and client boundaries.
2. Check prerequisites: verify Node.js/pnpm are installed, dependencies are installed, and network config is correct. Ask the user for any missing values before proceeding.
3. Choose the minimal App Router pattern that fits the feature.
4. Always use Pharos mainnet chain config (chain ID 1672, RPC https://rpc.pharos.xyz) for web3 integrations.
5. Present the plan and ask for approval before implementation.
6. Verify the app structure or runtime behavior after the change.

## Output

- route plan with Pharos chain boundaries
- component boundary notes (Server vs Client for Pharos data)
- server action notes (viem publicClient with Pharos RPC)
- route handler examples (Pharos contract proxy)
- verification result

## Examples

- "Add a Next.js App Router layout with wagmi provider configured for Pharos mainnet (chain 1672)"
- "Design a Server Action that reads contract state via viem publicClient({ chain: pharosMainnet, transport: http('https://rpc.pharos.xyz') })"
- "Build a Route Handler at app/api/contract/route.ts that proxies Pharos contract read calls"
- "Create a Server Component that fetches PHRS balance during SSR using viem"
- "Set up parallel routes and intercepting routes for a multi-step dapp wizard"

## Patterns

### Root Layout with Wagmi Provider (Pharos Mainnet)

```tsx
// app/layout.tsx
import { WagmiProvider, createConfig, http } from 'wagmi'
import { QueryClient, QueryClientProvider } from '@tanstack/react-query'
import { pharosMainnet } from '@/lib/chains/pharos'

const config = createConfig({
  chains: [pharosMainnet],
  transports: { [pharosMainnet.id]: http('https://rpc.pharos.xyz') },
})

const queryClient = new QueryClient()

export default function RootLayout({ children }: { children: React.ReactNode }) {
  return (
    <html lang="en">
      <body>
        <WagmiProvider config={config}>
          <QueryClientProvider client={queryClient}>
            {children}
          </QueryClientProvider>
        </WagmiProvider>
      </body>
    </html>
  )
}
```

### Pharos Chain Config

```ts
// lib/chains/pharos.ts
import { defineChain } from 'viem'

export const pharosMainnet = defineChain({
  id: 1672,
  name: 'Pharos Mainnet',
  nativeCurrency: { name: 'PHRS', symbol: 'PHRS', decimals: 18 },
  rpcUrls: {
    default: { http: ['https://rpc.pharos.xyz'] },
    public: { http: ['https://rpc.pharos.xyz'] },
  },
  blockExplorers: {
    default: { name: 'PharosScan', url: 'https://pharosscan.xyz' },
  },
})
```

### Server Action Reading Pharos Contract

```ts
// app/actions/contract.ts
'use server'

import { createPublicClient, http } from 'viem'
import { pharosMainnet } from '@/lib/chains/pharos'

const client = createPublicClient({
  chain: pharosMainnet,
  transport: http('https://rpc.pharos.xyz'),
})

// Balance read (native PHRS)
export async function readPhrsBalance(address: `0x${string}`) {
  try {
    const balance = await client.getBalance({ address })
    return { balance: balance.toString(), error: null }
  } catch (e) {
    return { balance: null, error: 'Failed to read Pharos contract. Check RPC and address.' }
  }
}

// Contract state read (readContract)
const PHAROS_CONTRACT = '0xYourContractAddress';
const ABI = [
  {
    name: 'totalSupply',
    type: 'function',
    stateMutability: 'view',
    inputs: [],
    outputs: [{ type: 'uint256', name: '' }],
  },
  {
    name: 'balanceOf',
    type: 'function',
    stateMutability: 'view',
    inputs: [{ type: 'address', name: 'account' }],
    outputs: [{ type: 'uint256', name: '' }],
  },
] as const;

export async function readContractState(address: `0x${string}`) {
  try {
    const totalSupply = await client.readContract({
      address: PHAROS_CONTRACT,
      abi: ABI,
      functionName: 'totalSupply',
    });
    const balance = await client.readContract({
      address: PHAROS_CONTRACT,
      abi: ABI,
      functionName: 'balanceOf',
      args: [address],
    });
    return { totalSupply: totalSupply.toString(), balance: balance.toString(), error: null };
  } catch (e) {
    return { totalSupply: null, balance: null, error: 'Contract read failed on Pharos' };
  }
}
```

### Route Handler Proxying Pharos Contract Read

```ts
// app/api/contract/route.ts
import { createPublicClient, http, getAddress } from 'viem'
import { pharosMainnet } from '@/lib/chains/pharos'
import { NextResponse } from 'next/server'

const client = createPublicClient({
  chain: pharosMainnet,
  transport: http('https://rpc.pharos.xyz'),
})

export async function GET(request: Request) {
  const { searchParams } = new URL(request.url)
  const address = searchParams.get('address')

  if (!address) {
    return NextResponse.json({ error: 'address query param required' }, { status: 400 })
  }

  try {
    const balance = await client.getBalance({ address: getAddress(address) })
    return NextResponse.json({ address, balance: balance.toString() })
  } catch {
    return NextResponse.json({ error: 'Pharos RPC call failed' }, { status: 502 })
  }
}
```

### Server Component Fetching PHRS Balance (SSR)

```tsx
// app/page.tsx
import { createPublicClient, http } from 'viem'
import { pharosMainnet } from '@/lib/chains/pharos'

const client = createPublicClient({
  chain: pharosMainnet,
  transport: http('https://rpc.pharos.xyz'),
})

export default async function Home() {
  const phrsBalance = await client.getBalance({ address: '0x...' })

  return (
    <main>
      <h1>Pharos Dapp</h1>
      <p>PHRS Balance: {phrsBalance.toString()}</p>
    </main>
  )
}
```

### Client Component Using Wagmi Hooks (Pharos Chain)

```tsx
// app/balance.tsx
'use client'

import { useBalance } from 'wagmi'
import { pharosMainnet } from '@/lib/chains/pharos'

export function PharosBalance({ address }: { address: `0x${string}` }) {
  const { data, isLoading, error } = useBalance({
    address,
    chainId: pharosMainnet.id,
  })

  if (isLoading) return <div>Loading PHRS balance...</div>
  if (error) return <div>Error fetching balance: {error.message}</div>

  return <div>PHRS: {data?.formatted ?? '0'}</div>
}
```

### Wallet Connection (Client Component)

```tsx
// app/wallet-button.tsx
'use client'

import { useAccount, useConnect, useDisconnect } from 'wagmi'

export function WalletButton() {
  const { address, isConnected } = useAccount()
  const { connectors, connect } = useConnect()
  const { disconnect } = useDisconnect()

  if (isConnected) {
    return (
      <div>
        <span>Connected: {address?.slice(0, 6)}...{address?.slice(-4)}</span>
        <button onClick={() => disconnect()}>Disconnect</button>
      </div>
    )
  }

  return (
    <div>
      {connectors.map((connector) => (
        <button key={connector.id} onClick={() => connect({ connector })}>
          Connect {connector.name}
        </button>
      ))}
    </div>
  )
}
```

### Dynamic Import for Wagmi Components

```tsx
// app/page.tsx
import dynamic from 'next/dynamic'

const WalletButton = dynamic(() => import('@/components/wallet-button'), { ssr: false })
const PharosBalance = dynamic(() => import('@/components/pharos-balance'), { ssr: false })

export default function Home() {
  return (
    <main>
      <WalletButton />
      <PharosBalance address="0x..." />
    </main>
  )
}
```

### next.config.js for Pharos Dapp

```js
// next.config.js
/** @type {import('next').NextConfig} */
const nextConfig = {
  images: {
    remotePatterns: [
      { protocol: 'https', hostname: 'pharosscan.xyz' },
    ],
  },
  // Allow Pharos RPC origin if needed for server-side fetch
  serverExternalPackages: ['viem'],
}

module.exports = nextConfig
```

## Error Handling

- Server Actions calling Pharos RPC must wrap viem calls in try/catch and return structured `{ data, error }` responses.
- Route handlers proxying Pharos should return `502 Bad Gateway` on RPC failure.
- Client components using wagmi hooks handle loading/error states natively; always check `isLoading` and `error` before rendering.
- Consider Pharos RPC rate limits — cache frequent reads with React's `cache()` or `unstable_cache`.

## Tips

- Pharos block time (~2s) makes Server-Sent Events (SSE) viable for real-time contract state updates via Route Handlers.
- Use `next/dynamic` with `ssr: false` for heavy wagmi components to avoid SSR mismatches.
- Prefer Server Components for initial data fetch (SSR) and Client Components for interactive reads.
- The Pharos testnet (if applicable) uses a different chain ID — verify environment before deploying.
- **Package deps**: `npm i wagmi viem @tanstack/react-query`
- **ABI typing**: Use `wagmi generate` with Pharos contract address to get typed hooks: `npx wagmi generate --config wagmi.config.ts`
- **Cache contract reads** with `unstable_cache` from `next/cache` to avoid hitting Pharos RPC rate limits on every request
- **Wallet connection**: Use `useConnect`, `useAccount`, and `useDisconnect` from `wagmi` (client component with `'use client'`)

## Verification

npm run build and manual route navigation. Verify balance renders, Server Actions return data, and Route Handler returns JSON from Pharos RPC.

## Related

react-ui-patterns-and-hooks (client components), wagmi-viem-dapp-workflow (contract integration)

## Gate


Low risk. Present route and boundary plan first; implement after user confirms server vs client split.
