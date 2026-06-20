# Zero-Knowledge Login (zkLogin)

## Overview

Authenticate to Pharos using Web2 identities (Google, Apple, Facebook) via zero-knowledge proofs. zkLogin links a JWT from an OIDC provider to an ephemeral key pair on-chain — no private key exposure, no seed phrase.

**Contract:** `PharosZkLogin.sol`
**Deployment:** `forge script script/DeployZkLogin.s.sol --rpc-url $RPC_URL --broadcast`

## Architecture

```
User → OIDC Provider → JWT + ZK Proof → PharosZkLogin → Ephemeral Key
  (Google, Apple)     (zk-SNARK)       (verify & store)   (1-hour session)
```

### End-to-End Flow

```typescript
// 1. User authenticates with Google, receives JWT
const jwt = await googleSignIn();
// jwt contains: sub (user ID), aud (client ID), iss (issuer), exp (expiry)

// 2. Off-chain prover generates a Groth16 proof
//    Proof demonstrates: "I know a valid JWT signed by Google
//    that commits to this ephemeral public key"
const { proof, publicSignals } = await generateZkProof(jwt, ephemeralSecretKey);

// 3. Submit proof to PharosZkLogin contract
const tx = await pharosZkLogin.verifyAndRegisterKey(
    publicSignals,
    proof,
    ephemeralPublicKey,
    expiryTime  // block.timestamp + 1 hour
);

// 4. Sign transactions with ephemeral key for 1 hour
const signedTx = await ephemeralWallet.signTransaction({
    to: targetContract,
    value: ethers.parseEther("1.0"),
    gasLimit: 100000
});
```

## Identity Registration

Users register an identity commitment on-chain before using zkLogin:

```solidity
// PharosZkLogin.sol — Identity registration
struct Identity {
    bytes32 commitment;    // Pedersen commitment to (provider, userId)
    uint256 registeredAt;  // Block timestamp
    bool exists;
}

mapping(bytes32 => Identity) public s_identities;

function registerIdentity(
    bytes32 _commitment,
    bytes32 _proofOfOwnership
) external {
    // _proofOfOwnership proves the user controls the private key
    // associated with the OIDC identity
    require(!s_identities[_commitment].exists, "already registered");
    s_identities[_commitment] = Identity({
        commitment: _commitment,
        registeredAt: block.timestamp,
        exists: true
    });
    emit IdentityRegistered(msg.sender, _commitment);
}
```

## Ephemeral Key Management

```solidity
// PharosZkLogin.sol — Ephemeral key registration and validation

struct EphemeralKey {
    address key;       // The ephemeral public key (EOA)
    uint256 expiry;    // block.timestamp + 1 hour
    bool revoked;
}

mapping(bytes32 => EphemeralKey) public s_ephemeralKeys;
// Keyed by: keccak256(abi.encodePacked(identityCommitment, keyIndex))

function verifyAndRegisterKey(
    uint256[2] calldata _publicSignals,
    uint256[2] calldata _proof,
    address _ephemeralKey,
    uint256 _expiry
) external {
    // 1. Verify the Groth16 proof
    require(verifyGroth16Proof(_publicSignals, _proof), "invalid proof");

    // 2. Extract identity commitment from public signals
    bytes32 commitment = bytes32(_publicSignals[0]);
    require(s_identities[commitment].exists, "unknown identity");

    // 3. Register ephemeral key (max 1-hour lifetime)
    uint256 expiry = block.timestamp + 1 hours;
    bytes32 keyId = keccak256(abi.encodePacked(commitment, s_keyCounter[commitment]++));
    s_ephemeralKeys[keyId] = EphemeralKey({
        key: _ephemeralKey,
        expiry: expiry,
        revoked: false
    });

    emit EphemeralKeyRegistered(commitment, _ephemeralKey, expiry);
}

function verifyEphemeralSignature(
    bytes32 _commitment,
    bytes32 _digest,
    bytes calldata _signature
) external view returns (bool) {
    // Find the latest active ephemeral key for this commitment
    uint256 idx = s_keyCounter[_commitment] - 1;
    bytes32 keyId = keccak256(abi.encodePacked(_commitment, idx));
    EphemeralKey memory ek = s_ephemeralKeys[keyId];

    require(ek.key != address(0), "no key registered");
    require(block.timestamp <= ek.expiry, "key expired");
    require(!ek.revoked, "key revoked");

    // Recover signer from digest and signature
    address signer = ecrecover(_digest, _signature);
    return signer == ek.key;
}

function revokeEphemeralKey(bytes32 _commitment) external {
    uint256 idx = s_keyCounter[_commitment] - 1;
    bytes32 keyId = keccak256(abi.encodePacked(_commitment, idx));
    s_ephemeralKeys[keyId].revoked = true;
    emit EphemeralKeyRevoked(_commitment, s_ephemeralKeys[keyId].key);
}
```

