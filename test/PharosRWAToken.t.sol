// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {Test} from "forge-std/Test.sol";
import {PharosRWAToken} from "../contracts/PharosRWAToken.sol";

contract PharosRWATokenTest is Test {
    PharosRWAToken public token;

    address public constant OWNER = address(0x1);
    address public constant LEGAL_ADMIN = address(0x2);
    address public constant USER = address(0x3);
    address public constant USER2 = address(0x4);
    address public constant UNWHITELISTED = address(0x5);

    uint256 public constant INITIAL_SUPPLY = 1_000_000e18;
    uint256 public constant SUPPLY_CAP = 100_000_000e18;

    function setUp() public {
        vm.startPrank(OWNER);
        token = new PharosRWAToken(
            "Pharos RealWorld Asset",
            "pRWA",
            18,
            INITIAL_SUPPLY,
            SUPPLY_CAP,
            LEGAL_ADMIN
        );
        vm.stopPrank();

        // Set KYC for test users
        vm.prank(LEGAL_ADMIN);
        token.setKYC(USER, type(uint256).max);
        vm.prank(LEGAL_ADMIN);
        token.setKYC(USER2, type(uint256).max);

        // Fund users
        vm.prank(OWNER);
        token.transfer(USER, 100_000e18);
        vm.prank(OWNER);
        token.transfer(USER2, 50_000e18);
    }

    // ──────────────────────────────────────────────
    // Constructor
    // ──────────────────────────────────────────────
    function test_Constructor_SetsMetadata() public {
        assertEq(token.name(), "Pharos RealWorld Asset");
        assertEq(token.symbol(), "pRWA");
        assertEq(token.decimals(), 18);
        assertEq(token.i_owner(), OWNER);
        assertEq(token.i_legalAdmin(), LEGAL_ADMIN);
        assertEq(token.s_supplyCap(), SUPPLY_CAP);
        assertEq(token.s_totalSupply(), INITIAL_SUPPLY);
        assertEq(token.s_transferCooldown(), 30);
    }

    function test_Constructor_RevertsZeroLegalAdmin() public {
        vm.expectRevert(PharosRWAToken.PharosRWAToken__ZeroAddress.selector);
        new PharosRWAToken("T", "T", 18, 0, SUPPLY_CAP, address(0));
    }

    // ──────────────────────────────────────────────
    // Transfer & KYC
    // ──────────────────────────────────────────────
    function test_Transfer_WorksWithKYC() public {
        vm.prank(USER);
        token.transfer(USER2, 1000e18);

        assertEq(token.balanceOf(USER), 99_000e18);
        assertEq(token.balanceOf(USER2), 51_000e18);
    }

    function test_Transfer_RevertsWithoutKYC() public {
        vm.prank(OWNER);
        vm.expectRevert(
            abi.encodeWithSelector(PharosRWAToken.PharosRWAToken__KYCExpired.selector, UNWHITELISTED)
        );
        token.transfer(UNWHITELISTED, 1000e18);
    }

    function test_Transfer_RevertsFrozenAccount() public {
        vm.prank(LEGAL_ADMIN);
        token.freeze(USER);

        vm.prank(USER);
        vm.expectRevert(
            abi.encodeWithSelector(PharosRWAToken.PharosRWAToken__FrozenAccount.selector, USER)
        );
        token.transfer(USER2, 1000e18);
    }

    // ──────────────────────────────────────────────
    // Transfer Cooldown (merged from RWAToken)
    // ──────────────────────────────────────────────
    function test_TransferCooldown_RevertsWithinCooldown() public {
        vm.prank(USER);
        token.transfer(USER2, 1000e18);

        // Second transfer from same sender should revert during cooldown
        vm.prank(USER);
        vm.expectRevert(
            abi.encodeWithSelector(PharosRWAToken.PharosRWAToken__TransferCooldown.selector, USER, 30)
        );
        token.transfer(USER2, 500e18);
    }

    function test_TransferCooldown_AllowsAfterCooldown() public {
        vm.prank(USER);
        token.transfer(USER2, 1000e18);

        // Warp past the 30-second cooldown
        vm.warp(block.timestamp + 31);

        vm.prank(USER);
        token.transfer(USER2, 500e18);

        assertEq(token.balanceOf(USER2), 51_500e18);
    }

    function test_TransferCooldown_NotAppliedToOwner() public {
        // Owner should not have cooldown
        vm.prank(OWNER);
        token.transfer(USER, 1000e18);

        vm.prank(OWNER);
        token.transfer(USER2, 1000e18);  // Should not revert

        assertEq(token.balanceOf(USER2), 51_000e18);
    }

    function test_TransferCooldown_CanBeChanged() public {
        vm.prank(OWNER);
        token.setTransferCooldown(60);

        assertEq(token.s_transferCooldown(), 60);
    }

    function test_TransferCooldown_NotAppliedOnZeroCooldown() public {
        vm.prank(OWNER);
        token.setTransferCooldown(0);

        vm.prank(USER);
        token.transfer(USER2, 1000e18);

        // Should work immediately with cooldown = 0
        vm.prank(USER);
        token.transfer(USER2, 500e18);

        assertEq(token.balanceOf(USER2), 51_500e18);
    }

    // ──────────────────────────────────────────────
    // TransferFrom
    // ──────────────────────────────────────────────
    function test_TransferFrom_Works() public {
        vm.prank(USER);
        token.approve(USER2, 5000e18);

        vm.prank(USER2);
        token.transferFrom(USER, USER2, 2000e18);

        assertEq(token.balanceOf(USER), 98_000e18);
        assertEq(token.balanceOf(USER2), 52_000e18);
        assertEq(token.allowance(USER, USER2), 3000e18);
    }

    // ──────────────────────────────────────────────
    // Mint & Burn
    // ──────────────────────────────────────────────
    function test_Mint_OnlyOwner() public {
        vm.prank(OWNER);
        token.mint(USER, 10_000e18);
        assertEq(token.balanceOf(USER), 110_000e18);
        assertEq(token.totalSupply(), INITIAL_SUPPLY + 10_000e18);
    }

    function test_Mint_RevertsNonOwner() public {
        vm.prank(USER);
        vm.expectRevert(PharosRWAToken.PharosRWAToken__NotOwner.selector);
        token.mint(USER, 1000e18);
    }

    function test_Mint_RevertsExceedsCap() public {
        uint256 hugeAmount = SUPPLY_CAP;
        vm.prank(OWNER);
        vm.expectRevert(PharosRWAToken.PharosRWAToken__SupplyCapExceeded.selector);
        token.mint(USER, hugeAmount);
    }

    function test_Burn_Works() public {
        vm.prank(USER);
        token.burn(10_000e18);
        assertEq(token.balanceOf(USER), 90_000e18);
        assertEq(token.totalSupply(), INITIAL_SUPPLY - 10_000e18);
    }

    function test_Burn_RevertsExceedsBalance() public {
        vm.prank(USER);
        vm.expectRevert(PharosRWAToken.PharosRWAToken__SupplyCapExceeded.selector);
        token.burn(200_000e18);
    }

    // ──────────────────────────────────────────────
    // KYC Expiry
    // ──────────────────────────────────────────────
    function test_KYC_Expiry() public {
        vm.prank(LEGAL_ADMIN);
        token.setKYC(USER, block.timestamp + 1 days);

        // Still valid today
        vm.prank(USER);
        token.transfer(USER2, 1000e18);

        // After expiry
        vm.warp(block.timestamp + 2 days);
        vm.prank(USER);
        vm.expectRevert(
            abi.encodeWithSelector(PharosRWAToken.PharosRWAToken__KYCExpired.selector, USER)
        );
        token.transfer(USER2, 1000e18);
    }

    // ──────────────────────────────────────────────
    // Admin: KYC & Freeze
    // ──────────────────────────────────────────────
    function test_SetKYC_OnlyLegalOrOwner() public {
        vm.prank(USER);
        vm.expectRevert(PharosRWAToken.PharosRWAToken__NotLegalAdmin.selector);
        token.setKYC(USER2, type(uint256).max);
    }

    function test_Freeze_OnlyLegalOrOwner() public {
        vm.prank(USER);
        vm.expectRevert(PharosRWAToken.PharosRWAToken__NotLegalAdmin.selector);
        token.freeze(USER2);
    }

    function test_Unfreeze_Works() public {
        vm.prank(LEGAL_ADMIN);
        token.freeze(USER);

        vm.prank(LEGAL_ADMIN);
        token.unfreeze(USER);

        vm.prank(USER);
        token.transfer(USER2, 1000e18);  // Should work after unfreeze
    }

    // ──────────────────────────────────────────────
    // Pause
    // ──────────────────────────────────────────────
    function test_Pause_RevertsTransfers() public {
        vm.prank(LEGAL_ADMIN);
        token.pause();

        vm.prank(USER);
        vm.expectRevert(PharosRWAToken.PharosRWAToken__ContractPaused.selector);
        token.transfer(USER2, 1000e18);

        vm.prank(LEGAL_ADMIN);
        token.unpause();

        vm.prank(USER);
        token.transfer(USER2, 1000e18);  // Should work after unpause
    }

    // ──────────────────────────────────────────────
    // Supply Cap
    // ──────────────────────────────────────────────
    function test_SetSupplyCap_OnlyOwner() public {
        vm.prank(OWNER);
        token.setSupplyCap(200_000_000e18);
        assertEq(token.s_supplyCap(), 200_000_000e18);
    }

    function test_SetSupplyCap_RevertsBelowTotalSupply() public {
        vm.prank(OWNER);
        vm.expectRevert(PharosRWAToken.PharosRWAToken__SupplyCapExceeded.selector);
        token.setSupplyCap(10_000e18);
    }
}
