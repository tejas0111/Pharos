# Pharos Power Skill Design

## Overview

`Pharos Power Skill` is a natural-language-first skill for AI agents that provides multi-wallet portfolio and ecosystem activity intelligence on Pharos. It is designed for Codex and Claude Code first, but remains portable to other agent frameworks by separating the natural-language interface from the structured output contract.

The hero workflow is investor-focused. A user provides up to 10 wallet addresses and a target network, and the skill returns a clear briefing of combined portfolio exposure, recent wallet activity, notable ecosystem interactions, overlap across wallets, simple risk or sanity flags, and suggested next actions.

The skill is read-first by default. It can optionally prepare and execute follow-up actions when a private key is configured, but execution is secondary to analysis and must remain explicitly gated.

## Goals

- Deliver a Pharos-specific investor intelligence skill rather than a generic EVM wallet checker.
- Support up to 10 wallets in a single run.
- Work on both Pharos mainnet and testnet.
- Accept natural-language prompts and map them into structured internal requests.
- Return both a human-readable briefing and a machine-readable payload.
- Support optional execution in two modes:
  - `safe mode` for constrained actions
  - `expert mode` for advanced custom writes with explicit opt-in

## Non-Goals

- Full protocol-wide DeFi decoding across the entire ecosystem in V1.
- Accurate PnL or cost-basis analytics in V1.
- Autonomous execution without explicit user confirmation.
- Unlimited saved watchlists or wallet groups in V1.
- Broad arbitrary automation by default.

## Target Users

### Primary

- Investors and ecosystem users who want a high-signal view of what a set of wallets holds and does on Pharos.

### Secondary

- Developers who want the same wallet and contract activity intelligence to support investigation and debugging.
- DeFi power users who want a summarized view of wallet exposure and protocol interactions before taking actions.

## Product Positioning

The skill should be presented as `Pharos Power Skill: Ecosystem Intelligence for Wallets`.

The differentiation is not raw RPC access. The differentiation is that the skill interprets wallet behavior in a Pharos-specific way:

- token exposure across multiple wallets
- repeated ecosystem contract interactions
- cross-wallet overlap patterns
- basic activity clustering
- investor-facing interpretation of raw onchain reads

This makes the submission more defensible than a simple balance or transaction helper.

## User Experience

### Input Style

The skill is natural-language first. Users should be able to issue prompts such as:

- "Analyze these 5 wallets on Pharos testnet and tell me what they are doing."
- "Compare these wallets and show common token exposure and repeated contract usage."
- "Which of these wallets look inactive or underfunded?"
- "Prepare a safe transfer to top up the wallet with the lowest gas balance."

### Response Style

The skill returns:

1. A concise natural-language briefing
2. A structured payload for agent interoperability

The natural-language summary should lead. Structured data should be available beneath it for downstream tools or agent workflows.

## V1 Feature Set

### Read Workflows

- Accept up to 10 wallet addresses plus selected network.
- Fetch native balances and token holdings for each wallet.
- Summarize recent wallet activity.
- Identify frequently touched contracts.
- Aggregate results across wallets.
- Highlight shared ecosystem interactions and overlaps.
- Flag simple notable conditions:
  - inactive wallet
  - low native gas balance
  - concentration in one token
  - repeated interaction with the same contract
  - unusual recent outgoing activity based on simple heuristics
- Suggest possible next actions after the analysis.

### Execution Workflows

Execution is optional and disabled unless explicitly requested.

- `safe mode`
  - native transfer
  - ERC20 transfer
  - approve allowance
  - predefined follow-up actions that can be expressed with known templates

- `expert mode`
  - custom arbitrary writes only when the user explicitly opts in
  - requires private key configuration
  - requires contract context and stronger warnings

## Architecture

The skill should be composed from focused modules instead of one large prompt or file.

### Skill Entry

Accepts:

- user prompt
- network
- wallet list
- requested mode: `read`, `safe`, or `expert`
- optional execution context

This layer is responsible for intent parsing and request normalization.

### Wallet Intelligence Orchestrator

Coordinates the full run:

- invokes readers
- merges results
- builds cross-wallet insights
- prepares final summary data

### RPC Readers