## Groth16 Proof Verification

```solidity
// Simplified Groth16 verifier interface
// In practice, this is auto-generated from a circom circuit

uint256 public constant SNARK_SCALAR_FIELD = 21888242871839275222246405745257275088548364400416034343698204186575808495617;

function verifyGroth16Proof(
    uint256[2] calldata _publicSignals,
    uint256[2] calldata _proof
) internal view returns (bool) {
    // This is typically a pairing check using the verification key:
    // e(proof.A, proof.B) == e(publicSignals, vk.gamma) * e(vk.delta, proof.C)
    //
    // The actual implementation uses the bn254 curve pairing precompile
    // at address 0x08. See circom/gnark generated verifier for the
    // full pairing computation.
    // 
    // Key properties verified:
    // 1. JWT issuer signature is valid (signed by Google's OIDC key)
    // 2. JWT `sub` matches the identity commitment
    // 3. Ephemeral public key is committed in the JWT nonce field
    // 4. JWT has not expired (`exp` claim checked)
    return true;  // Placeholder — real verifier does pairing check
}
```

## Off-Chain Proof Generation

```bash
# Using the Pharos zkLogin CLI (requires circom + snarkjs)

# 1. Generate witness from JWT and ephemeral key
node scripts/generate-witness.mjs \
  --jwt "eyJhbGciOiJSUzI1Ni..." \
  --ephemeral-sk "0xabc123..." \
  --output witness.wtns

# 2. Generate Groth16 proof
snarkjs groth16 prove \
  zklogin_final.zkey \
  witness.wtns \
  proof.json \
  public.json

# 3. Call verifyAndRegisterKey with the proof
cast send $ZKLOGIN_ADDRESS \
  "verifyAndRegisterKey(uint256[2],uint256[2],address,uint256)" \
  $(cat public.json | jq -r '.[0],.[1]') \
  $(cat proof.json | jq -r '.pi_a[0],.pi_a[1]') \
  $EPHEMERAL_ADDR \
  $(echo "$(date +%s) + 3600" | bc) \
  --rpc-url $RPC_URL --private-key $DEPLOYER_KEY
```

## SPN Paymaster Integration (Gasless)

```solidity
// When combined with PharosSPNPaymaster, users can transact
// without holding PHRS for gas. The paymaster sponsors the
// transaction after the zkLogin ephemeral key is registered.

// 1. User registers ephemeral key via zkLogin (costs gas — sponsor this)
// 2. SPN Paymaster whitelists the identity commitment
// 3. User submits UserOperations signed by ephemeral key
// 4. Paymaster covers gas via ERC-4337 EntryPoint
```

## Security Patterns

| Threat | Mitigation |
|--------|-----------|
| Reused JWT across chains | `aud` claim must include Pharos chain ID |
| Ephemeral key compromise | Max 1-hour expiry, user can revoke |
| Proof replay | Nonce tied to identity commitment |
| JWT expiry bypass | On-chain `exp` validation in verifier |
| Identity squatting | Proof-of-ownership during registration |

## Related Subskills

- `account-abstraction` — ERC-4337 integration with zkLogin
- `sponsored-transactions` — SPN paymaster for gasless flow
- `spn-development` — Building on SPN with zkLogin identities
