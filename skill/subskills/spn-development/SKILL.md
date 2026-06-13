---
name: pharos-spn-development
description: "Develop Special Processing Networks (SPNs) on Pharos: custom execution environments, validator restaking, cross-SPN Mailbox communication, escape hatches, SLA monitoring. Reference contracts: SPN Manager, SPN Adapter, Mailbox, Bridge. Use when. Keywords: SPN, Special Processing Network, custom execution, validator restaking, Mailbox, SPN Manager, SPN Adapter, escape hatch, SLA, cross-SPN, app-specific subnet, execution environment, custom VM, sovereign chain, Pharos SPN. Do NOT use for: standard EVM contract development (use solidity-authoring), general cross-chain messaging (use cross-chain-bridge), or deployment (use deployment-and-verification). See also: cross-chain-bridge (Mailbox-based messaging), upgrade-patterns (SPN adapter upgrades), contract-architecture (system design)."
metadata:
  audience: developer
  version: 1.0.0
  category: spn
slash: true
---

# SPN Development

Develop Special Processing Networks (SPNs) on Pharos: custom execution environments, validator restaking, cross-SPN Mailbox communication, escape hatches, SLA monitoring.

## When to Use

SPN, Special Processing Network, custom execution, validator restaking, Mailbox, SPN Manager, SPN Adapter, escape hatch, SLA, cross-SPN, app-specific subnet, execution environment, custom VM, sovereign chain, Pharos SPN

## When NOT to Use

- **Standard EVM contract development** — If the user is writing a regular Solidity contract without SPN-specific features, use `solidity-authoring`.
- **General cross-chain messaging** — If the user needs token bridging or message passing between standard EVM chains (not SPNs), use `cross-chain-bridge`.
- **Deployment** — If the user is ready to broadcast an SPN or supporting contract, use `deployment-and-verification`.
- **Validator setup/infrastructure** — If the user needs to configure validator nodes, staking UI, or infrastructure for running an SPN, this subskill covers smart contracts only — route infrastructure requests to `production-ops`.
- **Simple subnet / sidechain** — If the user just wants a standard sidechain without SPN-specific features (Mailbox, escape hatches, SLA), use `contract-architecture` for a simpler design.

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

- **Query:** "Design an SPN for a high-frequency trading application on Pharos" → **Action:** Architect SPN Manager (deploys SPN instances), Adapter (bridges main chain ↔ SPN), custom WASM execution environment with low-latency gas schedule, configure validator restaking with PROS stake requirements.
- **Query:** "Set up cross-SPN Mailbox communication between two app-specific subnets" → **Action:** Deploy Mailbox contracts on both SPNs, configure message envelope format (source SPN ID, nonce, payload hash), implement ordered nonce tracking and replay protection.
- **Query:** "Implement an escape hatch for users to withdraw from the SPN" → **Action:** Build escape hatch contract on main chain, define exit window and proof submission mechanism (Merkle proof of SPN state), test with simulated SPN unavailability.
- **Query:** "Configure validator restaking for a new SPN deployment" → **Action:** Set up staking contract on main chain, define minimum stake, slashing conditions for SLA violations, configure reward distribution and validator set management.

## Verification

Deploy SPN Manager, Adapter, and Mailbox contracts on testnet. Register a new SPN, send messages through Mailbox cross-SPN, verify delivery. Test escape hatch by simulating SPN unavailability.

## Related

cross-chain-bridge (Mailbox-based messaging), upgrade-patterns (SPN adapter upgrades), contract-architecture (system design)
