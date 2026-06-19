# Account Abstraction (ERC-4337)

## Overview

Pharos integrates ERC-4337 account abstraction to enable smart contract wallets that can execute transactions without externally owned account (EOA) signatures. This subskill covers building UserOperations, integrating with the SPN paymaster for gas sponsorship, and using ephemeral keys with ZkLogin.

**EntryPoint v0.7 (Atlantic Testnet):** `0x0000000071727De22E5E9d8BAf0edAc6f37da032`

## Architecture

### UserOperation Flow

```
User → Bundler → EntryPoint → Paymaster → Wallet Contract
  1. Builds UserOp    2. Validates    3. Checks sponsorship    4. Executes
```

### PackedUserOperation Structure

```solidity
struct PackedUserOperation {
    address sender;
    uint256 nonce;
    bytes initCode;              // Factory + calldata for new wallets
    bytes callData;              // The actual function call
    bytes32 accountGasLimits;    // verificationGas + callGasLimit (packed)
    uint256 preVerificationGas;  // Gas for bundler overhead
    bytes32 gasFees;             // maxPriorityFee + maxFeePerGas (packed)
    bytes paymasterAndData;      // Paymaster address + sponsorship context
    bytes signature;             // User signature or ZkLogin proof
}
```

## Building a UserOperation (Ethers v6)

```typescript
import { ethers } from "ethers";

const ENTRYPOINT = "0x0000000071727De22E5E9d8BAf0edAc6f37da032";
const RPC_URL = "https://atlantic.dplabs-internal.com";

async function buildUserOp(
  sender: string,
  target: string,
  calldata: string,
  paymaster: string
): Promise<any> {
  const provider = new ethers.JsonRpcProvider(RPC_URL);
  sender: string,
  target: string,
  calldata: string,
  paymaster: string
): Promise<any> {
  const entryPoint = new ethers.Contract(
    ENTRYPOINT,
    ["function getNonce(address sender, uint192 key) view returns (uint256)"],
    provider
  );
  const nonce = await entryPoint.getNonce(sender, 0);

  return {
    sender,
    nonce: Number(nonce),
    initCode: "0x",
    callData: new ethers.Interface([
      "function execute(address to, uint256 value, bytes calldata data)"
    ]).encodeFunctionData("execute", [target, 0, calldata]),
    callGasLimit: 500_000,
    verificationGasLimit: 200_000,
    preVerificationGas: 50_000,
    maxFeePerGas: ethers.parseUnits("1", "gwei"),
    maxPriorityFeePerGas: ethers.parseUnits("0.1", "gwei"),
    paymasterAndData: paymaster,
    signature: "0x"
  };
}
```

## Sending a UserOp via Bundler

```bash
# Using curl to a bundler RPC
curl -X POST https://atlantic.dplabs-internal.com \
  -H "Content-Type: application/json" \
  -d '{
    "jsonrpc": "2.0",
    "id": 1,
    "method": "eth_sendUserOperation",
    "params": [
      {
        "sender": "0x...",
        "nonce": "0x0",
        "initCode": "0x",
        "callData": "0x...",
        "callGasLimit": "0x7a120",
        "verificationGasLimit": "0x30d40",
        "preVerificationGas": "0xc350",
        "maxFeePerGas": "0x3b9aca00",
        "maxPriorityFeePerGas": "0x5f5e100",
        "paymasterAndData": "0x...",
        "signature": "0x..."
      },
      ENTRYPOINT_ADDRESS
    ]
  }'
```

## Paymaster Lifecycle

The SPN Paymaster handles gas sponsorship in three phases:

1. **Validation** — EntryPoint calls `validatePaymasterUserOp()` to check whitelist status and budget
2. **Execution** — The UserOperation executes via the wallet contract
3. **Post-Execution** — EntryPoint calls `postOp()` to deduct gas costs from the paymaster's deposit

```solidity
// PharosSPNPaymaster.sol validation logic (simplified)
function validatePaymasterUserOp(
    PackedUserOperation calldata op,
    bytes32, /* userOpHash */
    uint256 maxCost
) external view returns (bytes memory context, uint256 validationData) {
    // Check sender is whitelisted in SPN registry
    require(spnRegistry.isWhitelisted(op.sender), "not whitelisted");
    // Check paymaster has sufficient deposit
    require(address(this).balance >= maxCost, "insufficient deposit");
    // Return empty context — no postOp needed for simple sponsorship
    return ("", 0);
}
```

## Safe Smart Account Integration

```typescript
// Deploy a Safe smart account on Pharos
import Safe from "@safe-global/protocol-kit";

const safe = await Safe.init({
  provider: "https://atlantic.dplabs-internal.com",
  signer: privateKey,
  safeAddress: predictedAddress
});

// Create a sponsored transaction via MCP
const txPayload = await safe.createTransaction({
  transactions: [{
    to: targetContract,
    value: "0",
    data: encodedCall
  }]
});
```

## Security Patterns

| Pattern | Implementation | Risk if Omitted |
|---------|---------------|-----------------|
| EntryPoint validation | Verify address matches canonical `0x0000...a032` | Fake EntryPoint can drain wallets |
| Nonce management | Use `getNonce()` before each UserOp | Replay attacks |
| Paymaster budget caps | Enforce max spend per UserOp | Griefing (draining paymaster) |
| Ephemeral key rotation | Rotate session keys every 24h | Long-lived key compromise |
| Verification gas bound | Cap `verificationGasLimit` to 300k | DoS via expensive validation |

## Pharos-Specific Addresses

| Component | Atlantic (Testnet) |
|-----------|-------------------|
| EntryPoint v0.7 | `0x0000000071727De22E5E9d8BAf0edAc6f37da032` |
| SPN Paymaster | Address from `PharosSPNPaymaster.sol` deployment |
| ZkLogin Verifier | Address from `PharosZkLogin.sol` deployment |

## Related Subskills

- `zero-knowledge-login` — Identity abstraction with ephemeral keys
- `sponsored-transactions` — SPN paymaster integration
- `wallet-and-transaction-ui` — Frontend wallet connection patterns
