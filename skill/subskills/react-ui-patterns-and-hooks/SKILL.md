---
name: pharos-react-ui-patterns-and-hooks
description: "Improve React hooks, component boundaries, and client-side UI patterns for Pharos dapps. Use when designing React hooks, component patterns, context, custom hooks, component composition, or UI patterns for Pharos web3 frontends. Keywords: React hooks, component pattern, context, state hook, UI patterns, custom hook, component design, composition, Pharos, dapp, Next.js, TypeScript, wagmi, viem, tailwind, shadcn."
metadata:
  audience: developer
  version: 1.2.0
  category: frontend
slash: true
---

# React UI Patterns and Hooks

Improve React hooks, component boundaries, and client-side UI patterns.

## When to Use

React hooks, component pattern, context, state hook, UI patterns, custom hook, component design, React component, composition

## When NOT to Use

dapp-specific integration patterns (use wagmi-viem-dapp-workflow), or state management (use state-management-integration)

## Prerequisites
- **Gate Fix**: Perform the mandatory "Gate Fix" check before proceeding.
- **Security**:
    - **.env Usage**: Environment variables MUST be stored in a `.env` file in the project root. NEVER use `export VAR=...` for sensitive data.
    - **Mandatory Check**: The Agent MUST check for the existence of `.env` and valid values (especially `PRIVATE_KEY` and `PHAROSSCAN_API_KEY`) before attempting any deployment or on-chain action.
    - **Git**: Ensure `.env` is listed in `.gitignore` to prevent accidental commits.

- **Node.js**: >=18. Run `node --version` to verify.
- **pnpm**: installed. Run `pnpm --version` to verify (or npm/yarn if your project uses those).
- **Dependencies**: Run `pnpm install` (or `npm install`) before proceeding.
- **Chain config**: Pharos chain (mainnet 1672 / Atlantic Testnet 688689) must be configured in wagmi or viem. See `packages/shared/src/pharosChain.ts` for the canonical config.
- **RPC endpoint**: Ensure your app's RPC URL points to `$PHAROS_MAINNET_RPC_URL` (mainnet) or `$PHAROS_TESTNET_RPC_URL` (testnet).
- **Wallet**: A browser wallet (MetaMask, WalletConnect, etc.) with the Pharos network added for testing.
## Pharos-Specific Hook Patterns

### useBalance for PHRS Token (Pharos Mainnet, chainId: 1672)

```typescript
import { useBalance } from 'wagmi'

function usePhrsBalance(address: `0x${string}` | undefined) {
  return useBalance({
    address,
    chainId: 1672, // Pharos Mainnet
  })
}
```

### Wallet Connection for Pharos Chain

```typescript
import { createConfig, http } from 'wagmi'
import { mainnet, sepolia } from 'wagmi/chains'
import { injected, metaMask, walletConnect } from 'wagmi/connectors'

const pharosChain = {
  id: 1672,
  name: 'Pharos Mainnet',
  nativeCurrency: { name: 'PHRS', symbol: 'PHRS', decimals: 18 },
  rpcUrls: {
    public: { http: ['$PHAROS_MAINNET_RPC_URL'] },
    default: { http: ['$PHAROS_MAINNET_RPC_URL'] },
  },
  blockExplorers: {
    default: { name: 'PharosScan', url: 'https://www.pharosscan.xyz' },
  },
}

export const config = createConfig({
  chains: [pharosChain, mainnet, sepolia],
  connectors: [injected(), metaMask(), walletConnect({ projectId: '...' })],
  transports: {
    [pharosChain.id]: http('$PHAROS_MAINNET_RPC_URL'),
    [mainnet.id]: http(),
    [sepolia.id]: http(),
  },
})
```

### Transaction History via PharosScan API

```typescript
export function usePharosTransactionHistory(address: `0x${string}`) {
  const [txns, setTxns] = useState<Transaction[]>([])
  useEffect(() => {
    fetch(`https://api.pharosscan.xyz/api?module=account&action=txlist&address=${address}`)
      .then(r => r.json())
      .then(data => setTxns(data.result || []))
  }, [address])
  return txns
}
```

### Token Balance Display Component

```tsx
export function PhrsBalanceCard({ address }: { address: `0x${string}` }) {
  const { isConnected } = useAccount()
  const { data: balance, isLoading } = usePhrsBalance(address)

  if (!isConnected) return <WalletConnectButton />
  if (isLoading) return <Skeleton className="h-16 w-48" />

  return (
    <Card>
      <CardHeader><CardTitle>PHRS Balance</CardTitle></CardHeader>
      <CardContent>
        <p className="text-2xl font-bold">{formatEther(balance?.value || 0n)} PHRS</p>
      </CardContent>
    </Card>
  )
}
```

### Network Switcher

```tsx
export function PharosNetworkSwitcher() {
  const { switchChain } = useSwitchChain()
  const { chain } = useAccount()

  return (
    <Select onValueChange={(id) => switchChain({ chainId: Number(id) })}>
      <SelectTrigger>
        <SelectValue placeholder={chain?.name || 'Select Network'} />
      </SelectTrigger>
      <SelectContent>
        <SelectItem value="1672">Pharos Mainnet</SelectItem>
        <SelectItem value="11155111">Sepolia</SelectItem>
      </SelectContent>
    </Select>
  )
}
```

### usePharosBalance with viem (Direct RPC)

```typescript
import { createPublicClient, http, formatEther } from 'viem'
import { useQuery } from '@tanstack/react-query'

