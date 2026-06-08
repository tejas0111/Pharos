---
name: pharos-wallet-and-transaction-ui
description: "Design wallet connection, transaction preview, status, and history screens that feel reliable. Use when the user says: wallet UI, transaction UI, preview, status screen, history, connection flow, wallet connect button, tx modal, transaction status. Do NOT use for: wiring contract reads/writes (use frontend-dapp-integration), or designing general UI patterns (use react-ui-patterns-and-hooks). See also: frontend-dapp-integration (data wiring), react-ui-patterns-and-hooks (component patterns), wagmi-viem-dapp-workflow (wallet connection)."
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
