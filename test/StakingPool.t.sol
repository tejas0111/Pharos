// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {Test} from "forge-std/Test.sol";
import {StakingPool} from "../contracts/StakingPool.sol";
import {IERC20} from "../contracts/interfaces/IERC20.sol";

contract StakingPoolTest is Test {
    StakingPool public pool;
    IERC20 public stakingToken;
    IERC20 public rewardToken;

    address public OWNER = address(0x1234);
    address public USER = address(0x5678);
    address public USER2 = address(0x9ABC);

    uint256 public constant INITIAL_BALANCE = 100_000 ether;
    uint256 public constant REWARD_RATE = 1 ether; // 1 token per second
    uint256 public constant REWARD_DURATION = 30 days;
    uint256 public constant PHAROS_CHAIN_ID = 688689;

    function setUp() public {
        vm.startPrank(OWNER);

        // Deploy mock ERC20 tokens
        stakingToken = IERC20(address(new MockERC20("Stake Token", "STK", 18)));
        rewardToken = IERC20(address(new MockERC20("Reward Token", "RWD", 18)));

        // Deploy pool
        pool = new StakingPool(
            address(stakingToken),
            address(rewardToken),
            REWARD_RATE,
            REWARD_DURATION,
            PHAROS_CHAIN_ID
        );

        // Fund rewards
        MockERC20(address(rewardToken)).mint(OWNER, INITIAL_BALANCE);
        rewardToken.approve(address(pool), INITIAL_BALANCE);
        pool.fundRewards(INITIAL_BALANCE);

        // Fund users
        MockERC20(address(stakingToken)).mint(USER, INITIAL_BALANCE);
        MockERC20(address(stakingToken)).mint(USER2, INITIAL_BALANCE);

        vm.stopPrank();

        // Users approve pool
        vm.prank(USER);
        stakingToken.approve(address(pool), type(uint256).max);
        vm.prank(USER2);
        stakingToken.approve(address(pool), type(uint256).max);
    }

    // ── Constructor ────────────────────────────────

    function test_Constructor_SetsOwner() public {
        assertEq(pool.i_owner(), OWNER);
    }

    function test_Constructor_SetsChainId() public {
        assertEq(pool.i_chainId(), PHAROS_CHAIN_ID);
    }

    function test_Constructor_RevertsOnZeroAddress() public {
        vm.prank(OWNER);
        vm.expectRevert();
        new StakingPool(address(0), address(rewardToken), REWARD_RATE, REWARD_DURATION, PHAROS_CHAIN_ID);
    }

    function test_Constructor_RevertsOnLongDuration() public {
        vm.prank(OWNER);
        vm.expectRevert();
        new StakingPool(address(stakingToken), address(rewardToken), REWARD_RATE, 400 days, PHAROS_CHAIN_ID);
    }

    // ── Stake ──────────────────────────────────────

    function test_Stake_IncreasesBalance() public {
        vm.prank(USER);
        pool.stake(100 ether);
        vm.warp(block.timestamp + 7200);

        assertEq(pool.balanceOf(USER), 100 ether);
        assertEq(pool.s_totalStaked(), 100 ether);
    }

    function test_Stake_EmitsEvent() public {
        vm.prank(USER);
        vm.expectEmit(true, true, false, true);
        emit StakingPool.Staked(USER, 100 ether);
        pool.stake(100 ether);
        vm.warp(block.timestamp + 7200);
    }

    function test_Stake_RevertsOnZero() public {
        vm.prank(USER);
        vm.expectRevert(StakingPool.StakingPool__ZeroAmount.selector);
        pool.stake(0);
    }

    function test_Stake_RevertsOnInsufficientBalance() public {
        vm.prank(USER);
        vm.expectRevert();
        pool.stake(INITIAL_BALANCE * 2);
    }

    // ── Withdraw ───────────────────────────────────

    function test_Withdraw_DecreasesBalance() public {
        vm.prank(USER);
        pool.stake(100 ether);
        vm.warp(block.timestamp + 7200);

        vm.prank(USER);
        pool.withdraw(50 ether);

        assertEq(pool.balanceOf(USER), 50 ether);
        assertEq(pool.s_totalStaked(), 50 ether);
    }

    function test_Withdraw_RevertsOnLockedStake() public {
        vm.prank(USER);
        pool.stake(100 ether);


        vm.prank(USER);
        vm.expectRevert();
        pool.withdraw(50 ether);
    }

    // ── Rewards ────────────────────────────────────

    function test_Rewards_AccrueOverTime() public {
        vm.prank(USER);
        pool.stake(100 ether);
        vm.warp(block.timestamp + 7200);

        vm.warp(block.timestamp + 10 seconds);

        uint256 earned = pool.earned(USER);
        assertTrue(earned > 0, "Should have earned rewards");
    }

    function test_ClaimReward_TransfersTokens() public {
        vm.prank(USER);
        pool.stake(100 ether);
        vm.warp(block.timestamp + 7200);

        vm.warp(block.timestamp + 10 seconds);

        uint256 balBefore = rewardToken.balanceOf(USER);
        vm.prank(USER);
        pool.claimReward();
        uint256 balAfter = rewardToken.balanceOf(USER);

        assertTrue(balAfter > balBefore, "Should have received reward tokens");
    }

    function test_ClaimReward_RevertsOnNoRewards() public {
        vm.prank(USER);
        vm.expectRevert(StakingPool.StakingPool__NoRewards.selector);
        pool.claimReward();
    }

    // ── Owner ───────────────────────────────────────

    function test_OnlyOwner_CanSetRewardRate() public {
        vm.prank(OWNER);
        pool.setRewardRate(2 ether);
        assertEq(pool.s_rewardRate(), 2 ether);
    }

    function test_OnlyOwner_RevertsOnNonOwner() public {
        vm.prank(USER);
        vm.expectRevert(StakingPool.StakingPool__NotOwner.selector);
        pool.setRewardRate(2 ether);
    }

    // ── Fuzzing ────────────────────────────────────

    function testFuzz_StakeAndWithdraw(uint96 _amount) public {
        uint256 amount = uint256(_amount) % 1000 ether + 1;
        vm.assume(amount <= MockERC20(address(stakingToken)).balanceOf(USER));

        vm.prank(USER);
        pool.stake(amount);
        assertEq(pool.balanceOf(USER), amount);

        vm.warp(block.timestamp + pool.s_minStakeDuration() + 1);

        vm.prank(USER);
        pool.withdraw(amount);
        assertEq(pool.balanceOf(USER), 0);
    }
}

// ── Mock ERC20 (minimal, for testing) ─────────────

contract MockERC20 is IERC20 {
    string public name;
    string public symbol;
    uint8 public decimals;
    uint256 public totalSupply;
    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;

    constructor(string memory _name, string memory _symbol, uint8 _decimals) {
        name = _name;
        symbol = _symbol;
        decimals = _decimals;
    }

    function mint(address to, uint256 amount) external {
        totalSupply += amount;
        balanceOf[to] += amount;
        emit Transfer(address(0), to, amount);
    }

    function transfer(address to, uint256 value) external returns (bool) {
        balanceOf[msg.sender] -= value;
        balanceOf[to] += value;
        emit Transfer(msg.sender, to, value);
        return true;
    }

    function approve(address spender, uint256 value) external returns (bool) {
        allowance[msg.sender][spender] = value;
        emit Approval(msg.sender, spender, value);
        return true;
    }

    function transferFrom(address from, address to, uint256 value) external returns (bool) {
        allowance[from][msg.sender] -= value;
        balanceOf[from] -= value;
        balanceOf[to] += value;
        emit Transfer(from, to, value);
        return true;
    }
}
