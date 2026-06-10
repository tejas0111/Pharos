---
name: pharos-accessibility-review
description: "Review Pharos dapp UI behavior for keyboard support, semantics, contrast, and screen-reader friendliness. Use when auditing accessibility, a11y, keyboard navigation, screen reader support, ARIA semantics, tab order, or focus management in Pharos web3 dapps. Keywords: accessibility, a11y, keyboard, screen reader, contrast, semantics, ARIA, tab order, focus management, accessible, Pharos, dapp, React, Next.js, Tailwind, shadcn."
metadata:
  audience: developer
  version: 1.2.0
  category: frontend
slash: true
---

# Accessibility Review

Review UI behavior for keyboard support, semantics, contrast, and screen-reader friendliness for Pharos dApps (wallet connect, tx lifecycle, staking forms, dashboards).

## Severity Rubric

| Severity | Definition |
|----------|-----------|
| **Critical** | User cannot complete a core task (stake, unstake, claim) — e.g., submit button unreachable by keyboard |
| **High** | User can complete the task but with significant friction (no focus indicator, no error announcement) |
| **Medium** | User can complete the task but experience is degraded (missing aria-labels, low-contrast hints) |
| **Low** | Minor polish (semantic heading order, redundant ARIA) |

## Web3-Specific A11y Patterns

### Transaction Lifecycle States

| State | A11y Requirement |
|-------|-----------------|
| `idle` | Submit button enabled, clear label e.g. "Stake PHRS" |
| `pending` (wallet) | `aria-disabled="true"` on button, screen reader: "Confirm transaction in your wallet" |
| `pending` (on-chain) | Loading spinner with `role="status"`, live region: "Transaction confirming... {{txHash}}" |
| `success` | `role="alert"` live region: "Successfully staked 100 PHRS. View on PharosScan." |
| `reverted` | `role="alert"` live region: "Transaction failed: {{reason}}. Try again." |

### Wallet Connect Modal

```tsx
<Dialog
  open={isOpen}
  onOpenChange={onClose}
  aria-label="Connect wallet to Pharos testnet"
>
  <DialogContent role="dialog" aria-modal="true">
    <WalletList role="listbox" aria-label="Select a wallet">
      {wallets.map(w => (
        <button key={w.id} role="option" aria-selected={false}>
          {w.name}
        </button>
      ))}
    </WalletList>
  </DialogContent>
</Dialog>
```

### Staking Form

```tsx
<form onSubmit={handleStake} aria-label="Stake PHRS">
  <label htmlFor="phrs-amount">PHRS amount</label>
  <Input
    id="phrs-amount"
    type="number"
    min="0"
    step="0.01"
    aria-describedby="phrs-balance"
  />
  <p id="phrs-balance">Your balance: {formatEther(balance)} PHRS</p>
  <Button
    aria-disabled={isPending}
    aria-busy={isPending}
  >
    {isPending ? "Confirming..." : "Stake"}
  </Button>
  {error && <p role="alert">{error.message}</p>}
</form>
```

### Dashboard Table

```tsx
<table role="table" aria-label="Your staking positions on Pharos testnet 688689">
  <thead>
    <tr>
      <th scope="col">Staked (PHRS)</th>
      <th scope="col">Rewards (PHRS)</th>
      <th scope="col">Status</th>
    </tr>
  </thead>
  <tbody>
    {positions.map(p => (
      <tr key={p.id}>
        <td>{formatEther(p.staked)}</td>
        <td>{formatEther(p.rewards)}</td>
        <td>
          <span role="status" aria-label={p.status === 'active' ? 'Earning rewards' : 'Unstaking'}>
            {p.status}
          </span>
        </td>
      </tr>
    ))}
  </tbody>
</table>
```

## When NOT to Use

- **General UI component design** — For component patterns, use `react-ui-patterns-and-hooks` or `tailwind-shadcn-ui-workflow`.
- **dApp-specific UI** — For wallet connect, tx flows, use `frontend-dapp-integration`.
- **Localization** — For i18n/copy, use `localization-and-copy`.

## Prerequisites
- **Gate Fix**: Perform the mandatory "Gate Fix" check before proceeding.
- **Security**: Private keys must be stored in `.env` and accessed via `${PRIVATE_KEY}`.

- **Node.js**: >=18. Run `node --version` to verify.
- **pnpm**: installed. Run `pnpm --version` to verify (or npm/yarn if your project uses those).
- **Dependencies**: Run `pnpm install` (or `npm install`) before proceeding.
- **Chain config**: Pharos chain (mainnet 1672 / Atlantic Testnet 688689) must be configured in wagmi or viem. See `packages/shared/src/pharosChain.ts` for the canonical config.
- **RPC endpoint**: Ensure your app's RPC URL points to `https://rpc.pharos.xyz` (mainnet) or `https://atlantic.dplabs-internal.com` (testnet).
- **Wallet**: A browser wallet (MetaMask, WalletConnect, etc.) with the Pharos network added for testing.
## Workflow

1. **Requirement Gathering**: Analyze the user's request to identify the specific task, target environment (Atlantic 688689 or Pacific 1672), and any missing context. Zero-assumption delivery.
2. **Mandatory Plan (`PLAN.md`)**: Create or update `PLAN.md` in the project root with the proposed strategy. **Wait for explicit 'Approve' or 'Proceed' from the user before taking any action.**
3. Detect the user target network — Use `references/pharos-context.md` Network Detection table to determine if the user means testnet (688689, PHRS), mainnet (1672, PROS), or is ambiguous. If the user didn't specify, ask: 'Atlantic Testnet or Mainnet?' Adapt all following steps (RPC URLs, token symbols, deploy commands, chain IDs) to match.
4. Review the UI states and user flows for a11y compliance.
5. Check prerequisites: verify Node.js/pnpm are installed, dependencies are installed, and network config is correct. Ask the user for any missing values before proceeding.
6. Identify the components and interactions requiring a11y review.
7. Present the plan and ask for approval before implementation.
8. Run the a11y checks and document findings.
## Examples

- "Review accessibility of the PHRS staking form on Pharos testnet 688689"
- "Audit the wallet connect modal for keyboard navigation and screen reader support"
- "Check tx status component (pending → success → reverted) for live region announcements"
- "Review shadcn/ui Dialog, Button, Input, Table components used in a Pharos dApp"

## Verification

Tab through every interactive element. Run axe-core: `npx axe <url>`. Lighthouse a11y audit in Chrome DevTools. Verify live regions announce tx state transitions.
## Gate

High risk — two-phase execution required:

**Phase 1 — Plan (present freely):**
- Draft the `PLAN.md` with the full implementation strategy, environment-aware safeguards, and verification steps.
- Present the full severity report with WCAG violations, affected components, and fix recommendations — show the complete audit
- Wait for explicit 'Approve' or 'Proceed' from the user.

**Phase 2 — Execute (wait for approval):**
- Execute the approved plan from `PLAN.md`.
- Do NOT Change focus behavior, dialog mount order, aria-live text, or weaken focus trap / remove DialogTitle without alternative semantics
- Perform a final "Ready to Broadcast?" check for any high-risk on-chain actions.
- Wait for explicit user confirmation ("I approve", "proceed", "looks good") before taking any of the Phase 2 actions.