---
name: pharos-cross-chain-bridge
description: "Plan and implement cross-chain bridge integrations on Pharos using LayerZero, CCTP, native bridge patterns, and SPN Mailbox-based messaging. Use when. Keywords: cross-chain, bridge, LayerZero, CCTP, SPN Mailbox, message passing, chain abstraction, multichain, omnichain, interchain, bridging tokens, cross-chain messaging, bridge integration. Do NOT use for: single-chain contract authoring (use solidity-authoring), general architecture design (use contract-architecture), or deployment (use deployment-and-verification). See also: spn-development (SPN Mailbox patterns), upgrade-patterns (bridge proxy upgrades), contract-architecture (system design)."
metadata:
  audience: developer
  version: 1.0.0
  category: cross-chain
slash: true
---

# Cross-Chain Bridge

Plan and implement cross-chain bridge integrations on Pharos using LayerZero, CCTP, native bridge patterns, and SPN Mailbox-based messaging.

## When to Use

cross-chain, bridge, LayerZero, CCTP, SPN Mailbox, message passing, chain abstraction, multichain, omnichain, interchain, bridging tokens, cross-chain messaging, bridge integration

## When NOT to Use

- **Single-chain contract authoring** — If the user only needs a basic ERC-20/721 without cross-chain logic, use `solidity-authoring` instead.
- **General architecture design** — If the request is about system layout, data flow, or modular decomposition without bridging requirements, use `contract-architecture`.
- **Deployment** — If the user is ready to broadcast, use `deployment-and-verification`. This subskill covers design and implementation only.
- **Arbitrary messaging protocols** — If the user mentions a custom P2P or off-chain relayer without on-chain verification, route to `contract-architecture`.
- **Frontend bridge UI** — If the user asks about building a bridge frontend, use `frontend-dapp-integration` instead.

## Workflow

1. Identify the cross-chain messaging protocol (LayerZero OFT/ONFT, CCTP, native Pharos bridge, or SPN Mailbox).
2. Map the source and destination chains (Pharos mainnet 1672, testnet 688688) with endpoint IDs and gas limits.
3. Design the message payload, security model (trusted remotes, pausability), and fee estimation.
4. Implement the adapter or receiver contract with proper access control and replay protection.
5. Test with testnet deployments on both sides before mainnet.

## Output

- cross-chain architecture diagram (source ↔ destination)
- bridge contract code (sender, receiver, or OFT/ONFT)
- endpoint configuration (LayerZero endpoint IDs, CCTP domain mapping)
- fee estimation and gas configuration
- test plan for cross-chain message flows

## Examples

- **Query:** "Integrate LayerZero OFT for my token on Pharos and Ethereum" → **Action:** Design OFT adapter, configure endpoint IDs for Pharos (1672) and Ethereum (1), set trusted remotes, implement `_debit`/`_credit` overrides, generate fee estimation.
- **Query:** "Set up CCTP USDC bridging between Pharos testnet and Arbitrum" → **Action:** Map CCTP domain IDs, implement `messageTransmitter` integration, configure attestation endpoint, write test for circle attestation + `receiveTransaction` flow.
- **Query:** "Design an SPN Mailbox-based cross-chain message flow" → **Action:** Architect Mailbox adapter pattern, define message envelope (source chain, nonce, payload hash), implement replay protection with ordered nonce tracking.
- **Query:** "Bridge my ERC-721 collection from Pharos to Polygon using ONFT" → **Action:** Extend ERC-721 with ONFT semantics, override `_debit`/`_credit` for NFT locking/burning on source and minting on destination, configure min gas limit for destination execution.

## Verification

Deploy sender and receiver on respective testnets. Send a test message and verify delivery on the destination chain. Check event logs for successful message relay.

## Related

spn-development (SPN Mailbox patterns), upgrade-patterns (bridge proxy upgrades), contract-architecture (system design)
