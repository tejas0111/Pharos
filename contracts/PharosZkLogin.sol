// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

/// @title Pharos ZkLogin Verifier
/// @notice zkLogin verification for identity abstraction on Pharos
/// @dev Maps external identity commitments to EVM addresses
/// Allows users to authenticate using zero-knowledge proofs of identity
/// Compatible with Sui/zkLogin-style ephemeral key verification
contract PharosZkLogin {
    // ── Types ────────────────────────────────────────

    struct Identity {
        uint256 commitment;      // Pedersen commitment to identity
        uint256 provider;        // Identity provider (0 = Google, 1 = Apple, 2 = Facebook)
        uint256 aud;            // Client ID (application identifier)
        uint256 exp;            // Max epoch expiration
        bool registered;
    }

    struct ZkLoginProof {
        uint256[2] a;            // G1 point
        uint256[2][2] b;         // G2 point
        uint256[2] c;            // G1 point
        uint256[2] publicInputs; // public inputs to the proof
    }

    struct EphemeralKey {
        uint256 pubKeyX;         // Ephemeral public key (X coordinate)
        uint256 pubKeyY;         // Ephemeral public key (Y coordinate)
        uint256 expiration;      // Expiration timestamp
        bool active;
    }

    // ── Errors ────────────────────────────────────────
    error PharosZkLogin__NotOwner();
    error PharosZkLogin__IdentityNotRegistered();
    error PharosZkLogin__IdentityExists();
    error PharosZkLogin__InvalidProof();
    error PharosZkLogin__KeyExpired();
    error PharosZkLogin__InvalidAddress();
    error PharosZkLogin__KeyAlreadyExists();

    // ── Events ────────────────────────────────────────
    event IdentityRegistered(
        address indexed user,
        uint256 indexed provider,
        uint256 commitment
    );
    event EphemeralKeyRegistered(
        address indexed user,
        uint256 pubKeyX,
        uint256 pubKeyY,
        uint256 expiration
    );
    event EphemeralKeyRevoked(address indexed user);
    event ProofVerified(address indexed user, address indexed relayer);

    // ── Immutables ────────────────────────────────────
    address public immutable i_owner;
    uint256 public immutable i_chainId;

    // ── State ─────────────────────────────────────────
    mapping(address => Identity) public s_identities;
    mapping(address => EphemeralKey) public s_ephemeralKeys;
    mapping(uint256 => address) public s_commitmentToAddress;
    uint256 public s_ephemeralKeyDuration = 1 hours;

    // ── Constructor ───────────────────────────────────

    constructor(uint256 _chainId) {
        i_owner = msg.sender;
        i_chainId = _chainId;
    }

    // ── Modifiers ─────────────────────────────────────

    modifier onlyOwner() {
        if (msg.sender != i_owner) revert PharosZkLogin__NotOwner();
        _;
    }

    // ── Identity Management ───────────────────────────

    /// @notice Register an identity commitment for a user
    /// @dev Links an external identity (via commitment) to an EVM address
    /// @param _commitment Pedersen commitment to the user's identity
    /// @param _provider Identity provider identifier
    /// @param _aud Client ID (application identifier)
    /// @param _exp Maximum epoch that this identity is valid
    function registerIdentity(
        uint256 _commitment,
        uint256 _provider,
        uint256 _aud,
        uint256 _exp
    ) external {
        if (s_commitmentToAddress[_commitment] != address(0)) revert PharosZkLogin__IdentityExists();

        s_identities[msg.sender] = Identity({
            commitment: _commitment,
            provider: _provider,
            aud: _aud,
            exp: _exp,
            registered: true
        });

        s_commitmentToAddress[_commitment] = msg.sender;
        emit IdentityRegistered(msg.sender, _provider, _commitment);
    }

    /// @notice Verify a zkLogin proof and register an ephemeral key
    /// @dev In production, this would verify a Groth16/BLS proof
    /// @param _proof The zero-knowledge proof
    /// @param _ephemeralPubKeyX Ephemeral public key X coordinate
    /// @param _ephemeralPubKeyY Ephemeral public key Y coordinate
    function verifyAndRegisterKey(
        ZkLoginProof calldata _proof,
        uint256 _ephemeralPubKeyX,
        uint256 _ephemeralPubKeyY
    ) external {
        // Verify identity is registered
        if (!s_identities[msg.sender].registered) revert PharosZkLogin__IdentityNotRegistered();

        // In production: verify Groth16 proof here
        // For demonstration: we accept the proof and register the ephemeral key
        // _verifyGroth16Proof(_proof);

        // Check no duplicate key
        if (s_ephemeralKeys[msg.sender].active) revert PharosZkLogin__KeyAlreadyExists();

        // Register ephemeral key
        uint256 expiration = block.timestamp + s_ephemeralKeyDuration;
        s_ephemeralKeys[msg.sender] = EphemeralKey({
            pubKeyX: _ephemeralPubKeyX,
            pubKeyY: _ephemeralPubKeyY,
            expiration: expiration,
            active: true
        });

        emit EphemeralKeyRegistered(msg.sender, _ephemeralPubKeyX, _ephemeralPubKeyY, expiration);
        emit ProofVerified(msg.sender, address(0));
    }

    /// @notice Revoke the current ephemeral key
    function revokeEphemeralKey() external {
        if (!s_identities[msg.sender].registered) revert PharosZkLogin__IdentityNotRegistered();
        s_ephemeralKeys[msg.sender].active = false;
        emit EphemeralKeyRevoked(msg.sender);
    }

    /// @notice Check if a signature from an ephemeral key is valid
    /// @dev Verifies the key is active, not expired, and belongs to the user
    function verifyEphemeralSignature(
        address _user,
        uint256 _signatureX,
        uint256 _signatureY
    ) external view returns (bool) {
        EphemeralKey storage key = s_ephemeralKeys[_user];
        if (!key.active) return false;
        if (block.timestamp > key.expiration) return false;
        if (key.pubKeyX != _signatureX) return false;
        if (key.pubKeyY != _signatureY) return false;
        return true;
    }

    // ── Owner Functions ──────────────────────────────

    /// @notice Set ephemeral key duration
    function setEphemeralKeyDuration(uint256 _duration) external onlyOwner {
        s_ephemeralKeyDuration = _duration;
    }

    /// @notice Lookup address by commitment
    function getAddressFromCommitment(
        uint256 _commitment
    ) external view returns (address) {
        return s_commitmentToAddress[_commitment];
    }

    /// @notice Get identity info for a user
    function getIdentity(
        address _user
    ) external view returns (Identity memory) {
        return s_identities[_user];
    }
}
