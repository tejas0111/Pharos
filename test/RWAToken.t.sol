// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {Test} from "forge-std/Test.sol";
import {RWAToken} from "../contracts/RWAToken.sol";

contract RWATokenTest is Test {
    RWAToken public token;

    address public OWNER = address(0x1234);
    address public USER = address(0x5678);
    address public USER2 = address(0x9ABC);
    address public UNWHITELISTED = address(0xDEF0);

    uint256 public constant MAX_SUPPLY = 1_000_000 ether;
    uint256 public constant PHAROS_CHAIN_ID = 688689;

    function setUp() public {
        vm.prank(OWNER);
        token = new RWAToken("PharosRWA", "PRWA", MAX_SUPPLY, PHAROS_CHAIN_ID);

        // Whitelist users
        vm.prank(OWNER);
        token.setWhitelist(USER, true);
        vm.prank(OWNER);
        token.setWhitelist(USER2, true);

        // Mint tokens to users
        vm.prank(OWNER);
        token.mint(USER, 1000 ether);
        vm.prank(OWNER);
        token.mint(USER2, 500 ether);
    }

    // ── Constructor ────────────────────────────────

    function test_Constructor_SetsMetadata() public {
        assertEq(token.i_name(), "PharosRWA");
        assertEq(token.i_symbol(), "PRWA");
        assertEq(token.decimals(), 18);
    }

    function test_Constructor_SetsOwner() public {
        assertEq(token.i_owner(), OWNER);
    }

    function test_Constructor_SetsMaxSupply() public {
        assertEq(token.maxSupply(), MAX_SUPPLY);
    }

    function test_Constructor_OwnerWhitelisted() public {
        assertTrue(token.s_whitelist(OWNER));
    }

    // ── Transfer ───────────────────────────────────

    function test_Transfer_WorksWhenWhitelisted() public {
        vm.prank(USER);
        bool success = token.transfer(USER2, 100 ether);
        assertTrue(success);
        assertEq(token.balanceOf(USER), 900 ether);
        assertEq(token.balanceOf(USER2), 600 ether);
    }

    function test_Transfer_RevertsOnUnwhitelistedReceiver() public {
        vm.prank(USER);
        vm.expectRevert(abi.encodeWithSelector(RWAToken.RWAToken__NotWhitelisted.selector, UNWHITELISTED));
        token.transfer(UNWHITELISTED, 100 ether);
    }

    function test_Transfer_RevertsOnSelfTransfer() public {
        vm.prank(USER);
        vm.expectRevert(RWAToken.RWAToken__SelfTransfer.selector);
        token.transfer(USER, 100 ether);
    }

    function test_Transfer_RevertsOnInsufficientBalance() public {
        vm.prank(USER);
        vm.expectRevert(RWAToken.RWAToken__InsufficientBalance.selector);
        token.transfer(USER2, 2000 ether);
    }

    // ── Transfer Cooldown ──────────────────────────

    function test_Transfer_RespectsCooldown() public {
        vm.prank(USER);
        token.transfer(USER2, 100 ether);

        // Second transfer within cooldown should revert
        vm.prank(USER);
        vm.expectRevert();
        token.transfer(USER2, 50 ether);
    }

    function test_Transfer_WorksAfterCooldown() public {
        vm.prank(USER);
        token.transfer(USER2, 100 ether);

        vm.warp(block.timestamp + token.s_transferCooldown() + 1);

        vm.prank(USER);
        bool success = token.transfer(USER2, 50 ether);
        assertTrue(success);
    }

    // ── Whitelist Enforcement ──────────────────────

    function test_WhitelistEnforcement_CanBeDisabled() public {
        vm.prank(OWNER);
        token.setWhitelistEnforced(false);
        vm.prank(OWNER);
        token.mint(UNWHITELISTED, 100 ether);
        vm.prank(UNWHITELISTED);
        token.transfer(USER, 1);
    }

    // ── Minting ────────────────────────────────────

    function test_Mint_OnlyOwner() public {
        vm.prank(OWNER);
        token.mint(USER, 1000 ether);
        assertEq(token.balanceOf(USER), 2000 ether);
    }

    function test_Mint_RevertsOnNonOwner() public {
        vm.prank(USER);
        vm.expectRevert(RWAToken.RWAToken__NotOwner.selector);
        token.mint(USER, 100 ether);
    }

    function test_Mint_RevertsOnMaxSupply() public {
        vm.prank(OWNER);
        vm.expectRevert(RWAToken.RWAToken__SupplyCapExceeded.selector);
        token.mint(USER, MAX_SUPPLY);
    }

    // ── Burning ────────────────────────────────────

    function test_Burn_DecreasesSupply() public {
        uint256 totalBefore = token.totalSupply();
        vm.prank(USER);
        token.burn(500 ether);
        assertEq(token.totalSupply(), totalBefore - 500 ether);
    }

    function test_Burn_RevertsOnInsufficientBalance() public {
        vm.prank(USER);
        vm.expectRevert(RWAToken.RWAToken__InsufficientBalance.selector);
        token.burn(2000 ether);
    }

    // ── Supply Cap ─────────────────────────────────

    function test_UpdateSupplyCap_OnlyOwner() public {
        vm.prank(OWNER);
        token.updateSupplyCap(2_000_000 ether);
        assertEq(token.maxSupply(), 2_000_000 ether);
    }

    function test_UpdateSupplyCap_RevertsBelowTotal() public {
        vm.prank(OWNER);
        vm.expectRevert(RWAToken.RWAToken__SupplyCapExceeded.selector);
        token.updateSupplyCap(100 ether);
    }
}
