// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {Test} from "forge-std/Test.sol";
import {PharosSPNPaymaster} from "../contracts/PharosSPNPaymaster.sol";

/// @title SPN Paymaster Tests
/// @notice Test suite for PharosSPNPaymaster
contract PharosSPNPaymasterTest is Test {
    PharosSPNPaymaster public paymaster;
    address public entryPoint = address(0x1234);
    address public owner;
    address public user = address(0xABCD);
    address public stranger = address(0xDEAD);

    function setUp() external {
        owner = address(this);
        paymaster = new PharosSPNPaymaster(entryPoint, block.chainid);
    }

    // ── Constructor ──

    function test_Constructor() external {
        assertEq(paymaster.i_entryPoint(), entryPoint);
        assertEq(paymaster.i_owner(), owner);
        assertEq(paymaster.i_chainId(), block.chainid);
        assertEq(paymaster.s_paused(), false);
    }

    function test_RevertWhen_ZeroEntryPoint() external {
        vm.expectRevert(PharosSPNPaymaster.PharosSPNPaymaster__ZeroAddress.selector);
        new PharosSPNPaymaster(address(0), block.chainid);
    }

    // ── Sponsorship Management ──

    function test_AddSponsor() external {
        paymaster.addSponsor(user);
        assertTrue(paymaster.s_whitelistedSenders(user));
    }

    function test_RevertWhen_NonOwnerAddsSponsor() external {
        vm.prank(stranger);
        vm.expectRevert(PharosSPNPaymaster.PharosSPNPaymaster__NotOwner.selector);
        paymaster.addSponsor(user);
    }

    function test_BatchAddSponsors() external {
        address[] memory users = new address[](3);
        users[0] = address(0x1);
        users[1] = address(0x2);
        users[2] = address(0x3);
        paymaster.addSponsors(users);
        assertTrue(paymaster.s_whitelistedSenders(address(0x1)));
        assertTrue(paymaster.s_whitelistedSenders(address(0x2)));
        assertTrue(paymaster.s_whitelistedSenders(address(0x3)));
    }

    function test_RemoveSponsor() external {
        paymaster.addSponsor(user);
        assertTrue(paymaster.s_whitelistedSenders(user));
        paymaster.removeSponsor(user);
        assertFalse(paymaster.s_whitelistedSenders(user));
    }

    function test_SetSponsorBudget() external {
        paymaster.setSponsorBudget(user, 100 ether);
        assertEq(paymaster.s_sponsorBudgets(user), 100 ether);
    }

    function test_SetGlobalBudget() external {
        paymaster.setGlobalBudget(1000 ether);
        assertEq(paymaster.s_globalBudget(), 1000 ether);
    }

    // ── Pause ──

    function test_Pause() external {
        paymaster.pause();
        assertTrue(paymaster.s_paused());
        paymaster.unpause();
        assertFalse(paymaster.s_paused());
    }

    function test_RevertWhen_NonOwnerPauses() external {
        vm.prank(stranger);
        vm.expectRevert(PharosSPNPaymaster.PharosSPNPaymaster__NotOwner.selector);
        paymaster.pause();
    }

    // ── validatePaymasterUserOp ──

    function test_ValidatePaymasterUserOp() external {
        paymaster.addSponsor(user);

        PharosSPNPaymaster.PackedUserOperation memory op = _defaultUserOp(user);

        vm.prank(entryPoint);
        (bytes memory context, uint256 validationData) = paymaster.validatePaymasterUserOp(op, bytes32(0), 1 ether);

        assertEq(validationData, 0); // valid
        (address decodedUser, uint256 maxCost) = abi.decode(context, (address, uint256));
        assertEq(decodedUser, user);
        assertEq(maxCost, 1 ether);
    }

    function test_RevertWhen_NotWhitelisted() external {
        PharosSPNPaymaster.PackedUserOperation memory op = _defaultUserOp(stranger);

        vm.prank(entryPoint);
        vm.expectRevert(PharosSPNPaymaster.PharosSPNPaymaster__NotWhitelisted.selector);
        paymaster.validatePaymasterUserOp(op, bytes32(0), 1 ether);
    }

    function test_RevertWhen_Paused() external {
        paymaster.addSponsor(user);
        paymaster.pause();

        PharosSPNPaymaster.PackedUserOperation memory op = _defaultUserOp(user);

        vm.prank(entryPoint);
        vm.expectRevert(PharosSPNPaymaster.PharosSPNPaymaster__Paused.selector);
        paymaster.validatePaymasterUserOp(op, bytes32(0), 1 ether);
    }

    function test_RevertWhen_CallerNotEntryPoint() external {
        PharosSPNPaymaster.PackedUserOperation memory op = _defaultUserOp(user);

        vm.prank(stranger);
        vm.expectRevert(PharosSPNPaymaster.PharosSPNPaymaster__NotEntryPoint.selector);
        paymaster.validatePaymasterUserOp(op, bytes32(0), 1 ether);
    }

    // ── postOp ──

    function test_PostOp() external {
        paymaster.addSponsor(user);
        paymaster.setGlobalBudget(100 ether);

        bytes memory context = abi.encode(user, 1 ether);

        vm.prank(entryPoint);
        paymaster.postOp(PharosSPNPaymaster.PostOpMode.opSucceeded, context, 0.5 ether, 1 gwei);

        assertEq(paymaster.s_globalSpent(), 0.5 ether);
    }

    // ── View ──

    function test_CanSponsor() external {
        assertFalse(paymaster.canSponsor(user));
        paymaster.addSponsor(user);
        assertTrue(paymaster.canSponsor(user));
        paymaster.pause();
        assertFalse(paymaster.canSponsor(user));
    }

    function test_RemainingBudget() external {
        paymaster.setSponsorBudget(user, 100 ether);
        assertEq(paymaster.remainingBudget(user), 100 ether);
    }

    function test_RemainingGlobalBudget() external {
        paymaster.setGlobalBudget(100 ether);
        assertEq(paymaster.remainingGlobalBudget(), 100 ether);
    }

    // ── Helpers ──

    function _defaultUserOp(address sender) internal pure returns (PharosSPNPaymaster.PackedUserOperation memory) {
        return PharosSPNPaymaster.PackedUserOperation({
            sender: sender,
            nonce: 0,
            initCode: "",
            callData: "",
            accountGasLimits: bytes32(0),
            preVerificationGas: 0,
            gasFees: bytes32(0),
            paymasterAndData: "",
            signature: ""
        });
    }
}
