# Zero-Knowledge Login (zkLogin)

## Overview

zkLogin enables users to authenticate to the Pharos blockchain using external Web2 identity providers (Google, Apple, Facebook) without compromising privacy. A zero-knowledge proof links the user's external identity to an ephemeral key pair on-chain.

## Architecture

```
User ──→ Identity Provider (Google Auth) ──→ JWT Token
  │                                              │
  │    Off-chain: ZK-proof generation            │
  └─────→ zkLogin Verifier Contract ←───────────┘
              │
              ↓
         Ephemeral Key
         (valid for N hours)
              │
              ↓
         Signed Transactions
```

### Components

1. **Identity Registration**: User registers a Pedersen commitment to their identity (provider + subject) on-chain
2. **Proof Generation**: Off-chain, a zk-SNARK/Groth16 proof validates the JWT without revealing the secret
3. **Ephemeral Key Registration**: After proof verification, the user registers a time-limited signing key
4. **Transaction Signing**: The ephemeral key signs transactions during the session

## Contract

### `PharosZkLogin.sol`

Location: `contracts/PharosZkLogin.sol`

An identity abstraction contract supporting:
- **Identity Commitment**: Pedersen commitment to external identity
- **Provider Support**: Google (0), Apple (1), Facebook (2)
- **Ephemeral Keys**: Time-limited signing keys (default: 1 hour)
- **Proof Verification**: Extensible Groth16 verification slot

**Key Functions:**

```solidity
// Register an identity commitment
function registerIdentity(
    uint256 _commitment,
    uint256 _provider,
    uint256 _aud,
    uint256 _exp
) external

// Verify zkLogin proof and register ephemeral key
function verifyAndRegisterKey(
    ZkLoginProof calldata _proof,
    uint256 _ephemeralPubKeyX,
    uint256 _ephemeralPubKeyY
) external

// Verify an ephemeral key signature
function verifyEphemeralSignature(
    address _user,
    uint256 _signatureX,
    uint256 _signatureY
) external view returns (bool)

// Revoke current ephemeral key
function revokeEphemeralKey() external
```

## Deployment

```bash
# Deploy zkLogin Verifier
forge script script/DeployZkLogin.s.sol --rpc-url <RPC_URL> --broadcast
```

## Testing

```bash
forge test --match-contract PharosZkLoginTest -vv
```

Tests cover: identity registration, duplicate prevention, ephemeral key lifecycle (register, verify, expire, revoke), access control, and edge cases.

## Integration with SPN Paymaster

zkLogin + SPN Paymaster = complete gasless onboarding:
1. User authenticates via Google → zkLogin proof
2. Proof verified → ephemeral key registered
3. User submits UserOperation → SPN Paymaster sponsors gas
4. Transaction executed without user holding PROS/PHRS

## Security Considerations

1. **Ephemeral Key Duration**: Short-lived keys (1 hour default) limit exposure
2. **Commitment Collision**: Commitments must be unique per user
3. **Proof Verification**: Production deployment requires real Groth16/BLS verification
4. **Key Revocation**: Users can revoke compromised keys at any time
5. **Replay Protection**: Nonces prevent replay attacks
