---
name: pharos-tailwind-shadcn-ui-workflow
description: "Design and implement polished UI flows for Pharos dapps using Tailwind and shadcn/ui patterns. Use when building Tailwind CSS layouts, shadcn/ui components, design systems, DaisyUI, or utility-first CSS workflows for Pharos web3 frontends. Keywords: Tailwind, shadcn, UI workflow, design system, component styles, Tailwind CSS, shadcn/ui, DaisyUI, utility CSS, Pharos, dapp, Next.js, React, TypeScript."
metadata:
  audience: developer
  version: 1.2.0
  category: frontend
slash: true
---

# Tailwind and shadcn/ui Workflow

Design and implement polished UI flows using Tailwind and shadcn/ui patterns.

## When to Use

Tailwind, shadcn, UI workflow, design system, component styles, Tailwind CSS, shadcn/ui, DaisyUI, utility CSS

## When NOT to Use

logic or state wiring (use react-ui-patterns-and-hooks or frontend-dapp-integration), or contract code (use solidity-authoring)

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
## Shadcn/ui Theme Setup for Pharos

Configure your `globals.css` to use Pharos brand tokens:

```css
@tailwind base;
@tailwind components;
@tailwind utilities;

@layer base {
  :root {
    --background: 225 29% 6%;        /* pharos-deep #0A1628 */
    --foreground: 0 0% 100%;
    --card: 222 29% 13%;             /* pharos-navy #0F1D35 */
    --card-foreground: 0 0% 100%;
    --primary: 167 100% 42%;         /* pharos-accent #00D4AA */
    --primary-foreground: 225 29% 6%;
    --secondary: 222 29% 13%;
    --secondary-foreground: 0 0% 100%;
    --muted: 215 16% 47%;            /* pharos-muted #64748B */
    --muted-foreground: 215 16% 70%;
    --accent: 167 100% 42%;
    --accent-foreground: 225 29% 6%;
    --border: 215 16% 47% / 0.3;
    --radius: 0.75rem;
  }
}
```

## Pharos Brand Design Tokens

Extend your Tailwind config with Pharos brand colors:

```js
// tailwind.config.ts
export default {
  theme: {
    extend: {
      colors: {
        pharos: {
          deep: '#0A1628',      // primary background
          navy: '#0F1D35',      // card/surface background
          accent: '#00D4AA',    // primary accent / CTAs
          'accent-dim': '#00B894',
          gold: '#F0B90B',      // highlights / warnings
          muted: '#64748B',     // secondary text
          surface: '#1A2744',   // elevated surface
        },
      },
      fontFamily: {
        mono: ['JetBrains Mono', 'monospace'],
      },
    },
  },
}
```

## Pharos-Themed Shadcn/ui Components

### Transaction Status Card

```tsx
export function TransactionCard({ tx }: { tx: Transaction }) {
  const statusColor = tx.status === 'confirmed' ? 'bg-pharos-accent' : 'bg-yellow-500'
  return (
    <Card className="bg-pharos-navy border-pharos-muted/30">
      <CardHeader className="flex flex-row items-center gap-2">
        <div className={`h-2 w-2 rounded-full ${statusColor}`} />
        <CardTitle className="text-sm font-mono text-white">
          {tx.hash.slice(0, 10)}...{tx.hash.slice(-6)}
        </CardTitle>
      </CardHeader>
      <CardContent>
        <div className="flex justify-between text-sm">
          <span className="text-pharos-muted">Value:</span>
          <span className="text-white font-mono">{formatEther(BigInt(tx.value))} PHRS</span>
        </div>
        <div className="flex justify-between text-sm mt-1">
          <span className="text-pharos-muted">To:</span>
          <span className="text-white font-mono">{tx.to?.slice(0, 6)}...{tx.to?.slice(-4)}</span>
        </div>
      </CardContent>
      <CardFooter className="text-xs text-pharos-muted">
        <a href={`https://www.pharosscan.xyz/tx/${tx.hash}`} target="_blank" className="text-pharos-accent hover:underline">
          View on PharosScan →
        </a>
      </CardFooter>
    </Card>
  )
}
```

### Pharos Dashboard Card Layout

```tsx
export function PharosDashboard() {
  return (
    <div className="min-h-screen bg-pharos-deep text-white p-6">
      <header className="flex justify-between items-center mb-8">
        <h1 className="text-xl font-bold tracking-tight">Pharos Dashboard</h1>
        <PharosNetworkSwitcher />
      </header>
      <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
        <PhrsBalanceCard />
        <TransactionCard />
        <div className="bg-pharos-navy rounded-xl border border-pharos-muted/20 p-4">
          <h3 className="text-pharos-accent text-sm font-semibold mb-2">Network</h3>
          <p className="text-pharos-muted text-xs">Pharos Mainnet (1672)</p>
          <p className="text-white font-mono text-sm mt-1">RPC: rpc.pharos.xyz</p>
        </div>
      </div>
    </div>
  )
}
```

### Pharos NetworkSwitcher Component

```tsx
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from '@/components/ui/select'
import { useSwitchChain, useAccount } from 'wagmi'

