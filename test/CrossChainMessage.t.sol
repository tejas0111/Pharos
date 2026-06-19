// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {Test} from "forge-std/Test.sol";
import {CrossChainMessage} from "../contracts/CrossChainMessage.sol";

contract CrossChainMessageTest is Test {
    CrossChainMessage public sourceChain;
    CrossChainMessage public destChain;

    address public OWNER = address(0x1234);
    address public USER = address(0x5678);
    uint256 public SOURCE_CHAIN_ID = 688689;
    uint256 public DEST_CHAIN_ID = 1672;

    function setUp() public {
        vm.prank(OWNER);
        sourceChain = new CrossChainMessage(SOURCE_CHAIN_ID);

        vm.prank(OWNER);
        destChain = new CrossChainMessage(DEST_CHAIN_ID);

        // Register peers
        vm.prank(OWNER);
        sourceChain.registerPeer(DEST_CHAIN_ID, address(destChain));
        vm.prank(OWNER);
        destChain.registerPeer(SOURCE_CHAIN_ID, address(sourceChain));
    }

    // ── Constructor ────────────────────────────────

    function test_Constructor_SetsChainId() public {
        assertEq(sourceChain.i_chainId(), SOURCE_CHAIN_ID);
        assertEq(destChain.i_chainId(), DEST_CHAIN_ID);
    }

    function test_Constructor_SetsOwner() public {
        assertEq(sourceChain.i_owner(), OWNER);
    }

    // ── Peer Management ────────────────────────────

    function test_RegisterPeer() public {
        uint256[] memory peers = sourceChain.getTrustedChainIds();
        assertEq(peers.length, 1);
        assertEq(peers[0], DEST_CHAIN_ID);
    }

    function test_RegisterPeer_RevertsOnNonOwner() public {
        vm.prank(USER);
        vm.expectRevert(CrossChainMessage.CrossChain__NotOwner.selector);
        sourceChain.registerPeer(999, address(0x9999));
    }

    function test_RemovePeer() public {
        vm.prank(OWNER);
        sourceChain.removePeer(DEST_CHAIN_ID);

        vm.prank(OWNER);
        vm.expectRevert(CrossChainMessage.CrossChain__NotTrustedPeer.selector);
        sourceChain.deliverMessage(1, USER, "", DEST_CHAIN_ID);
    }

    // ── Send Message ───────────────────────────────

    function test_SendMessage_CreatesMessage() public {
        bytes memory payload = abi.encodeWithSignature("someFunction()");

        vm.prank(USER);
        uint256 msgId = sourceChain.sendMessage(DEST_CHAIN_ID, address(destChain), payload);

        assertEq(msgId, 1);
        assertEq(sourceChain.getUserMessageCount(USER), 1);
    }

    function test_SendMessage_RevertsOnSameChain() public {
        vm.prank(USER);
        vm.expectRevert(CrossChainMessage.CrossChain__InvalidChainId.selector);
        sourceChain.sendMessage(SOURCE_CHAIN_ID, address(destChain), "");
    }

    function test_SendMessage_RevertsOnEmptyPayload() public {
        vm.prank(USER);
        vm.expectRevert(CrossChainMessage.CrossChain__EmptyPayload.selector);
        sourceChain.sendMessage(DEST_CHAIN_ID, address(destChain), "");
    }

    // ── Deliver Message ────────────────────────────

    function test_DeliverMessage() public {
        bytes memory payload = abi.encodeWithSignature("someFunction()");

        vm.prank(USER);
        uint256 msgId = sourceChain.sendMessage(DEST_CHAIN_ID, address(destChain), payload);

        vm.prank(OWNER);
        destChain.deliverMessage(msgId, USER, payload, SOURCE_CHAIN_ID);

        // In a real scenario, the payload would call a function. Here it fails silently
        // because destChain doesn't have `someFunction`, but that's expected in this test
        CrossChainMessage.Message memory msg_ = destChain.getMessage(msgId);
        assertTrue(msg_.delivered || msg_.failed, "Message should be delivered or failed");
    }

    function test_DeliverMessage_RevertsOnUntrustedPeer() public {
        vm.prank(OWNER);
        destChain.removePeer(SOURCE_CHAIN_ID);

        vm.prank(USER);
        uint256 msgId = sourceChain.sendMessage(DEST_CHAIN_ID, address(destChain), "0x00");

        vm.prank(USER);
        vm.expectRevert(CrossChainMessage.CrossChain__NotTrustedPeer.selector);
        destChain.deliverMessage(msgId, USER, "0x00", SOURCE_CHAIN_ID);
    }

    // ── Message Queries ────────────────────────────

    function test_GetUserMessages() public {
        bytes memory payload = abi.encodeWithSignature("someFunction()");

        vm.prank(USER);
        sourceChain.sendMessage(DEST_CHAIN_ID, address(destChain), payload);
        vm.prank(USER);
        sourceChain.sendMessage(DEST_CHAIN_ID, address(destChain), payload);

        uint256[] memory messages = sourceChain.getUserMessages(USER);
        assertEq(messages.length, 2);
    }
}
