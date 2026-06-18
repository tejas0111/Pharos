// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import "forge-std/Test.sol";
import {Counter} from "../contracts/Counter.sol";

contract CounterTest is Test {
    Counter private s_counter;
    address private constant OWNER = address(0x1234);
    address private constant USER = address(0x5678);

    function setUp() public {
        vm.prank(OWNER);
        s_counter = new Counter();
    }

    // --- Constructor ---
    function test_Constructor_SetsOwner() public view {
        assertEq(s_counter.getOwner(), OWNER);
    }

    function test_Constructor_StartsAtZero() public view {
        assertEq(s_counter.getCount(), 0);
    }

    // --- Increment ---
    function test_Increment_IncreasesCount() public {
        vm.prank(USER);
        vm.expectEmit(true, true, true, true, address(s_counter));
        emit Counter.CounterIncremented(USER, 1);
        s_counter.increment();
        assertEq(s_counter.getCount(), 1);
    }

    function test_Increment_MultipleTimes() public {
        vm.startPrank(USER);
        s_counter.increment();
        s_counter.increment();
        s_counter.increment();
        vm.stopPrank();
        assertEq(s_counter.getCount(), 3);
    }

    // --- Decrement ---
    function test_Decrement_DecreasesCount() public {
        vm.prank(USER);
        s_counter.increment();
        s_counter.increment();

        vm.prank(USER);
        vm.expectEmit(true, true, true, true, address(s_counter));
        emit Counter.CounterDecremented(USER, 1);
        s_counter.decrement();
        assertEq(s_counter.getCount(), 1);
    }

    function test_Decrement_RevertsWhenZero() public {
        vm.prank(USER);
        vm.expectRevert(Counter.Counter__CannotDecrementBelowZero.selector);
        s_counter.decrement();
    }

    function test_Decrement_RevertByFuzzing(uint256 increments) public {
        increments = bound(increments, 1, 500);
        vm.prank(USER);
        for (uint256 i = 0; i < increments; i++) {
            s_counter.increment();
        }
        vm.prank(USER);
        for (uint256 i = 0; i < increments; i++) {
            s_counter.decrement();
        }
        assertEq(s_counter.getCount(), 0);
    }

    // --- Reset ---
    function test_Reset_SetsCountToZero() public {
        vm.prank(USER);
        s_counter.increment();
        s_counter.increment();
        s_counter.increment();

        vm.prank(OWNER);
        vm.expectEmit(true, true, true, true, address(s_counter));
        emit Counter.CounterReset(OWNER);
        s_counter.reset();
        assertEq(s_counter.getCount(), 0);
    }

    function test_Reset_RevertsWhenNotOwner() public {
        vm.prank(USER);
        s_counter.increment();

        vm.prank(USER);
        vm.expectRevert(Counter.Counter__NotOwner.selector);
        s_counter.reset();
    }
}
