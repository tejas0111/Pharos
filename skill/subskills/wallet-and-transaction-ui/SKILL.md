---
name: pharos-wallet-and-transaction-ui
description: "Design Pharos dapp wallet connection, transaction preview, status, and history screens that feel reliable. Use when building wallet connect UI, transaction modals, tx status screens, transaction history, or connection flows for Pharos web3 dapps. Keywords: wallet UI, transaction UI, preview, status screen, history, wallet connect, tx modal, transaction status, wagmi, viem, ethers, Next.js, React, TypeScript, Pharos, web3, dapp."
metadata:
  audience: developer
  version: 1.0.0
  category: frontend
slash: true
---

# Wallet and Transaction UI

Design wallet connection, transaction preview, status, and history screens that feel reliable.

## When to Use

wallet UI, transaction UI, preview, status screen, history, connection flow, wallet connect button, tx modal, transaction status

## When NOT to Use

wiring contract reads/writes (use frontend-dapp-integration), or designing general UI patterns (use react-ui-patterns-and-hooks)

## Workflow

1. Identify the wallet states, transaction states, and error states.
2. Define the screen sequence and what each state shows.
3. Present the UI plan and ask for changes before implementation.
4. Build the smallest working state machine and verify the transitions.

## Output

- screen flow
- state machine
- copy plan
- error-state checklist

## Examples

- "Design a transaction preview modal with gas and risk details"
- "Create wallet status and history components for a dapp"
- "Build a wallet connection flow with loading, error, and connected states"

## Verification

Component renders all states (loading, success, error, empty) in browser or storybook.

## Related

frontend-dapp-integration (data wiring), react-ui-patterns-and-hooks (component patterns), wagmi-viem-dapp-workflow (wallet connection)
