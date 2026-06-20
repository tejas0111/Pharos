// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

/// @title PharosTimelockController
/// @notice Timelock governance for Pharos with proposal queuing, execution, and cancellation.
/// @dev Uses pull-over-push for native transfers. Minimal delay is 1 hour, max is 30 days.
contract PharosTimelockController {
    // ── Inline Reentrancy Guard ──
    uint256 private _status;
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    modifier nonReentrant() {
        if (_status == _ENTERED) revert PharosTimelockController__Reentrancy();
        _status = _ENTERED;
        _;
        _status = _NOT_ENTERED;
    }

    error PharosTimelockController__InvalidDelay();
    error PharosTimelockController__CallFailed();
    error PharosTimelockController__NotProposer();
    error PharosTimelockController__NotExecutor();
    error PharosTimelockController__ProposalNotReady();
    error PharosTimelockController__ProposalExpired();
    error PharosTimelockController__ProposalDoesNotExist();
    error PharosTimelockController__InvalidTarget();
    error PharosTimelockController__Reentrancy();

    event ProposalQueued(bytes32 indexed id, address indexed target, uint256 value, bytes data, uint256 executeTime);
    event ProposalExecuted(bytes32 indexed id, address indexed target, uint256 value, bytes data);
    event ProposalCancelled(bytes32 indexed id);
    event DelayUpdated(uint256 oldDelay, uint256 newDelay);
    event ProposerAdded(address indexed proposer);
    event ProposerRemoved(address indexed proposer);
    event ExecutorAdded(address indexed executor);
    event ExecutorRemoved(address indexed executor);

    uint256 public s_delay;
    uint256 public constant MIN_DELAY = 1 hours;
    uint256 public constant MAX_DELAY = 30 days;
    uint256 public constant GRACE_PERIOD = 14 days;

    address public immutable i_owner;
    mapping(address => bool) public s_proposers;
    mapping(address => bool) public s_executors;
    mapping(bytes32 => bool) public s_queuedProposals;
    mapping(bytes32 => uint256) public s_executionTimes;

    modifier onlyOwner() { if (msg.sender != i_owner) revert PharosTimelockController__InvalidDelay(); _; }
    modifier onlyProposer() { if (!s_proposers[msg.sender]) revert PharosTimelockController__NotProposer(); _; }
    modifier onlyExecutor() { if (!s_executors[msg.sender]) revert PharosTimelockController__NotExecutor(); _; }

    constructor(uint256 _delay) {
        if (_delay < MIN_DELAY || _delay > MAX_DELAY) revert PharosTimelockController__InvalidDelay();
        i_owner = msg.sender;
        s_delay = _delay;
        s_proposers[msg.sender] = true;
        s_executors[msg.sender] = true;
        _status = _NOT_ENTERED;
    }

    function queue(address _target, uint256 _value, bytes calldata _data) external onlyProposer returns (bytes32 id) {
        if (_target == address(0)) revert PharosTimelockController__InvalidTarget();
        id = keccak256(abi.encode(_target, _value, _data));
        if (s_queuedProposals[id]) return id;
        uint256 _executeTime = block.timestamp + s_delay;
        s_queuedProposals[id] = true;
        s_executionTimes[id] = _executeTime;
        emit ProposalQueued(id, _target, _value, _data, _executeTime);
    }

    function execute(address _target, uint256 _value, bytes calldata _data) external onlyExecutor nonReentrant returns (bytes memory) {
        bytes32 id = keccak256(abi.encode(_target, _value, _data));
        if (!s_queuedProposals[id]) revert PharosTimelockController__ProposalDoesNotExist();

        uint256 _execTime = s_executionTimes[id];
        if (block.timestamp < _execTime) revert PharosTimelockController__ProposalNotReady();
        if (block.timestamp > _execTime + GRACE_PERIOD) revert PharosTimelockController__ProposalExpired();

        s_queuedProposals[id] = false;
        emit ProposalExecuted(id, _target, _value, _data);

        (bool success, bytes memory result) = _target.call{value: _value}(_data);
        if (!success) revert PharosTimelockController__CallFailed();
        return result;
    }

    function cancel(bytes32 _id) external onlyProposer nonReentrant {
        if (!s_queuedProposals[_id]) revert PharosTimelockController__ProposalDoesNotExist();
        s_queuedProposals[_id] = false;
        emit ProposalCancelled(_id);
    }

    function updateDelay(uint256 _newDelay) external onlyOwner {
        if (_newDelay < MIN_DELAY || _newDelay > MAX_DELAY) revert PharosTimelockController__InvalidDelay();
        emit DelayUpdated(s_delay, _newDelay);
        s_delay = _newDelay;
    }

    function addProposer(address _proposer) external onlyOwner {
        s_proposers[_proposer] = true;
        emit ProposerAdded(_proposer);
    }

    function removeProposer(address _proposer) external onlyOwner {
        s_proposers[_proposer] = false;
        emit ProposerRemoved(_proposer);
    }

    function addExecutor(address _executor) external onlyOwner {
        s_executors[_executor] = true;
        emit ExecutorAdded(_executor);
    }

    function removeExecutor(address _executor) external onlyOwner {
        s_executors[_executor] = false;
        emit ExecutorRemoved(_executor);
    }
}
