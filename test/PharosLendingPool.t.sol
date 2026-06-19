// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {Test} from "forge-std/Test.sol";
import {PharosLendingPool} from "../contracts/PharosLendingPool.sol";

contract PharosLendingPoolTest is Test {
    PharosLendingPool public pool;
    address public OWNER;
    address public USER = address(0x5678);

    uint256 public constant MAX_CAPACITY = 10_000e18;
    uint256 public constant RESERVE_FACTOR = 1000;
    uint256 public constant COLLATERAL_RATIO = 15_000;
    uint256 public constant MAX_LTV = 7_500;
    uint256 public constant LIQUIDATION_BONUS = 1_000;
    uint256 public constant BASE_RATE = 1_000_000_000;
    uint256 public constant SLOPE1 = 2_000_000_000;
    uint256 public constant SLOPE2 = 10_000_000_000;
    uint256 public constant OPTIMAL_UTIL = 8_000;

    function setUp() public {
        OWNER = address(this);
        pool = new PharosLendingPool(
            MAX_CAPACITY, RESERVE_FACTOR, COLLATERAL_RATIO,
            MAX_LTV, LIQUIDATION_BONUS,
            BASE_RATE, SLOPE1, SLOPE2, OPTIMAL_UTIL
        );
        vm.deal(USER, 100_000e18);
    }

    function test_Constructor_SetsOwner() public { assertEq(pool.i_owner(), OWNER); }

    function test_Constructor_InitialState() public {
        assertEq(pool.s_totalSupplied(), 0);
        assertEq(pool.s_totalBorrows(), 0);
        assertEq(pool.getUtilization(), 0);
    }

    function test_Supply_DepositsFunds() public {
        vm.prank(USER); pool.supply{value: 1000e18}();
        assertEq(pool.s_totalSupplied(), 1000e18);
    }

    function test_Supply_RevertsCapacityExceeded() public {
        vm.prank(USER);
        vm.expectRevert(PharosLendingPool.PharosLendingPool__CapacityExceeded.selector);
        pool.supply{value: MAX_CAPACITY + 1}();
    }

    function test_Withdraw_Success() public {
        vm.prank(USER); pool.supply{value: 1000e18}();
        vm.prank(USER); pool.withdraw(500e18);
        assertEq(pool.s_totalSupplied(), 500e18);
    }

    function test_Borrow_Success() public {
        vm.prank(USER); pool.supply{value: 1000e18}();
        vm.prank(USER); pool.borrow(500e18);
        (, uint256 borrowed,) = pool.s_positions(USER);
        assertEq(borrowed, 500e18);
    }

    function test_Repay_Full() public {
        vm.prank(USER); pool.supply{value: 1000e18}();
        vm.prank(USER); pool.borrow(500e18);
        vm.prank(USER); pool.repay(500e18);
        (, uint256 borrowed,) = pool.s_positions(USER);
        assertEq(borrowed, 0);
    }

    function test_GetUtilization() public {
        vm.prank(USER); pool.supply{value: 1000e18}();
        vm.prank(USER); pool.borrow(500e18);
        // Returns (borrows * 1e18) / supply = (500e18 * 1e18) / 1000e18 = 5e17
        assertEq(pool.getUtilization(), 5e17);
    }

    function test_GetMaxBorrow() public {
        vm.prank(USER); pool.supply{value: 1000e18}();
        assertEq(pool.getMaxBorrow(USER), 750e18);
    }

    function test_Admin_SetPaused() public {
        vm.prank(OWNER); pool.setPaused(true);
        assertTrue(pool.s_paused());
    }

    function test_Admin_RevertsNonOwner() public {
        vm.prank(USER);
        vm.expectRevert(PharosLendingPool.PharosLendingPool__NotOwner.selector);
        pool.setPaused(true);
    }
}
