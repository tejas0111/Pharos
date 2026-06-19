// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import "forge-std/Test.sol";
import "../contracts/PharosTimelockController.sol";

contract PharosTimelockControllerTest is Test {
    PharosTimelockController public timelock;
    address public OWNER = address(0x1234);
    address public PROPOSER = address(0x5678);
    address public EXECUTOR = address(0x9ABC);
    address public TARGET;
    receive() external payable {}

    uint256 constant DELAY = 1 hours;

    function setUp() public {
        vm.prank(OWNER);
        timelock = new PharosTimelockController(DELAY);
        TARGET = address(this); // Self-target for testing

        vm.prank(OWNER);
        timelock.addProposer(PROPOSER);
        vm.prank(OWNER);
        timelock.addExecutor(EXECUTOR);
    }

    function test_Constructor_SetsDelayAndOwner() public {
        assertEq(timelock.s_delay(), DELAY);
        assertEq(timelock.i_owner(), OWNER);
    }

    function test_Constructor_OwnerIsProposerAndExecutor() public {
        assertTrue(timelock.s_proposers(OWNER));
        assertTrue(timelock.s_executors(OWNER));
    }

    function test_Queue_Proposal() public {
        vm.prank(PROPOSER);
        bytes32 id = timelock.queue(TARGET, 0, "");

        assertTrue(timelock.s_queuedProposals(id));
    }

    function test_Execute_AfterDelay() public {
        vm.prank(PROPOSER);
        bytes32 id = timelock.queue(TARGET, 0, "");

        vm.warp(block.timestamp + DELAY);

        vm.prank(EXECUTOR);
        timelock.execute(TARGET, 0, "");
    }

    function test_Execute_RevertsBeforeDelay() public {
        vm.prank(PROPOSER);
        timelock.queue(TARGET, 0, "");

        vm.prank(EXECUTOR);
        vm.expectRevert(abi.encodeWithSignature("PharosTimelockController__ProposalNotReady()"));
        timelock.execute(TARGET, 0, "");
    }

    function test_Execute_RevertsExpired() public {
        vm.prank(PROPOSER);
        bytes32 id = timelock.queue(TARGET, 0, "");

        vm.warp(block.timestamp + DELAY + 15 days); // Past grace period

        vm.prank(EXECUTOR);
        vm.expectRevert(abi.encodeWithSignature("PharosTimelockController__ProposalExpired()"));
        timelock.execute(TARGET, 0, "");
    }

    function test_Cancel_Proposal() public {
        vm.prank(PROPOSER);
        bytes32 id = timelock.queue(TARGET, 0, "");

        vm.prank(PROPOSER);
        timelock.cancel(id);

        assertFalse(timelock.s_queuedProposals(id));
    }

    function test_Cancel_RevertsNotProposer() public {
        vm.prank(PROPOSER);
        bytes32 id = timelock.queue(TARGET, 0, "");

        vm.prank(EXECUTOR);
        vm.expectRevert(abi.encodeWithSignature("PharosTimelockController__NotProposer()"));
        timelock.cancel(id);
    }

    function test_Execute_RevertsNotExecutor() public {
        vm.prank(PROPOSER);
        bytes32 id = timelock.queue(TARGET, 0, "");

        vm.warp(block.timestamp + DELAY);

        vm.prank(PROPOSER);
        vm.expectRevert(abi.encodeWithSignature("PharosTimelockController__NotExecutor()"));
        timelock.execute(TARGET, 0, "");
    }

    function test_UpdateDelay() public {
        vm.prank(OWNER);
        timelock.updateDelay(2 hours);
        assertEq(timelock.s_delay(), 2 hours);
    }

    function test_AddRemoveProposer() public {
        address newProp = address(0xCAFE);
        vm.prank(OWNER);
        timelock.addProposer(newProp);
        assertTrue(timelock.s_proposers(newProp));

        vm.prank(OWNER);
        timelock.removeProposer(newProp);
        assertFalse(timelock.s_proposers(newProp));
    }

    function test_AddRemoveExecutor() public {
        address newExec = address(0xCAFE);
        vm.prank(OWNER);
        timelock.addExecutor(newExec);
        assertTrue(timelock.s_executors(newExec));

        vm.prank(OWNER);
        timelock.removeExecutor(newExec);
        assertFalse(timelock.s_executors(newExec));
    }
}
