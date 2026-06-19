// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

/// @title Pharos CrossChainMessage
/// @notice Demonstrates cross-chain messaging pattern for Pharos
/// @dev Uses pull-over-push for message delivery, chain-aware validation
///      Compatible with LayerZero / SPN Mailbox pattern
contract CrossChainMessage {
    // ── Types ───────────────────────────────────────
    struct Message {
        uint256 id;
        address sender;
        address target;
        bytes payload;
        uint256 sourceChainId;
        uint256 destinationChainId;
        uint256 timestamp;
        bool delivered;
        bool failed;
    }

    struct ChainPeer {
        uint256 chainId;
        address peerContract;
        bool trusted;
    }

    // ── Errors ──────────────────────────────────────
    error CrossChain__NotOwner();
    error CrossChain__NotTrustedPeer();
    error CrossChain__InvalidChainId();
    error CrossChain__MessageAlreadyDelivered();
    error CrossChain__MessageFailed();
    error CrossChain__EmptyPayload();
    error CrossChain__InvalidAddress();

    // ── Events ──────────────────────────────────────
    event MessageSent(uint256 indexed id, address indexed sender, uint256 targetChain, bytes payload);
    event MessageReceived(uint256 indexed id, address indexed sender, bytes payload);
    event MessageFailed(uint256 indexed id, bytes reason);
    event MessageRetried(uint256 indexed id);
    event PeerRegistered(uint256 chainId, address contractAddr);
    event PeerRemoved(uint256 chainId);

    // ── Immutable ───────────────────────────────────
    address public immutable i_owner;
    uint256 public immutable i_chainId;

    // ── State ───────────────────────────────────────
    uint256 public s_messageCount;
    mapping(uint256 => Message) public s_messages;
    mapping(uint256 => ChainPeer) public s_trustedPeers;  // chainId -> peer
    uint256[] public s_trustedChainIds;

    mapping(address => uint256[]) public s_userMessages;

    constructor(uint256 _chainId) {
        i_owner = msg.sender;
        i_chainId = _chainId;
    }

    modifier onlyOwner() {
        if (msg.sender != i_owner) revert CrossChain__NotOwner();
        _;
    }

    modifier onlyTrustedPeer(uint256 _chainId) {
        if (!s_trustedPeers[_chainId].trusted) revert CrossChain__NotTrustedPeer();
        _;
    }

    // ── Administration ──────────────────────────────

    function registerPeer(uint256 _chainId, address _contract) external onlyOwner {
        if (_chainId == 0) revert CrossChain__InvalidChainId();
        if (_contract == address(0)) revert CrossChain__InvalidAddress();

        if (!s_trustedPeers[_chainId].trusted) {
            s_trustedChainIds.push(_chainId);
        }

        s_trustedPeers[_chainId] = ChainPeer({
            chainId: _chainId,
            peerContract: _contract,
            trusted: true
        });

        emit PeerRegistered(_chainId, _contract);
    }

    function removePeer(uint256 _chainId) external onlyOwner {
        s_trustedPeers[_chainId].trusted = false;
        emit PeerRemoved(_chainId);
    }

    function getTrustedChainIds() external view returns (uint256[] memory) {
        return s_trustedChainIds;
    }

    // ── Send Message ────────────────────────────────

    function sendMessage(uint256 _destinationChainId, address _target, bytes calldata _payload) external returns (uint256) {
        if (_destinationChainId == i_chainId) revert CrossChain__InvalidChainId();
        if (_target == address(0)) revert CrossChain__InvalidAddress();
        if (_payload.length == 0) revert CrossChain__EmptyPayload();

        s_messageCount++;
        uint256 msgId = s_messageCount;

        s_messages[msgId] = Message({
            id: msgId,
            sender: msg.sender,
            target: _target,
            payload: _payload,
            sourceChainId: i_chainId,
            destinationChainId: _destinationChainId,
            timestamp: block.timestamp,
            delivered: false,
            failed: false
        });

        s_userMessages[msg.sender].push(msgId);
        emit MessageSent(msgId, msg.sender, _destinationChainId, _payload);

        return msgId;
    }

    // ── Receive / Deliver (called by relayer / SPN Mailbox) ─

    function deliverMessage(
        uint256 _msgId,
        address _sender,
        bytes calldata _payload,
        uint256 _sourceChainId
    ) external onlyTrustedPeer(_sourceChainId) {
        if (s_messages[_msgId].delivered) revert CrossChain__MessageAlreadyDelivered();

        s_messages[_msgId].delivered = true;
        s_messages[_msgId].sourceChainId = _sourceChainId;

        // Attempt to call target with payload
        (bool success, bytes memory result) = s_messages[_msgId].target.call(_payload);
        if (!success) {
            s_messages[_msgId].failed = true;
            emit MessageFailed(_msgId, result);
            return;
        }

        emit MessageReceived(_msgId, _sender, _payload);
    }

    // ── Retry Failed ────────────────────────────────

    function retryMessage(uint256 _msgId) external onlyTrustedPeer(s_messages[_msgId].sourceChainId) {
        Message storage msg_ = s_messages[_msgId];
        if (!msg_.failed) revert CrossChain__MessageFailed();

        (bool success, ) = msg_.target.call(msg_.payload);
        if (success) {
            msg_.failed = false;
            msg_.delivered = true;
            emit MessageRetried(_msgId);
        } else {
            emit MessageFailed(_msgId, "retry failed");
        }
    }

    // ── Query ───────────────────────────────────────

    function getUserMessageCount(address _user) external view returns (uint256) {
        return s_userMessages[_user].length;
    }

    function getUserMessages(address _user) external view returns (uint256[] memory) {
        return s_userMessages[_user];
    }

    function getMessage(uint256 _msgId) external view returns (Message memory) {
        return s_messages[_msgId];
    }
}
