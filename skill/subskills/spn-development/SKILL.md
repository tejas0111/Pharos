---
name: pharos-spn-development
description: "Develop Special Processing Networks (SPNs) on Pharos: custom execution environments, TEE requirements (SGX/TDX/Nitro), SPN registration via Pharos CLI, cross-SPN Mailbox communication, escape hatches, SLA monitoring, PHRS staking and slashing. Use when building custom SPNs or TEE-based execution on Pharos. Keywords: SPN, Special Processing Network, custom execution, validator restaking, Mailbox, SPN Manager, SPN Adapter, escape hatch, SLA, cross-SPN, app-specific subnet, execution environment, custom VM, sovereign chain, Pharos SPN, TEE, SGX, TDX, Nitro, PHRS stake, PharosScan SPN, Pharos RPC SPN, Atlantic Testnet."
metadata:
  audience: developer
  version: 1.1.0
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

## Prerequisites
- **Gate Fix**: Perform the mandatory "Gate Fix" check before proceeding.
- **Security**: private keys must be stored in `.env` and accessed via `${PRIVATE_KEY}`.

- **Foundry**: `forge build` must succeed. Run `forge --version` to verify installation.
- **RPC endpoint**: Set `PHAROS_TESTNET_RPC=https://atlantic.dplabs-internal.com` or `PHAROS_MAINNET_RPC=https://rpc.pharos.xyz` in your environment or `.env`.
- **Private key**: Set `PRIVATE_KEY` environment variable (keep this secret, never commit).
- **PharosScan API key**: Set `PHAROSSCAN_API_KEY` for contract verification.
- **Network reachability**: Run `cast chain-id --rpc-url $RPC_URL` to confirm the target network is reachable.
- **Pharos CLI**: `pharos spn` commands available. Run `pharos --version` to verify.

## Workflow

1. Design the SPN architecture: SPN Manager (deploys and manages SPN instances), SPN Adapter (bridges between Pharos main chain and SPN), Mailbox (cross-SPN message passing), Bridge (asset transfer).
2. Check prerequisites: verify required tools are installed, env vars are set, and any required context is available. Ask the user for any missing values before proceeding.
3. Configure the custom execution environment (WASM runtime, gas schedule, state model) with TEE attestation: Pharos supports Intel SGX, Intel TDX, and AWS Nitro Enclaves. Select the TEE type in the SPN registration manifest.
4. Register the SPN on Pharos via the Pharos CLI: `pharos spn register --tee-type sgx --min-stake 100000 --reward-rate 0.12 --pharos-rpc https://rpc.pharos.xyz`. SPN registration uses the Pharos SPN Manager contract deployed on mainnet — verify current address via `pharos spn info`.
5. Set up validator restaking: validators stake PHRS on the Pharos main chain to secure the SPN. Minimum SPN stake: 100,000 PHRS. Validator rewards calculated as: `reward = staked_amount * reward_rate * (uptime / total_slots)`. Reward rate configurable at registration (default 12% APR).
6. Implement cross-SPN communication via the Mailbox contract with proper nonce tracking and replay protection. Verify mailbox addresses on PharosScan: `https://pharosscan.xyz/pharos/address/{mailbox_contract}`.
7. Build escape hatch mechanisms for users to exit the SPN if it becomes unresponsive: submit Merkle proof of SPN state to the main chain escape hatch contract. Escape window: 7 days from request.
8. Define SLA monitoring with on-chain checkpoints and slashing conditions. Pharos SPN slashing: 1% of stake per missed checkpoint (up to 10% maximum). Miss more than 10 consecutive checkpoints triggers full slashing and SPN deregistration. Monitor via Pharos RPC: `pharos spn status --spn-id <id>`.
9. Deploy on Pharos Atlantic Testnet first: `--network pharos-atlantic-testnet --rpc-url https://atlantic.dplabs-internal.com`. Verify on PharosScan before mainnet.
10. Show the plan and ask for approval before implementing.

## Deployment Sequencing