export function PharosNetworkSwitcher() {
  const { switchChain } = useSwitchChain()
  const { chain } = useAccount()

  return (
    <Select onValueChange={(id) => switchChain({ chainId: Number(id) })}>
      <SelectTrigger className="w-44 bg-pharos-surface border-pharos-muted/30 text-white">
        <SelectValue placeholder={chain?.name || 'Select Network'} />
      </SelectTrigger>
      <SelectContent className="bg-pharos-navy border-pharos-muted/30 text-white">
        <SelectItem value="1672" className="focus:bg-pharos-surface focus:text-pharos-accent">
          <span className="flex items-center gap-2">
            <span className="h-2 w-2 rounded-full bg-pharos-accent" />
            Pharos Mainnet
          </span>
        </SelectItem>
        <SelectItem value="688689" className="focus:bg-pharos-surface focus:text-pharos-accent">
          <span className="flex items-center gap-2">
            <span className="h-2 w-2 rounded-full bg-yellow-500" />
            Pharos Testnet
          </span>
        </SelectItem>
      </SelectContent>
    </Select>
  )
}
```

### Transaction List Layout Pattern

```tsx
export function TransactionList({ txs }: { txs: Transaction[] }) {
  return (
    <Card className="bg-pharos-navy border-pharos-muted/30 col-span-2">
      <CardHeader>
        <CardTitle className="text-pharos-accent text-lg">Recent Transactions</CardTitle>
        <CardDescription className="text-pharos-muted">Latest activity on Pharos Mainnet</CardDescription>
      </CardHeader>
      <CardContent>
        <div className="space-y-2">
          {txs.map((tx) => (
            <div key={tx.hash} className="flex items-center justify-between p-3 rounded-lg bg-pharos-surface/50 border border-pharos-muted/10">
              <div className="flex items-center gap-3">
                <div className={`h-2 w-2 rounded-full ${tx.status === 'confirmed' ? 'bg-pharos-accent' : 'bg-yellow-500'}`} />
                <span className="font-mono text-sm text-white">{tx.hash.slice(0, 8)}...{tx.hash.slice(-6)}</span>
              </div>
              <span className="font-mono text-sm text-pharos-muted">{formatEther(BigInt(tx.value))} PHRS</span>
            </div>
          ))}
        </div>
      </CardContent>
      <CardFooter>
        <a href="https://www.pharosscan.xyz" target="_blank" className="text-pharos-accent text-sm hover:underline">View all on PharosScan</a>
      </CardFooter>
    </Card>
  )
}
```

### Balance Display with Skeleton Loading

```tsx
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card'
import { Skeleton } from '@/components/ui/skeleton'

