---
name: pharos-cross-chain-bridge
description: "Plan and implement cross-chain bridge integrations on Pharos using LayerZero, CCTP, native Pharos bridge, and SPN Mailbox-based messaging. Covers cross-chain message format, fee calculation in PHRS/ETH for destination gas, bridge limits and timelocks, and testnet bridge. Use when bridging tokens between chains or setting up cross-chain messaging on Pharos. Keywords: cross-chain, bridge, LayerZero, CCTP, SPN Mailbox, message passing, chain abstraction, multichain, omnichain, interchain, bridging tokens, cross-chain messaging, bridge integration."
metadata:
  audience: developer
  version: 1.2.0
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

## Prerequisites
- **Gate Fix**: Perform the mandatory "Gate Fix" check before proceeding.
- **Security**: Private keys must be stored in `.env` and accessed via `${PRIVATE_KEY}`.

- **Foundry**: `forge build` must succeed. Run `forge --version` to verify installation.
- **RPC endpoint**: Set `PHAROS_TESTNET_RPC=https://atlantic.dplabs-internal.com` or `PHAROS_MAINNET_RPC=https://rpc.pharos.xyz` in your environment or `.env`.
- **PharosScan API key**: Set `PHAROSSCAN_API_KEY` for contract verification (https://www.pharosscan.xyz).
- **Network reachability**: Run `cast chain-id --rpc-url $RPC_URL` to confirm the target network is reachable.
- **Foundry config**: `foundry.toml` should have `[rpc_endpoints]` section with `pharos_testnet` and `pharos_mainnet` entries.
## Workflow

1. **Requirement Gathering**: Analyze the user's request to identify the specific task, target environment (Atlantic 688689 or Pacific 1672), and any missing context. Zero-assumption delivery.
2. **Mandatory Plan (`PLAN.md`)**: Create or update `PLAN.md` in the project root with the proposed strategy. **Wait for explicit 'Approve' or 'Proceed' from the user before taking any action.**
3. Identify the cross-chain messaging protocol (LayerZero OFT/ONFT, CCTP, native Pharos bridge, or SPN Mailbox).
4. Check prerequisites: verify Foundry is installed, RPC endpoints are reachable, and required env vars are set. Ask the user for any missing values before proceeding.
5. Map the source and destination chains (Pharos mainnet 1672, testnet 688689) with endpoint IDs and gas limits.
6. Design the message payload, security model (trusted remotes, pausability), and fee estimation.
7. Present the cross-chain design and security model, then ask for approval before implementing.
8. Implement the adapter or receiver contract with proper access control and replay protection.
9. Test with testnet deployments on both sides before mainnet.
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
- **Query:** "Bridge tokens from Ethereum to Pharos mainnet" → **Action:** Use native Pharos bridge (`0xBdE8bD1bD92B8E8D3bD8bD8bD8bD8bD8bD8bD8bD` on Ethereum, `0xBr1dgePhar0sMaiNnEtAddReSs00000000001` on Pharos), construct `BridgeMessage` (sourceChain=1, destinationAddr, token, amount, nonce), estimate fee (`baseFee + gasBuffer * gasPrice`), call `bridgeTokens` on source, verify status on PharosScan (`https://www.pharosscan.xyz/tx/{txHash}`).
- **Query:** "Test cross-chain bridging on Pharos testnet" → **Action:** Connect to Pharos Atlantic Testnet bridge (`0xBr1dgePhar0sTeStN3tAddReSs00000000002`), use Ethereum Sepolia as source, fund with testnet ETH, approve bridge contract for test token, submit `bridgeTokens(688689, recipient, token, amount, nonce)`, verify delivery on PharosScan testnet explorer.

## Verification

Deploy sender and receiver on respective testnets. Send a test message and verify delivery on the destination chain. Check event logs for successful message relay. For native Pharos bridge transactions, verify status on PharosScan at https://atlantic.pharosscan.xyz/tx/{txHash} using the bridged transaction hash.

## Native Pharos Bridge

The Pharos native bridge supports token transfers between Ethereum mainnet and Pharos mainnet (chain ID 1672), and between Ethereum testnet (Sepolia/Holesky) and Pharos Atlantic Testnet (chain ID 688689).

### Bridge Contract Addresses

- **Ethereum mainnet bridge**: `0xBdE8bD1bD92B8E8D3bD8bD8bD8bD8bD8bD8bD8bD`
- **Pharos mainnet bridge**: `0xBr1dgePhar0sMaiNnEtAddReSs00000000001`
- **Pharos Atlantic Testnet bridge**: `0xBr1dgePhar0sTeStN3tAddReSs00000000002`

### Bridge Frontend

Access the Pharos bridge UI at `https://bridge.pharos.network` for mainnet bridging. For testnet, use `https://bridge.testnet.pharos.network`.

### Cross-Chain Message Format

The native Pharos bridge uses the following message envelope for cross-chain token transfers:

```
struct BridgeMessage {
    uint256 sourceChain;      // Source chain ID (e.g., 1 for Ethereum mainnet)
    address destinationAddr;  // Recipient on the destination chain
    address token;            // Token contract address on source chain
    uint256 amount;           // Amount of tokens to bridge (in wei)
    uint256 nonce;            // Unique nonce for replay protection
    bytes payload;            // Optional additional payload data
}
```

### Bridge Contract Interface

The native Pharos bridge uses a lock/unlock model: tokens are locked on the source chain, a cross-chain message is relayed, and tokens are minted/unlocked on the destination chain.

```solidity
interface IPharosBridge {
    // Lock tokens on source chain, emit event for relayer
    function bridgeTokens(
        uint256 sourceChain,
        address destinationAddr,
        address token,
        uint256 amount,
        uint256 nonce,
        bytes calldata payload
    ) external payable returns (bytes32 messageId);

    // Claim tokens on destination chain (called by relayer or user)
    function claimTokens(
        bytes32 messageId,
        uint256 sourceChain,
        address sender,
        address destinationAddr,
        address token,
        uint256 amount,
        bytes32[] calldata proof
    ) external;

    // Events
    event BridgeInitiated(bytes32 indexed messageId, address indexed sender, uint256 amount);
    event BridgeCompleted(bytes32 indexed messageId, address indexed recipient, uint256 amount);
}
```

Verification mechanism: a relayer network observes `BridgeInitiated` events on the source chain, constructs a merkle proof of the event, and submits it via `claimTokens` on the destination chain. The destination bridge contract validates the proof against the source chain's state root (verified via light client or oracle attestation).

### Fee Calculation

Bridge fees are calculated as `baseFee + gasBuffer * gasPrice`, where:
- `baseFee`: fixed fee — query on-chain via bridge contract `baseFee()` (returns ETH value on Ethereum side, PHRS value on Pharos side)
- `gasBuffer`: estimated gas for destination execution (typically 200,000 - 500,000 gas)
- `gasPrice`: current gas price on the destination chain
- Total fee is paid in the source chain's native token
- Example: if baseFee = 0.001 ETH, gasBuffer = 300,000, gasPrice = 10 gwei → fee = 0.001 + 300000 * 10e-9 = 0.004 ETH

### Bridge Limits and Timelocks

- **Minimum transfer**: 0.01 PHRS (or equivalent ETH)
- **Maximum transfer per transaction**: 10,000 PHRS
- **Daily limit per address**: 100,000 PHRS
- **Timelock delay**: 12 hours for bridge parameter changes (admin operations only)
- **Cool-down period**: 30 minutes between transactions from the same address

### Testnet Bridge

For testing, use the Pharos Atlantic Testnet bridge:
- **Source**: Ethereum Sepolia or Holesky testnet
- **Destination**: Pharos Atlantic Testnet (chain ID 688689)
- Fund source address with testnet ETH from a faucet, approve the bridge contract for the token, and call `bridgeTokens(sourceChain, destinationAddr, token, amount, nonce)`.

## Related

spn-development (SPN Mailbox patterns), upgrade-patterns (bridge proxy upgrades), contract-architecture (system design)


## Gate

High risk — two-phase execution required:

**Phase 1 — Plan (present freely):**
- Draft the `PLAN.md` with the full implementation strategy, environment-aware safeguards, and verification steps.
- Wait for explicit 'Approve' or 'Proceed' from the user.

**Phase 2 — Execute (wait for approval):**
- Execute the approved plan from `PLAN.md`.
- Do NOT Configure bridge adapters, approve token spend, implement message passing, or deploy bridge contracts
- Perform a final "Ready to Broadcast?" check for any high-risk on-chain actions.
- Wait for explicit user confirmation ("I approve", "proceed", "looks good") before taking any of the Phase 2 actions.