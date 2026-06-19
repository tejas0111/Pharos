# Account Abstraction (ERC-4337)

## Overview

ERC-4337 Account Abstraction enables smart contract wallets that can execute transactions on behalf of users without requiring EOA signatures. On Pharos, this integrates with the SPN network for sponsored transactions.

## Pharos-Specific Integration

- **EntryPoint v0.7**: Pre-deployed on Atlantic at `0x0000000071727De22E5E9d8BAf0edAc6f37da032`
- **SPN Paymaster**: `contracts/PharosSPNPaymaster.sol` implements IPaymaster
- **zkLogin**: `contracts/PharosZkLogin.sol` provides identity abstraction

## Architecture

```
User ──→ Build UserOperation
  │
  ├──→ EntryPoint.validateUserOp()
  │       └──→ Paymaster.validatePaymasterUserOp()
  │               └──→ (optional) zkLogin verify
  │
  └──→ EntryPoint.executeUserOp()
          └──→ Paymaster.postOp()
                  └──→ Track gas costs
```

## Key Concepts

### PackedUserOperation
```solidity
struct PackedUserOperation {
    address sender;
    uint256 nonce;
    bytes initCode;        // Factory + init data
    bytes callData;        // Target contract call
    bytes32 accountGasLimits;  // verificationGas + callGas
    uint256 preVerificationGas;
    bytes32 gasFees;       // maxPriorityFee + maxFee
    bytes paymasterAndData;    // Paymaster address + data
    bytes signature;
}
```

### Paymaster Flow
1. **Validation Phase**: `validatePaymasterUserOp` checks if the user is whitelisted and budgets are available
2. **Execution Phase**: EntryPoint executes the UserOperation
3. **Post-Execution**: `postOp` deducts actual gas costs from budget

## Smart Wallets

Pharos supports Safe Smart Accounts for multi-sig and account abstraction:
- `pharos_create_safe_tx`: Prepare multi-sig transactions
- `pharos_propose_safe_tx`: Submit to Safe Transaction Service

## Security Considerations

1. **EntryPoint Trust**: Only interact with known EntryPoint addresses
2. **Paymaster Budgets**: Set conservative budgets to limit exposure
3. **Nonce Management**: Prevent replay across chains
4. **Gas Limits**: Bound verification gas to prevent griefing
5. **Key Rotation**: Ephemeral keys limit attack window

## References

- [ERC-4337 Specification](https://eips.ethereum.org/EIPS/eip-4337)
- [Pharos Canonical Contracts](https://docs.pharos.xyz/getting-started/canonical-contracts)
- `contracts/PharosSPNPaymaster.sol`
- `contracts/PharosZkLogin.sol`
