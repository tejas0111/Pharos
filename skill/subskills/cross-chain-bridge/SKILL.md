---
name: pharos-cross-chain-bridge
description: "Plan and implement cross-chain bridge integrations on Pharos using LayerZero, CCTP, native bridge patterns, and SPN Mailbox-based messaging. Use when the user says: cross-chain, bridge, LayerZero, CCTP, SPN Mailbox, message passing, chain abstraction, multichain, omnichain, interchain, bridging tokens, cross-chain messaging, bridge integration. Do NOT use for: single-chain contract authoring (use solidity-authoring), general architecture design (use contract-architecture), or deployment (use deployment-and-verification). See also: spn-development (SPN Mailbox patterns), upgrade-patterns (bridge proxy upgrades), contract-architecture (system design)."
---

# Cross-Chain Bridge

Plan and implement cross-chain bridge integrations on Pharos using LayerZero, CCTP, native bridge patterns, and SPN Mailbox-based messaging.

## When to Use

cross-chain, bridge, LayerZero, CCTP, SPN Mailbox, message passing, chain abstraction, multichain, omnichain, interchain, bridging tokens, cross-chain messaging, bridge integration

## When NOT to Use

single-chain contract authoring (use solidity-authoring), general architecture design (use contract-architecture), or deployment (use deployment-and-verification)

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

- "Integrate LayerZero OFT for my token on Pharos and Ethereum"
- "Set up CCTP USDC bridging between Pharos testnet and Arbitrum"
- "Design an SPN Mailbox-based cross-chain message flow"
- "Bridge my ERC-721 collection from Pharos to Polygon using ONFT"

## Verification

Deploy sender and receiver on respective testnets. Send a test message and verify delivery on the destination chain. Check event logs for successful message relay.

## Related

spn-development (SPN Mailbox patterns), upgrade-patterns (bridge proxy upgrades), contract-architecture (system design)
