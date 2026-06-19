// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

/// @title Pharos SPN Paymaster
/// @notice ERC-4337 Paymaster for sponsored transactions on Pharos
/// @dev Implements the IPaymaster interface to allow dApps to sponsor user gas fees
/// @dev Compatible with Pharos Atlantic (EntryPoint v0.7 at 0x0000000071727De22E5E9d8BAf0edAc6f37da032)
contract PharosSPNPaymaster {
    // ── ERC-4337 Types ───────────────────────────────

    struct PackedUserOperation {
        address sender;
        uint256 nonce;
        bytes initCode;
        bytes callData;
        bytes32 accountGasLimits;
        uint256 preVerificationGas;
        bytes32 gasFees;
        bytes paymasterAndData;
        bytes signature;
    }

    enum PostOpMode {
        opSucceeded,
        opReverted,
        postOpReverted
    }

    // ── Errors ────────────────────────────────────────
    error PharosSPNPaymaster__NotEntryPoint();
    error PharosSPNPaymaster__NotOwner();
    error PharosSPNPaymaster__NotWhitelisted();
    error PharosSPNPaymaster__Paused();
    error PharosSPNPaymaster__InsufficientBudget();
    error PharosSPNPaymaster__InsufficientGlobalBudget();
    error PharosSPNPaymaster__InvalidAddress();
    error PharosSPNPaymaster__ZeroAddress();

    // ── Events ────────────────────────────────────────
    event UserWhitelisted(address indexed user);
    event UserRemoved(address indexed user);
    event BudgetSet(address indexed sponsor, uint256 amount);
    event GlobalBudgetSet(uint256 amount);
    event TransactionSponsored(
        address indexed user,
        uint256 cost
    );
    event EmergencyWithdrawn(address indexed to, uint256 amount);
    event Paused(bool paused);

    // ── Immutables ────────────────────────────────────
    address public immutable i_entryPoint;
    address public immutable i_owner;
    uint256 public immutable i_chainId;

    // ── State ─────────────────────────────────────────
    mapping(address => bool) public s_whitelistedSenders;
    mapping(address => uint256) public s_sponsorBudgets;
    mapping(address => uint256) public s_sponsorSpent;
    uint256 public s_globalBudget;
    uint256 public s_globalSpent;
    bool public s_paused;

    // ── Constructor ───────────────────────────────────

    constructor(address _entryPoint, uint256 _chainId) {
        if (_entryPoint == address(0)) revert PharosSPNPaymaster__ZeroAddress();
        i_entryPoint = _entryPoint;
        i_owner = msg.sender;
        i_chainId = _chainId;
    }

    // ── Modifiers ─────────────────────────────────────

    modifier onlyEntryPoint() {
        if (msg.sender != i_entryPoint) revert PharosSPNPaymaster__NotEntryPoint();
        _;
    }

    modifier onlyOwner() {
        if (msg.sender != i_owner) revert PharosSPNPaymaster__NotOwner();
        _;
    }

    modifier notPaused() {
        if (s_paused) revert PharosSPNPaymaster__Paused();
        _;
    }

    // ── ERC-4337 Paymaster Interface ─────────────────

    function validatePaymasterUserOp(
        PackedUserOperation calldata userOp,
        bytes32 /* userOpHash */,
        uint256 maxCost
    ) external onlyEntryPoint notPaused returns (bytes memory context, uint256 validationData) {
        if (!s_whitelistedSenders[userOp.sender]) revert PharosSPNPaymaster__NotWhitelisted();

        // Check per-sponsor budget
        uint256 sponsorBudget = s_sponsorBudgets[userOp.sender];
        if (sponsorBudget > 0) {
            uint256 sponsorSpent = s_sponsorSpent[userOp.sender];
            if (sponsorSpent + maxCost > sponsorBudget) revert PharosSPNPaymaster__InsufficientBudget();
        }

        // Check global budget
        if (s_globalBudget > 0) {
            if (s_globalSpent + maxCost > s_globalBudget) revert PharosSPNPaymaster__InsufficientGlobalBudget();
        }

        context = abi.encode(userOp.sender, maxCost);
        return (context, 0);
    }

    function postOp(
        PostOpMode /* mode */,
        bytes calldata context,
        uint256 actualGasCost,
        uint256 /* actualUserOpFeePerGas */
    ) external onlyEntryPoint {
        (address user, uint256 maxCost) = abi.decode(context, (address, uint256));

        // Use actualGasCost (bounded by maxCost from validation)
        uint256 cost = actualGasCost > maxCost ? maxCost : actualGasCost;

        // Update both per-sponsor and global tracking
        s_sponsorSpent[user] += cost;
        s_globalSpent += cost;

        emit TransactionSponsored(user, cost);
    }

    // ── Admin: Sponsorship Management ─────────────────

    function addSponsor(address _user) external onlyOwner {
        if (_user == address(0)) revert PharosSPNPaymaster__InvalidAddress();
        s_whitelistedSenders[_user] = true;
        emit UserWhitelisted(_user);
    }

    function addSponsors(address[] calldata _users) external onlyOwner {
        for (uint256 i = 0; i < _users.length; i++) {
            if (_users[i] == address(0)) revert PharosSPNPaymaster__InvalidAddress();
            s_whitelistedSenders[_users[i]] = true;
            emit UserWhitelisted(_users[i]);
        }
    }

    function removeSponsor(address _user) external onlyOwner {
        s_whitelistedSenders[_user] = false;
        emit UserRemoved(_user);
    }

    function setSponsorBudget(address _sponsor, uint256 _amount) external onlyOwner {
        s_sponsorBudgets[_sponsor] = _amount;
        emit BudgetSet(_sponsor, _amount);
    }

    function setGlobalBudget(uint256 _amount) external onlyOwner {
        s_globalBudget = _amount;
        emit GlobalBudgetSet(_amount);
    }

    // ── Admin: Emergency & Pause ──────────────────────

    function pause() external onlyOwner {
        s_paused = true;
        emit Paused(true);
    }

    function unpause() external onlyOwner {
        s_paused = false;
        emit Paused(false);
    }

    function emergencyWithdraw(address _to, uint256 _amount) external onlyOwner {
        if (_to == address(0)) revert PharosSPNPaymaster__InvalidAddress();
        payable(_to).transfer(_amount);
        emit EmergencyWithdrawn(_to, _amount);
    }

    // ── View ──────────────────────────────────────────

    function canSponsor(address _user) external view returns (bool) {
        return s_whitelistedSenders[_user] && !s_paused;
    }

    function remainingBudget(address _sponsor) external view returns (uint256) {
        return s_sponsorBudgets[_sponsor] - s_sponsorSpent[_sponsor];
    }

    function remainingGlobalBudget() external view returns (uint256) {
        return s_globalBudget - s_globalSpent;
    }

    receive() external payable {}
}
