// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {IERC20} from "./interfaces/IERC20.sol";
import {SafeERC20} from "./interfaces/SafeERC20.sol";
import {ReentrancyGuard} from "./interfaces/ReentrancyGuard.sol";

/// @title Pharos StakingPool
/// @notice A staking pool with time-weighted rewards, built for Pharos Atlantic/Pacific
/// @dev Uses pull-over-push pattern for safety (Pharos best practice: no gas stipend on .call)
contract StakingPool is ReentrancyGuard {
    using SafeERC20 for IERC20;

    // ──────────────────────────────────────────────
    // Pharos-Specific: Immutable owner, chain-aware
    // ──────────────────────────────────────────────
    address public immutable i_owner;
    uint256 public immutable i_chainId;
    IERC20 public immutable i_stakingToken;
    IERC20 public immutable i_rewardToken;

    uint256 public s_rewardRate;         // reward tokens per second
    uint256 public s_totalStaked;
    uint256 public s_rewardPerTokenStored;
    uint256 public s_lastUpdateTime;
    uint256 public s_rewardDuration;     // e.g. 30 days
    uint256 public constant MAX_REWARD_DURATION = 365 days;

    // Pharos-Specific: gas-safe pull-over-push for rewards
    mapping(address => uint256) public s_userRewardPerTokenPaid;
    mapping(address => uint256) public s_rewards;
    mapping(address => uint256) public s_balances;
    mapping(address => uint256) public s_lastStakeTime;

    // Pharos-specific: minimum stake duration to prevent wash staking
    uint256 public s_minStakeDuration = 1 hours;

    error StakingPool__NotOwner();
    error StakingPool__ZeroAmount();
    error StakingPool__InsufficientBalance();
    error StakingPool__StakeLocked(uint256 unlockTime);
    error StakingPool__RewardDurationTooLong();
    error StakingPool__InsufficientReward();
    error StakingPool__NoRewards();
    error StakingPool__InvalidAddress();

    event Staked(address indexed user, uint256 amount);
    event Withdrawn(address indexed user, uint256 amount);
    event RewardPaid(address indexed user, uint256 reward);
    event RewardRateUpdated(uint256 newRate);
    event MinStakeDurationUpdated(uint256 duration);

    constructor(
        address _stakingToken,
        address _rewardToken,
        uint256 _rewardRate,
        uint256 _rewardDuration,
        uint256 _chainId
    ) {
        if (_stakingToken == address(0) || _rewardToken == address(0)) revert StakingPool__InvalidAddress();
        if (_rewardDuration > MAX_REWARD_DURATION) revert StakingPool__RewardDurationTooLong();

        i_owner = msg.sender;
        i_stakingToken = IERC20(_stakingToken);
        i_rewardToken = IERC20(_rewardToken);
        s_rewardRate = _rewardRate;
        s_rewardDuration = _rewardDuration;
        i_chainId = _chainId;
        s_lastUpdateTime = block.timestamp;
    }

    modifier onlyOwner() {
        if (msg.sender != i_owner) revert StakingPool__NotOwner();
        _;
    }

    modifier updateReward(address _account) {
        s_rewardPerTokenStored = rewardPerToken();
        s_lastUpdateTime = block.timestamp;
        if (_account != address(0)) {
            s_rewards[_account] = earned(_account);
            s_userRewardPerTokenPaid[_account] = s_rewardPerTokenStored;
        }
        _;
    }

    // ── View ────────────────────────────────────────

    function rewardPerToken() public view returns (uint256) {
        if (s_totalStaked == 0) return s_rewardPerTokenStored;
        return s_rewardPerTokenStored + ((block.timestamp - s_lastUpdateTime) * s_rewardRate * 1e18) / s_totalStaked;
    }

    function earned(address _account) public view returns (uint256) {
        return ((s_balances[_account] * (rewardPerToken() - s_userRewardPerTokenPaid[_account])) / 1e18) + s_rewards[_account];
    }

    function balanceOf(address _account) external view returns (uint256) {
        return s_balances[_account];
    }

    function stakingTokenBalance() external view returns (uint256) {
        return i_stakingToken.balanceOf(address(this));
    }

    // ── Stake ───────────────────────────────────────

    function stake(uint256 _amount) external nonReentrant updateReward(msg.sender) {
        if (_amount == 0) revert StakingPool__ZeroAmount();
        i_stakingToken.safeTransferFrom(msg.sender, address(this), _amount);
        s_balances[msg.sender] += _amount;
        s_totalStaked += _amount;
        s_lastStakeTime[msg.sender] = block.timestamp;
        emit Staked(msg.sender, _amount);
    }

    // ── Withdraw (Pull-over-push: user pulls funds) ─

    function withdraw(uint256 _amount) external nonReentrant updateReward(msg.sender) {
        if (_amount == 0) revert StakingPool__ZeroAmount();
        if (s_balances[msg.sender] < _amount) revert StakingPool__InsufficientBalance();

        // Pharos-specific: check min stake duration
        if (block.timestamp < s_lastStakeTime[msg.sender] + s_minStakeDuration) {
            revert StakingPool__StakeLocked(s_lastStakeTime[msg.sender] + s_minStakeDuration);
        }

        s_balances[msg.sender] -= _amount;
        s_totalStaked -= _amount;
        i_stakingToken.safeTransfer(msg.sender, _amount);
        emit Withdrawn(msg.sender, _amount);
    }

    // ── Claim Rewards (Pull-over-push: user pulls) ─

    function claimReward() external nonReentrant updateReward(msg.sender) {
        uint256 reward = s_rewards[msg.sender];
        if (reward == 0) revert StakingPool__NoRewards();
        s_rewards[msg.sender] = 0;
        i_rewardToken.safeTransfer(msg.sender, reward);
        emit RewardPaid(msg.sender, reward);
    }

    // ── Owner ───────────────────────────────────────

    function setRewardRate(uint256 _newRate) external onlyOwner updateReward(address(0)) {
        s_rewardRate = _newRate;
        emit RewardRateUpdated(_newRate);
    }

    function setMinStakeDuration(uint256 _duration) external onlyOwner {
        if (_duration > 7 days) revert StakingPool__RewardDurationTooLong();
        s_minStakeDuration = _duration;
        emit MinStakeDurationUpdated(_duration);
    }

    function fundRewards(uint256 _amount) external onlyOwner {
        if (_amount == 0) revert StakingPool__ZeroAmount();
        i_rewardToken.safeTransferFrom(msg.sender, address(this), _amount);
    }

    /// @notice Emergency recovery: recover stuck tokens (not staking/reward tokens)
    function recoverTokens(address _token, uint256 _amount) external onlyOwner {
        if (_token == address(i_stakingToken) || _token == address(i_rewardToken)) revert StakingPool__InsufficientBalance();
        IERC20(_token).safeTransfer(i_owner, _amount);
    }
}
