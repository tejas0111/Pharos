// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {Test} from "forge-std/Test.sol";
import {PharosZkLogin} from "../contracts/PharosZkLogin.sol";

/// @title ZkLogin Tests
/// @notice Test suite for PharosZkLogin
contract PharosZkLoginTest is Test {
    PharosZkLogin public zkLogin;
    address public owner;
    address public user = address(0xABCD);
    address public stranger = address(0xDEAD);

    uint256 constant TEST_COMMITMENT = 123456789;
    uint256 constant TEST_PROVIDER = 0; // Google
    uint256 constant TEST_AUD = 42;
    uint256 constant TEST_EXP = 1000000;

    function setUp() external {
        owner = address(this);
        zkLogin = new PharosZkLogin(block.chainid);
    }

    // ── Constructor ──

    function test_Constructor() external {
        assertEq(zkLogin.i_owner(), owner);
        assertEq(zkLogin.i_chainId(), block.chainid);
    }

    // ── Identity Management ──

    function test_RegisterIdentity() external {
        vm.prank(user);
        zkLogin.registerIdentity(TEST_COMMITMENT, TEST_PROVIDER, TEST_AUD, TEST_EXP);

        PharosZkLogin.Identity memory identity = zkLogin.getIdentity(user);
        assertTrue(identity.registered);
        assertEq(identity.commitment, TEST_COMMITMENT);
        assertEq(identity.provider, TEST_PROVIDER);
        assertEq(identity.aud, TEST_AUD);

        // Check commitment lookup
        assertEq(zkLogin.getAddressFromCommitment(TEST_COMMITMENT), user);
    }

    function test_RevertWhen_DuplicateCommitment() external {
        vm.prank(user);
        zkLogin.registerIdentity(TEST_COMMITMENT, TEST_PROVIDER, TEST_AUD, TEST_EXP);

        vm.prank(stranger);
        vm.expectRevert(PharosZkLogin.PharosZkLogin__IdentityExists.selector);
        zkLogin.registerIdentity(TEST_COMMITMENT, TEST_PROVIDER, TEST_AUD, TEST_EXP);
    }

    // ── Ephemeral Keys ──

    function test_VerifyAndRegisterKey() external {
        vm.prank(user);
        zkLogin.registerIdentity(TEST_COMMITMENT, TEST_PROVIDER, TEST_AUD, TEST_EXP);

        uint256 pubKeyX = 0x1234;
        uint256 pubKeyY = 0x5678;

        PharosZkLogin.ZkLoginProof memory proof = _emptyProof();

        vm.prank(user);
        zkLogin.verifyAndRegisterKey(proof, pubKeyX, pubKeyY);

        assertTrue(zkLogin.verifyEphemeralSignature(user, pubKeyX, pubKeyY));
    }

    function test_RevertWhen_NoIdentity() external {
        uint256 pubKeyX = 0x1234;
        uint256 pubKeyY = 0x5678;

        PharosZkLogin.ZkLoginProof memory proof = _emptyProof();

        vm.prank(user);
        vm.expectRevert(PharosZkLogin.PharosZkLogin__IdentityNotRegistered.selector);
        zkLogin.verifyAndRegisterKey(proof, pubKeyX, pubKeyY);
    }

    function test_RevokeEphemeralKey() external {
        vm.prank(user);
        zkLogin.registerIdentity(TEST_COMMITMENT, TEST_PROVIDER, TEST_AUD, TEST_EXP);

        uint256 pubKeyX = 0x1234;
        uint256 pubKeyY = 0x5678;

        PharosZkLogin.ZkLoginProof memory proof = _emptyProof();

        vm.prank(user);
        zkLogin.verifyAndRegisterKey(proof, pubKeyX, pubKeyY);

        vm.prank(user);
        zkLogin.revokeEphemeralKey();

        assertFalse(zkLogin.verifyEphemeralSignature(user, pubKeyX, pubKeyY));
    }

    function test_VerifyExpiredKey() external {
        vm.prank(user);
        zkLogin.registerIdentity(TEST_COMMITMENT, TEST_PROVIDER, TEST_AUD, TEST_EXP);

        uint256 pubKeyX = 0x1234;
        uint256 pubKeyY = 0x5678;

        PharosZkLogin.ZkLoginProof memory proof = _emptyProof();

        vm.prank(user);
        zkLogin.verifyAndRegisterKey(proof, pubKeyX, pubKeyY);

        // Warp past expiration
        vm.warp(block.timestamp + 2 hours);

        assertFalse(zkLogin.verifyEphemeralSignature(user, pubKeyX, pubKeyY));
    }

    function test_RevertWhen_DuplicateKey() external {
        vm.prank(user);
        zkLogin.registerIdentity(TEST_COMMITMENT, TEST_PROVIDER, TEST_AUD, TEST_EXP);

        PharosZkLogin.ZkLoginProof memory proof = _emptyProof();

        vm.prank(user);
        zkLogin.verifyAndRegisterKey(proof, 0x1234, 0x5678);

        vm.prank(user);
        vm.expectRevert(PharosZkLogin.PharosZkLogin__KeyAlreadyExists.selector);
        zkLogin.verifyAndRegisterKey(proof, 0x9ABC, 0xDEF0);
    }

    // ── Owner Functions ──

    function test_SetEphemeralKeyDuration() external {
        zkLogin.setEphemeralKeyDuration(2 hours);
        assertEq(zkLogin.s_ephemeralKeyDuration(), 2 hours);
    }

    function test_RevertWhen_NonOwnerSetsDuration() external {
        vm.prank(stranger);
        vm.expectRevert(PharosZkLogin.PharosZkLogin__NotOwner.selector);
        zkLogin.setEphemeralKeyDuration(2 hours);
    }

    // ── Helpers ──

    function _emptyProof() internal pure returns (PharosZkLogin.ZkLoginProof memory proof) {
        proof.a = [uint256(0), uint256(0)];
        proof.b = [[uint256(0), uint256(0)], [uint256(0), uint256(0)]];
        proof.c = [uint256(0), uint256(0)];
        proof.publicInputs = [uint256(0), uint256(0)];
    }
}
