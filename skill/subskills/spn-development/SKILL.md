# SPN Development

## Overview

Special Processing Networks (SPNs) are Pharos's answer to scalable, specialized execution environments. Each SPN is an independent TEE-backed network that can process specific workloads (ML inference, gaming, DeFi, etc.) while settling to the Pharos main chain.

## Architecture

```
Pharos Main Chain (Pacific Mainnet, Chain 1672)
    │
    ├── SPN Mailbox (cross-SPN messaging)
    │       └── contracts/CrossChainMessage.sol
    │
    ├── SPN #1: DeFi Hub
    │       └── contracts: DEXPool.sol, PharosLendingPool.sol, StakingPool.sol
    │       └── TEE: SGX
    │
    └── SPN #2: RWA Compliance
            └── contracts: PharosRWAToken.sol, RWAToken.sol
            └── TEE: TDX
```

## SPN Lifecycle

### 1. Contract Layer

Every SPN needs smart contracts on the main chain for coordination:

```solidity
// contracts/CrossChainMessage.sol — SPN Mailbox
struct Message {
    bytes32 id;
    address sender;
    address target;
    bytes payload;
    uint256 sourceChain;
    uint256 destChain;
    uint256 timestamp;
    bool delivered;
    bool failed;
}

// registerPeer sets up trusted SPN endpoints
function registerPeer(uint256 chainId, address peerContract, bool trusted) external onlyOwner;
```

> **Deployed on Atlantic testnet.** To connect an SPN, deploy a `CrossChainMessage` instance and register the peer SPN's contract address.

### 2. Mailbox Integration

The `CrossChainMessage` contract (`contracts/CrossChainMessage.sol`) implements the pull-over-push pattern for SPN-to-SPN communication:

```solidity
// SPN A sends a message to SPN B
spnMailbox.sendMessage(targetChain, targetContract, payload);
// Emits MessageSent event → SPN B's relayer picks it up

// SPN B's relayer calls deliverMessage
spnMailbox.deliverMessage(sourceChain, messageId, payload);
// Emits MessageReceived or MessageFailed
```

### 3. SPN Paymaster Integration

SPNs can sponsor transactions for their users via `contracts/PharosSPNPaymaster.sol`:

```solidity
// SPN adds its users to the whitelist
paymaster.addSponsors(userAddresses);
paymaster.setSponsorBudget(spnAddress, 1000 ether);

// Users submit UserOperations — gas is covered by SPN
// EntryPoint calls validatePaymasterUserOp → checks whitelist + budget
```

### 4. Staking & Economics

Validators running SPN nodes must stake tokens. The `contracts/StakingPool.sol` handles reward distribution:

```solidity
// Minimum stake: 100,000 PHRS (configurable)
// Default reward rate: 12% APR
// Lock period: 1 hour minimum
```

## Deployment Sequence

```bash
# 1. Deploy Mailbox on main chain
forge script script/DeployCrossChain.s.sol --rpc-url <RPC> --broadcast

# 2. Register peer SPN
cast send <MAILBOX_ADDR> "registerPeer(uint256,address,bool)" <SPN_CHAIN_ID> <SPN_CONTRACT> true

# 3. Deploy SPN Paymaster for gas sponsorship
forge script script/DeploySPNPaymaster.s.sol --rpc-url <RPC> --broadcast

# 4. Add users to sponsorship whitelist
cast send <PAYMASTER_ADDR> "addSponsors(address[])" ["<USER1>","<USER2>"]
```

## Real Deployments

| Contract | Atlantic (688689) | Pacific (1672) |
|----------|-------------------|----------------|
| CrossChainMessage | Not deployed | Not deployed |
| PharosSPNPaymaster | Not deployed | Not deployed |
| StakingPool | Not deployed | Not deployed |

> **Deploy to Atlantic testnet:** `forge script script/DeployCrossChain.s.sol --rpc-url https://atlantic.dplabs-internal.com --broadcast`

## Security Considerations

1. **Escrow Hatches:** Every SPN should have an escape hatch — a time-locked function that lets users exit if the SPN goes rogue. Use `contracts/PharosTimelockController.sol` for this.
2. **Mailbox Trust:** Only register peer contracts you control. A malicious peer could inject fake messages.
3. **SPN Paymaster Budgets:** Set conservative budgets. A buggy SPN could drain the paymaster.
4. **Staking Slashing:** Validators that miss checkpoints get slashed. Monitor via PharosScan.

## References

- `contracts/CrossChainMessage.sol` — Mailbox implementation
- `contracts/PharosSPNPaymaster.sol` — Gas sponsorship
- `contracts/StakingPool.sol` — Staking rewards
- `contracts/PharosTimelockController.sol` — Time-locked governance

## MCP Tool Integration

When developing SPNs, AI agents should use the following MCP tools:

| Task | MCP Tool | Example |
|------|----------|--------|
| Deploy CrossChainMessage | `pharos_deploy_contract` | `script/DeployCrossChain.s.sol` |
| Deploy SPN Paymaster | `pharos_deploy_contract` | `script/DeploySPNPaymaster.s.sol` |
| Whitelist SPN users | `pharos_spn_configure` | `addSponsors([user1, user2])` |
| Set sponsorship budget | `pharos_spn_fund` | `setGlobalBudget(1000 ETH)` |
| Check paymaster status | `pharos_spn_status` | `canSponsor(user)` |
| Verify deployment | `pharos_verify_contract` | Verify on PharosScan |
| Security audit | `pharos_run_security_check` | Slither analysis |
| Timelock governance | `pharos_create_safe_tx` | Multi-sig proposal |