```
Step 1: Deploy SPN Manager on testnet (688689)
  forge script DeploySPNManager --rpc-url pharos_testnet --broadcast
Step 2: Deploy SPN Adapter (bridge main chain ↔ SPN)
  forge script DeploySPNAdapter --rpc-url pharos_testnet --broadcast
Step 3: Deploy Mailbox contract for cross-SPN messaging
  forge script DeployMailbox --rpc-url pharos_testnet --broadcast
Step 4: Register SPN via CLI
  pharos spn register --tee-type sgx --min-stake 100000 --reward-rate 0.12
Step 5: Add validators
  pharos spn add-validator --spn-id <id> --validator-address <addr>
Step 6: Test cross-SPN message flow on testnet
Step 7: Repeat steps 1-6 on mainnet (1672)
Step 8: Verify all contracts on PharosScan
  forge verify-contract --chain-id 1672 --verifier-url https://www.pharosscan.xyz/api ...
```

## Output

- SPN architecture design (Manager, Adapter, Mailbox, Bridge)
- SPN Adapter and Mailbox integration contracts
- validator restaking configuration with PHRS staking parameters
- escape hatch contract and user exit procedure
- SLA monitoring and slashing parameters
- PHRS staking and reward calculation model
- TEE attestation configuration per SPN
- Pharos CLI registration commands and SPN ID
- cross-SPN message flow documentation
- PharosScan monitoring links for SPN events

## Examples

- **Query:** "Design an SPN for a high-frequency trading application on Pharos" → **Action:** Architect SPN Manager (deploys SPN instances), Adapter (bridges main chain ↔ SPN), custom WASM execution environment with low-latency gas schedule, configure TEE via SGX (`--tee-type sgx`), validator restaking with 100,000 PHRS minimum stake at 12% APR. Register via `pharos spn register --tee-type sgx --min-stake 100000 --reward-rate 0.12`.
- **Query:** "Set up cross-SPN Mailbox communication between two app-specific subnets" → **Action:** Deploy Mailbox contracts on both SPNs, configure message envelope format (source SPN ID, nonce, payload hash), implement ordered nonce tracking and replay protection. Verify delivery on PharosScan: `https://pharosscan.xyz/pharos/tx/{tx_hash}`.
- **Query:** "Implement an escape hatch for users to withdraw from the SPN" → **Action:** Build escape hatch contract on main chain, define exit window (7 days) and proof submission mechanism (Merkle proof of SPN state), test with simulated SPN unavailability on Atlantic Testnet.
- **Query:** "Configure validator restaking for a new SPN deployment" → **Action:** Set up staking contract on main chain, define minimum stake (100,000 PHRS), slashing conditions (1% per missed checkpoint, 10% max, full slashing after 10 consecutive missed), configure reward distribution at 12% APR with uptime-based calculation.
- **Query:** "Check if my SPN is healthy after deployment" → **Action:** Run `pharos spn status --spn-id <id>` against Pharos RPC (`https://rpc.pharos.xyz`). Monitor slashing checkpoints on PharosScan: `https://pharosscan.xyz/pharos/events?spn_id=<id>`. Set up alerting if 5+ consecutive checkpoints missed.

## Verification

Deploy SPN Manager, Adapter, and Mailbox contracts on Pharos Atlantic Testnet. Register a new SPN via `pharos spn register --network testnet-v2`. Verify SPN status via `pharos spn status --spn-id <id>`. Send messages through Mailbox cross-SPN, verify delivery on PharosScan. Test escape hatch by simulating SPN unavailability. Confirm slashing conditions fire after missed checkpoints.

## Related

cross-chain-bridge (Mailbox-based messaging), upgrade-patterns (SPN adapter upgrades), contract-architecture (system design)


## Gate

High risk — two-phase execution required:

**Phase 1 — Plan (present freely):**
- Draft the SPN architecture with registration contract, validator set management, challenge period, and fee model — show the complete design
- Do NOT wait for approval to draft — show everything in your response before asking for confirmation

**Phase 2 — Execute (wait for approval):**
- Do NOT Configure SPN execution environments, deploy TEE workloads, modify SPN contracts, or send onchain transactions
- Wait for explicit user confirmation ("I approve", "proceed", "looks good") before taking any of the Phase 2 actions