export function PhrsBalanceDisplay({ balance, isLoading }: { balance?: bigint; isLoading: boolean }) {
  if (isLoading) {
    return (
      <Card className="bg-pharos-navy border-pharos-muted/30">
        <CardHeader><Skeleton className="h-4 w-24 bg-pharos-muted/50" /></CardHeader>
        <CardContent><Skeleton className="h-8 w-36 bg-pharos-muted/50" /></CardContent>
      </Card>
    )
  }
  return (
    <Card className="bg-gradient-to-br from-pharos-navy to-pharos-deep border-pharos-accent/20">
      <CardHeader>
        <CardTitle className="text-pharos-accent text-sm">PHRS Balance</CardTitle>
      </CardHeader>
      <CardContent>
        <p className="text-3xl font-bold text-white font-mono">{formatEther(balance || 0n)} <span className="text-pharos-accent">PHRS</span></p>
      </CardContent>
    </Card>
  )
}
```

## Wallet Connection Button (Pharos Themed)

```tsx
export function PharosConnectButton() {
  return (
    <ConnectButton.Custom>
      {({ account, chain, openConnectModal, openChainModal }) => (
        <>
          {chain?.id !== 1672 && chain?.unsupported && (
            <button onClick={openChainModal} className="bg-pharos-gold text-black px-4 py-2 rounded-lg text-sm font-semibold">
              Switch to Pharos
            </button>
          )}
          {!account ? (
            <button onClick={openConnectModal} className="bg-pharos-accent text-pharos-deep px-4 py-2 rounded-lg text-sm font-semibold hover:bg-pharos-accent-dim transition-colors">
              Connect Wallet
            </button>
          ) : (
            <span className="text-sm font-mono text-white bg-pharos-surface px-3 py-1 rounded-lg">
              {account.displayName}
            </span>
          )}
        </>
      )}
    </ConnectButton.Custom>
  )
}
```

### Button Variants (Pharos Themed)

```tsx
import { Button } from '@/components/ui/button'

export function PharosButtonExamples() {
  return (
    <div className="flex gap-2">
      <Button className="bg-pharos-accent text-pharos-deep hover:bg-pharos-accent-dim">Send PHRS</Button>
      <Button variant="outline" className="border-pharos-muted/40 text-pharos-accent hover:bg-pharos-surface">Cancel</Button>
      <Button variant="ghost" className="text-pharos-muted hover:text-white hover:bg-pharos-surface">Details</Button>
      <Button disabled className="bg-pharos-muted/30 text-pharos-muted">Disabled</Button>
    </div>
  )
}
```

### Input with PHRS Amount

```tsx
import { Input } from '@/components/ui/input'
import { Button } from '@/components/ui/button'

export function SendPhrsForm() {
  return (
    <div className="space-y-3">
      <label className="text-sm text-pharos-muted">Amount (PHRS)</label>
      <div className="relative">
        <Input
          type="number"
          placeholder="0.0"
          className="bg-pharos-surface border-pharos-muted/30 text-white pl-4 pr-16 py-6 text-lg"
        />
        <span className="absolute right-3 top-1/2 -translate-y-1/2 text-pharos-accent text-sm font-semibold">PHRS</span>
      </div>
      <Button className="w-full bg-pharos-accent text-pharos-deep hover:bg-pharos-accent-dim">Send</Button>
    </div>
  )
}
```

### Dialog for Send PHRS

```tsx
import { Dialog, DialogTrigger, DialogContent, DialogHeader, DialogTitle, DialogDescription, DialogFooter } from '@/components/ui/dialog'
import { Button } from '@/components/ui/button'
import { Input } from '@/components/ui/input'

export function SendPhrsDialog() {
  return (
    <Dialog>
      <DialogTrigger asChild>
        <Button className="bg-pharos-accent text-pharos-deep hover:bg-pharos-accent-dim">Send PHRS</Button>
      </DialogTrigger>
      <DialogContent className="bg-pharos-navy border-pharos-muted/30 text-white">
        <DialogHeader>
          <DialogTitle className="text-pharos-accent">Send PHRS</DialogTitle>
          <DialogDescription className="text-pharos-muted">Enter recipient address and amount</DialogDescription>
        </DialogHeader>
        <div className="space-y-3 py-4">
          <Input placeholder="Recipient address (0x...)" className="bg-pharos-surface border-pharos-muted/30 text-white" />
          <Input type="number" placeholder="Amount in PHRS" className="bg-pharos-surface border-pharos-muted/30 text-white" />
        </div>
        <DialogFooter>
          <Button variant="outline" className="border-pharos-muted/40 text-pharos-muted">Cancel</Button>
          <Button className="bg-pharos-accent text-pharos-deep hover:bg-pharos-accent-dim">Confirm</Button>
        </DialogFooter>
      </DialogContent>
    </Dialog>
  )
}
```

### Transaction Table (shadcn/ui Table)

```tsx
import { Table, TableHeader, TableRow, TableHead, TableBody, TableCell } from '@/components/ui/table'
import { Badge } from '@/components/ui/badge'

