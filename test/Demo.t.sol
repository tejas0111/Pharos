// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import "forge-std/Test.sol";
import {Demo} from "../contracts/Demo.sol";

contract DemoTest is Test {
    Demo private s_demo;
    address private constant OWNER = address(0x1234);
    address private constant USER = address(0x5678);
    string private constant INITIAL_GREETING = "Hello, Pharos!";

    function setUp() public {
        vm.prank(OWNER);
        s_demo = new Demo(INITIAL_GREETING);
    }

    // --- Constructor ---
    function test_Constructor_SetsOwner() public view {
        assertEq(s_demo.owner(), OWNER);
    }

    function test_Constructor_SetsGreeting() public view {
        assertEq(s_demo.greeting(), INITIAL_GREETING);
    }

    function test_Constructor_RevertsEmptyGreeting() public {
        vm.expectRevert(Demo.Demo__EmptyGreeting.selector);
        new Demo("");
    }

    // --- Set Greeting ---
    function test_SetGreeting_UpdatesGreeting() public {
        string memory newGreeting = "GM Pharos!";
        vm.prank(OWNER);
        vm.expectEmit(true, true, true, true, address(s_demo));
        emit Demo.GreetingUpdated(OWNER, INITIAL_GREETING, newGreeting);
        s_demo.setGreeting(newGreeting);
        assertEq(s_demo.greeting(), newGreeting);
    }

    function test_SetGreeting_RevertsWhenNotOwner() public {
        vm.prank(USER);
        vm.expectRevert(Demo.Demo__NotOwner.selector);
        s_demo.setGreeting("hi");
    }

    function test_SetGreeting_RevertsEmptyGreeting() public {
        vm.prank(OWNER);
        vm.expectRevert(Demo.Demo__EmptyGreeting.selector);
        s_demo.setGreeting("");
    }
}
