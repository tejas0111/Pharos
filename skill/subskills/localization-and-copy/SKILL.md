---
name: pharos-localization-and-copy
description: "Adjust Pharos dapp product copy, labels, and localization structure for clearer user-facing text. Use when handling localization, i18n, translation, microcopy, labels, strings, text content, locale setup, or multi-language support for Pharos web3 dapps. Keywords: localization, i18n, translation, copy, microcopy, labels, strings, text content, locale, multi-language, Pharos, dapp, Next.js, React, TypeScript."
metadata:
  audience: developer
  version: 1.2.0
  category: frontend
slash: true
---

# Localization and Copy

Adjust product copy, labels, and localization structure for Pharos dApps with staking, wallet connect, tx lifecycle, and dashboards.

## Pharos i18n Implementation (next-intl)

### Directory Structure

```
frontend/
├── messages/
│   ├── en.json
│   ├── ja.json
│   └── zh.json
├── i18n.ts
└── components/
    └── StakingForm.tsx
```

### English Locale (en.json)

```json
{
  "dashboard": {
    "title": "Staking Dashboard",
    "stakedBalance": "Staked: {amount} PHRS",
    "rewards": "Rewards: {amount} PHRS",
    "network": "Pharos Mainnet (1672)",
    "viewOnExplorer": "View on PharosScan"
  },
  "stakingForm": {
    "label": "PHRS Amount",
    "placeholder": "Enter PHRS amount to stake",
    "balance": "Balance: {amount} PHRS",
    "stake": "Stake",
    "unstake": "Unstake",
    "claimRewards": "Claim Rewards",
    "txPending": "Confirm transaction in your wallet...",
    "txConfirming": "Transaction confirming on Pharos...",
    "txSuccess": "Successfully staked {amount} PHRS!",
    "txReverted": "Transaction failed: {reason}"
  },
  "errors": {
    "networkSwitch": "Please switch to Pharos network (Chain ID: {chainId})",
    "walletConnect": "Please connect a wallet",
    "insufficientBalance": "Insufficient PHRS balance",
    "minStake": "Minimum stake is {min} PHRS",
    "generic": "Something went wrong. Please try again."
  },
  "wallet": {
    "connect": "Connect Wallet",
    "disconnect": "Disconnect",
    "connecting": "Connecting...",
    "wrongNetwork": "Wrong Network",
    "switchNetwork": "Switch to Pharos"
  }
}
```

### Japanese Locale (ja.json)

```json
{
  "dashboard": {
    "title": "ステーキングダッシュボード",
    "stakedBalance": "ステーク中: {amount} PHRS",
    "rewards": "報酬: {amount} PHRS",
    "network": "Pharos メインネット (1672)",
    "viewOnExplorer": "PharosScan で確認"
  },
  "stakingForm": {
    "label": "PHRS 数量",
    "placeholder": "ステークする PHRS 数量を入力",
    "balance": "残高: {amount} PHRS",
    "stake": "ステーク",
    "unstake": "アンステーク",
    "claimRewards": "報酬を受け取る",
    "txPending": "ウォレットでトランザクションを確認してください...",
    "txConfirming": "Pharos 上でトランザクションを確認中...",
    "txSuccess": "{amount} PHRS のステークが完了しました！",
    "txReverted": "トランザクションが失敗しました: {reason}"
  },
  "errors": {
    "networkSwitch": "Pharos ネットワークに切り替えてください (チェーンID: {chainId})",
    "walletConnect": "ウォレットを接続してください",
    "insufficientBalance": "PHRS 残高が不足しています",
    "minStake": "最低ステーク量は {min} PHRS です",
    "generic": "エラーが発生しました。もう一度お試しください。"
  },
  "wallet": {
    "connect": "ウォレットを接続",
    "disconnect": "切断",
    "connecting": "接続中...",
    "wrongNetwork": "ネットワークが違います",
    "switchNetwork": "Pharos に切り替え"
  }
}
```

### i18n.ts Setup

```typescript
import { getRequestConfig } from 'next-intl/server'

export default getRequestConfig(async ({ locale }) => ({
  messages: (await import(`../messages/${locale}.json`)).default
}))
```

## Pharos Copy Tone Guide

| Context | Tone | Example |
|---------|------|---------|
| Transaction success | Warm, confirmational | "Successfully staked 100 PHRS!" |
| Transaction pending | Informational, neutral | "Transaction confirming on Pharos..." |
| Transaction reverted | Clear cause, not alarmist | "Transaction failed: insufficient gas" |
| Wrong network | Directive, with chain ID | "Please switch to Pharos (Chain ID: 1672)" |
| Wallet connect | Action-oriented | "Connect Wallet" |
| Balance display | Minimal, precise | "Staked: 1,000.00 PHRS" |

## When NOT to Use

- **Accessibility review** — For inclusive language/ARIA, use `accessibility-review`.
- **Technical documentation** — For developer docs, use `docs-and-example-generation`.
- **UI component changes** — For component patterns, use `react-ui-patterns-and-hooks`.

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
## Workflow
- **Strict .env Check**: Verify `.env` exists in project root and contains `PRIVATE_KEY`, `PHAROSSCAN_API_KEY`, and required RPC URLs. Do NOT proceed if missing or if the user suggests using `export`.

1. **Requirement Gathering**: Analyze the user's request to identify the specific task, target environment (Atlantic 688689 or Pacific 1672), and any missing context. Zero-assumption delivery.
2. **Mandatory Plan (`PLAN.md`)**: Create or update `PLAN.md` in the project root with the proposed strategy. **Wait for explicit 'Approve' or 'Proceed' from the user before taking any action.**
3. Detect the user target network — Use `references/pharos-context.md` Network Detection table to determine if the user means testnet (688689, PHRS), mainnet (1672, PROS), or is ambiguous. If the user didn't specify, ask: 'Atlantic Testnet or Mainnet?' Adapt all following steps (RPC URLs, token symbols, deploy commands, chain IDs) to match.
4. Review the user-facing copy and identify localization needs.
5. Check prerequisites: verify Node.js/pnpm are installed, dependencies are installed, and network config is correct. Ask the user for any missing values before proceeding.
6. Map the locale structure and translation requirements.
7. Present the plan and ask for approval before implementation.
8. Implement the i18n setup and verify all strings render correctly.
## Examples

- "Add Japanese locale for Pharos staking dApp (PHRS, mainnet 1672, PharosScan links)"
- "Improve error messages for Pharos wallet connect and wrong-network scenarios"
- "Localize tx lifecycle strings (pending → confirming → success → reverted) into Chinese"
- "Set up next-intl for Pharos dApp with en/ja/zh locales and chain-aware network labels"

## Verification

Run the dApp with each locale. Verify all strings render correctly. Confirm network names and chain IDs are correct for each locale.
## Gate


Low risk. Present copy or key-structure plan first; apply wording after user confirms tone and terminology.