const pharosChain = {
  id: 1672,
  name: 'Pharos Mainnet',
  nativeCurrency: { name: 'PHRS', symbol: 'PHRS', decimals: 18 },
  rpcUrls: { default: { http: ['$PHAROS_MAINNET_RPC_URL'] } },
}

const publicClient = createPublicClient({
  chain: pharosChain,
  transport: http('$PHAROS_MAINNET_RPC_URL'),
})

const PHRS_TOKEN_ADDRESS = '0x...PHRS_TOKEN_ADDRESS'

export function usePharosBalance(address: `0x${string}` | undefined) {
  return useQuery({
    queryKey: ['pharos-balance', address],
    queryFn: async () => {
      if (!address) return 0n
      const balance = await publicClient.getBalance({ address })
      const tokenBalance = await publicClient.readContract({
        address: PHRS_TOKEN_ADDRESS,
        abi: [{ name: 'balanceOf', type: 'function', inputs: [{ name: 'account', type: 'address' }], outputs: [{ name: '', type: 'uint256' }], stateMutability: 'view' }],
        functionName: 'balanceOf',
        args: [address],
      })
      return { native: balance, token: tokenBalance as bigint }
    },
    refetchInterval: 10_000,
  })
}
```

### useTransactionStatus (Pharos Testnet RPC Polling)

```typescript
import { createPublicClient, http } from 'viem'
import { useQuery } from '@tanstack/react-query'

const pharosTestnet = {
  id: 688689,
  name: 'Pharos Atlantic Testnet',
  nativeCurrency: { name: 'PHRS', symbol: 'PHRS', decimals: 18 },
  rpcUrls: { default: { http: ['$PHAROS_TESTNET_RPC_URL'] } },
}

const testnetClient = createPublicClient({
  chain: pharosTestnet,
  transport: http('$PHAROS_TESTNET_RPC_URL'),
})

export function useTransactionStatus(hash: `0x${string}` | undefined) {
  return useQuery({
    queryKey: ['tx-status', hash],
    queryFn: async () => {
      if (!hash) return null
      const receipt = await testnetClient.getTransactionReceipt({ hash })
      return {
        status: receipt.status === 'success' ? 'confirmed' : 'failed',
        blockNumber: receipt.blockNumber,
        gasUsed: receipt.gasUsed,
      }
    },
    refetchInterval: (query) => (query.state.data?.status === 'confirmed' || query.state.data?.status === 'failed' ? false : 3_000),
    enabled: !!hash,
  })
}
```

### PharosChainProvider (Context Provider for Chain State)

```typescript
import { createContext, useContext } from 'react'
import { type Chain, createPublicClient, http } from 'viem'

interface PharosChainContextType {
  mainnet: Chain
  testnet: Chain
  mainnetClient: ReturnType<typeof createPublicClient>
  testnetClient: ReturnType<typeof createPublicClient>
}

const pharosMainnet: Chain = {
  id: 1672,
  name: 'Pharos Mainnet',
  nativeCurrency: { name: 'PHRS', symbol: 'PHRS', decimals: 18 },
  rpcUrls: { default: { http: ['$PHAROS_MAINNET_RPC_URL'] } },
  blockExplorers: { default: { name: 'PharosScan', url: 'https://www.pharosscan.xyz' } },
}

const pharosTestnet: Chain = {
  id: 688689,
  name: 'Pharos Atlantic Testnet',
  nativeCurrency: { name: 'PHRS', symbol: 'PHRS', decimals: 18 },
  rpcUrls: { default: { http: ['$PHAROS_TESTNET_RPC_URL'] } },
  blockExplorers: { default: { name: 'PharosScan', url: 'https://www.pharosscan.xyz' } },
}

const PharosChainContext = createContext<PharosChainContextType | null>(null)