const statusColor = (s: string) => s === 'confirmed' ? 'bg-green-500' : s === 'pending' ? 'bg-yellow-500' : 'bg-red-500'

export function TransactionTable({ txs }: { txs: any[] }) {
  return (
    <Table>
      <TableHeader>
        <TableRow className="border-pharos-muted/20">
          <TableHead className="text-pharos-muted">Tx Hash</TableHead>
          <TableHead className="text-pharos-muted">Amount</TableHead>
          <TableHead className="text-pharos-muted">Status</TableHead>
          <TableHead className="text-pharos-muted">Time</TableHead>
        </TableRow>
      </TableHeader>
      <TableBody>
        {txs.map((tx) => (
          <TableRow key={tx.hash} className="border-pharos-muted/10 hover:bg-pharos-surface/50">
            <TableCell className="font-mono text-white text-sm">{tx.hash.slice(0, 10)}...</TableCell>
            <TableCell className="font-mono text-white">{formatEther(BigInt(tx.value))} PHRS</TableCell>
            <TableCell><Badge className={`${statusColor(tx.status)} text-white`}>{tx.status}</Badge></TableCell>
            <TableCell className="text-pharos-muted text-sm">{tx.timestamp}</TableCell>
          </TableRow>
        ))}
      </TableBody>
    </Table>
  )
}
```

## Workflow
- **Strict .env Check**: Verify `.env` exists in project root and contains `PRIVATE_KEY`, `PHAROSSCAN_API_KEY`, and required RPC URLs. Do NOT proceed if missing or if the user suggests using `export`.

1. **Requirement Gathering**: Analyze the user's request to identify the specific task, target environment (Atlantic 688689 or Pacific 1672), and any missing context. Zero-assumption delivery.
2. **Mandatory Plan (`PLAN.md`)**: Create or update `PLAN.md` in the project root with the proposed strategy. **Wait for explicit 'Approve' or 'Proceed' from the user before taking any action.**
3. Identify the UI surface and the design constraints.
4. Check prerequisites: verify Node.js/pnpm are installed, dependencies are installed, and network config is correct. Ask the user for any missing values before proceeding.
5. Choose the smallest Tailwind and shadcn/ui pattern that fits the task.
6. Present the plan and ask for approval before implementation.
7. Verify the component structure and styling outcome.
## Output

- UI plan
- component notes
- style notes
- verification hint

## Examples

- "Build a Tailwind and shadcn/ui flow for a wallet preview modal"
- "Design the UI component patterns for this Pharos dashboard"
- "Create a shadcn/ui component library for this dapp's design system"
- "Style a PHRS balance card with Pharos brand colors"
- "Build a transaction history list with PharosScan links"

## Verification

Visual check in browser. npm run build.

## Related

react-ui-patterns-and-hooks (logic), frontend-dapp-integration (contract wiring)

## Gate


Medium risk. Present dialog state machine and component paths before modifying `components/ui/*` or shared layout. Do not change confirm/submit behavior without user approval.


Low risk. Present the plan and proceed once the user agrees.

### Anti-Generic Rules (tailwind-shadcn-ui-workflow)
- Every component step MUST name the specific component path (e.g., `src/components/TxHistory.tsx`).
- Every shadcn/ui add command MUST include the component name (e.g., `npx shadcn@latest add dialog`).
- Verification MUST include both `pnpm exec tsc --noEmit` AND manual chain ID checks (688689/1672).
- Native token labels MUST use PROS (mainnet) or PHRS (testnet), never ETH or generic "native."
- Do NOT suggest generic Tailwind classes — name the specific utility or component pattern.
