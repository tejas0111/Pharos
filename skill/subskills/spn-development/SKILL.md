---
name: pharos-spn-development
description: "Develop Special Processing Networks (SPNs) on Pharos: custom execution environments, validator restaking, cross-SPN Mailbox communication, escape hatches, SLA monitoring. Reference contracts: SPN Manager, SPN Adapter, Mailbox, Bridge. Use when the user says: SPN, Special Processing Network, custom execution, validator restaking, Mailbox, SPN Manager, SPN Adapter, escape hatch, SLA, cross-SPN, app-specific subnet, execution environment, custom VM, sovereign chain, Pharos SPN. Do NOT use for: standard EVM contract development (use solidity-authoring), general cross-chain messaging (use cross-chain-bridge), or deployment (use deployment-and-verification). See also: cross-chain-bridge (Mailbox-based messaging), upgrade-patterns (SPN adapter upgrades), contract-architecture (system design)."
---

# SPN Development

Develop Special Processing Networks (SPNs) on Pharos: custom execution environments, validator restaking, cross-SPN Mailbox communication, escape hatches, SLA monitoring.

## When to Use

SPN, Special Processing Network, custom execution, validator restaking, Mailbox, SPN Manager, SPN Adapter, escape hatch, SLA, cross-SPN, app-specific subnet, execution environment, custom VM, sovereign chain, Pharos SPN

## When NOT to Use

standard EVM contract development (use solidity-authoring), general cross-chain messaging (use cross-chain-bridge), or deployment (use deployment-and-verification)

## Workflow

1. Design the SPN architecture: SPN Manager (deploys and manages SPN instances), SPN Adapter (bridges between Pharos main chain and SPN), Mailbox (cross-SPN message passing), Bridge (asset transfer).
2. Configure the custom execution environment (WASM runtime, gas schedule, state model).
3. Set up validator restaking: validators stake PROS on the main chain to secure the SPN.
4. Implement cross-SPN communication via the Mailbox contract with proper nonce tracking and replay protection.
5. Build escape hatch mechanisms for users to exit the SPN if it becomes unresponsive.
6. Define SLA monitoring with on-chain checkpoints and slashing conditions.

## Output

- SPN architecture design (Manager, Adapter, Mailbox, Bridge)
- SPN Adapter and Mailbox integration contracts
- validator restaking configuration
- escape hatch contract and user exit procedure
- SLA monitoring and slashing parameters
- cross-SPN message flow documentation

## Examples

- "Design an SPN for a high-frequency trading application on Pharos"
- "Set up cross-SPN Mailbox communication between two app-specific subnets"
- "Implement an escape hatch for users to withdraw from the SPN"
- "Configure validator restaking for a new SPN deployment"

## Verification

Deploy SPN Manager, Adapter, and Mailbox contracts on testnet. Register a new SPN, send messages through Mailbox cross-SPN, verify delivery. Test escape hatch by simulating SPN unavailability.

## Related

cross-chain-bridge (Mailbox-based messaging), upgrade-patterns (SPN adapter upgrades), contract-architecture (system design)