export function PharosChainProvider({ children }: { children: React.ReactNode }) {
  const mainnetClient = createPublicClient({ chain: pharosMainnet, transport: http('$PHAROS_MAINNET_RPC_URL') })
  const testnetClient = createPublicClient({ chain: pharosTestnet, transport: http('$PHAROS_TESTNET_RPC_URL') })

  return (
    <PharosChainContext.Provider value={{ mainnet: pharosMainnet, testnet: pharosTestnet, mainnetClient, testnetClient }}>
      {children}
    </PharosChainContext.Provider>
  )
}

export function usePharosChain() {
  const ctx = useContext(PharosChainContext)
  if (!ctx) throw new Error('usePharosChain must be used within PharosChainProvider')
  return ctx
}
```

### useContractEvents (Pharos Contract ABI Patterns)

```typescript
import { useQuery } from '@tanstack/react-query'
import { usePharosChain } from './PharosChainProvider'

export function useContractEvents(
  address: `0x${string}`,
  eventName: string,
  abi: readonly unknown[],
  fromBlock: bigint = 0n,
) {
  const { mainnetClient } = usePharosChain()

  return useQuery({
    queryKey: ['contract-events', address, eventName, fromBlock.toString()],
    queryFn: () =>
      mainnetClient.getLogs({
        address,
        event: abi.find((entry: any) => entry.type === 'event' && entry.name === eventName) as any,
        fromBlock,
        toBlock: 'latest',
      }),
    refetchInterval: 15_000,
  })
}
```

### useWatchContractEvent (WebSocket Subscription)

```typescript
import { useEffect, useRef } from 'react'
import { createPublicClient, webSocket, type Address, type Log } from 'viem'
import { pharosMainnet } from '@/lib/chains/pharos'
import { erc20Abi } from 'viem' // viem built-in ERC-20 ABI

const wsClient = createPublicClient({
  chain: pharosMainnet,
  transport: webSocket('wss://rpc.pharos.xyz/ws'), // Pharos WS endpoint
})

export function useWatchPharosTransfer(
  tokenAddress: Address,
  onTransfer: (log: Log) => void,
) {
  const callbackRef = useRef(onTransfer)
  callbackRef.current = onTransfer

  useEffect(() => {
    const unwatch = wsClient.watchContractEvent({
      address: tokenAddress,
      abi: erc20Abi,
      eventName: 'Transfer',
      onLogs: (logs) => {
        for (const log of logs) {
          callbackRef.current(log)
        }
      },
      onError: (err) => console.error('Pharos WS error:', err),
    })
    return () => unwatch()
  }, [tokenAddress])
}
```

### usePhrsBalance (Parameterized by Address)

```typescript
import { useBalance } from 'wagmi'
import { pharosMainnet } from '@/lib/chains/pharos'

export function usePhrsBalance(address: `0x${string}` | undefined) {
  return useBalance({
    address,
    chainId: pharosMainnet.id,
  })
}
```

## Workflow
- **Strict .env Check**: Verify `.env` exists in project root and contains `PRIVATE_KEY`, `PHAROSSCAN_API_KEY`, and required RPC URLs. Do NOT proceed if missing or if the user suggests using `export`.

1. **Requirement Gathering**: Analyze the user's request to identify the specific task, target environment (Atlantic 688689 or Pacific 1672), and any missing context. Zero-assumption delivery.
2. **Mandatory Plan (`PLAN.md`)**: Create or update `PLAN.md` in the project root with the proposed strategy. **Wait for explicit 'Approve' or 'Proceed' from the user before taking any action.**
3. Identify the state and rendering pattern that needs support.
4. Check prerequisites: verify Node.js/pnpm are installed, dependencies are installed, and network config is correct. Ask the user for any missing values before proceeding.
5. Suggest the smallest React pattern that fits the feature.
6. Present the plan and ask for approval before implementation.
7. Keep the component shape simple enough to maintain.
## Output

- hook plan
- component notes
- rendering notes
- follow-up suggestions

## Examples

- "Refine the usePharosStaking hook: deduplicate RPC calls, add error boundaries, handle wallet disconnection"
- "Design a state machine for PHRS staking tx: idle → pending (wallet) → confirming (on-chain) → success/reverted"
- "Create a usePharosBalance hook with auto-refresh every 12s (Pharos block time) and PharosScan fallback"
- "Build a PHRS token balance component using wagmi and shadcn/ui"
- "Create a transaction history hook using PharosScan API"

## Verification

npm run build and component rendering check.

## Related

state-management-integration (global state), frontend-dapp-integration (dapp-specific), tailwind-shadcn-ui-workflow (UI)

## Gate


Medium risk. Present hook split and file paths before moving wagmi calls out of components. Do not change transaction behavior or query keys without explicit approval.