These provide baseline chain access and should be RPC-first:

- native balances
- token balances
- recent activity lookups
- touched contracts
- metadata reads where available

### Ecosystem Intelligence Layer

Maps raw chain results into Pharos-relevant meaning:

- token labels
- contract labels
- known protocol labels
- overlap detection across wallets
- recurring interaction patterns
- simple heuristics for notable activity

Optional adapters can be added later for richer indexing, but RPC should remain the default foundation.

### Summary Generator

Produces:

- structured JSON payload
- natural-language investor briefing

### Execution Layer

Isolated from the read path and disabled by default. Responsible for:

- safe-mode action preparation
- expert-mode action preparation
- explicit transaction previews
- confirmation gating before broadcast

### Config and Adapters

Holds:

- network configuration
- token and contract registries
- framework wrappers for Codex and Claude Code
- optional adapter definitions for richer metadata sources

## Data Flow

1. User provides a natural-language request, target network, and up to 10 wallets.
2. Entry layer validates network, wallet count, address format, and requested mode.
3. Orchestrator fans out read requests for balances, token exposure, recent activity, and touched contracts.
4. Intelligence layer transforms the raw reads into wallet-level and aggregate ecosystem insights.
5. Summary generator emits a structured payload and a concise human-readable briefing.
6. If execution is explicitly requested and credentials are configured:
   - execution layer prepares the action
   - skill clearly restates what will happen
   - action proceeds only after explicit confirmation

## Output Contract

The skill should expose a stable structured shape while remaining NL-first.

Example V1 payload:

```json
{
  "network": "pharos-mainnet",
  "mode": "read",
  "wallet_count": 3,
  "wallets": [
    {
      "address": "0x...",
      "native_balance": "...",
      "token_exposure": [],
      "recent_activity": [],
      "top_contract_interactions": [],
      "flags": []
    }
  ],
  "aggregate": {
    "native_balance_total": "...",
    "token_exposure_combined": [],
    "shared_contracts": [],
    "activity_patterns": [],
    "ecosystem_highlights": []
  },
  "insights": [
    {
      "type": "concentration",
      "severity": "medium",
      "message": "..."
    }
  ],
  "suggested_actions": [
    {
      "mode": "safe",
      "label": "Fund low-gas wallet",
      "description": "..."
    }
  ],
  "execution_available": {
    "safe_mode": true,
    "expert_mode": true,
    "requires_private_key": true
  }
}
```

The natural-language summary should explain:

- what the wallets hold
- what they have been doing recently
- where they overlap in the Pharos ecosystem
- what stands out
- what the user may want to do next

## Safety Rules

- Read mode is the default.
- Execution is always opt-in.
- Private key usage is never assumed.
- Safe mode and expert mode are clearly separated.
- All transaction actions must be previewed before submission.
- No silent execution.
- No autonomous approvals or transfers without explicit user confirmation.
- Expert mode must warn about the risk of custom writes.

## Error Handling

The skill should degrade gracefully and return partial insight when possible.

It must handle:

- invalid wallet addresses
- more than 10 wallets
- unsupported networks
- RPC failures or timeouts
- missing token metadata
- unavailable recent activity sources
- network mismatch between request and context
- missing private key for execution
- ambiguous or unsafe execution requests

## Testing Strategy

V1 tests should cover:

- wallet parsing and validation
- network selection and mode gating
- multi-wallet aggregation logic
- cross-wallet overlap detection
- prompt-to-parameter mapping
- summary generation
- execution gating and preview generation

## Repo Structure

Suggested repository layout:

- `README.md`
- `skill/`
- `prompts/`
- `src/`
  - `orchestrator/`
  - `readers/`
  - `intelligence/`
  - `execution/`
  - `formatters/`
  - `adapters/`
- `config/`
- `examples/`
- `docs/`
- `tests/`
- `assets/`

## Submission Positioning

The final campaign submission should emphasize:

- a one-sentence Pharos-specific value proposition
- natural-language-first interaction
- investor-first hero workflow
- multi-wallet ecosystem intelligence
- read-first safety model
- optional controlled execution
- Codex and Claude Code support with broader agent portability

The demo should show one clean end-to-end investor workflow in under two minutes.
