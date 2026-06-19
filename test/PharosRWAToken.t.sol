// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import "forge-std/Test.sol";
import "../contracts/PharosRWAToken.sol";

contract PharosRWATokenTest is Test {
    PharosRWAToken public token;
    address public OWNER = address(0x1234);
    address public USER = address(0x5678);
    address public USER2 = address(0x9ABC);

    function setUp() public {
        vm.prank(OWNER);
        token = new PharosRWAToken("Pharos RWA", "pRWA", 1000000e18, 100000000e18);

        // Give USER and USER2 KYC
        vm.prank(OWNER);
        token.setKYC(USER, type(uint256).max);
        vm.prank(OWNER);
        token.setKYC(USER2, type(uint256).max);

        // Transfer some tokens to USER
        vm.prank(OWNER);
        require(token.transfer(USER, 10000e18), "transfer failed");
    }

    function test_Constructor_SetsMetadata() public {
        assertEq(token.name(), "Pharos RWA");
        assertEq(token.symbol(), "pRWA");
        assertEq(token.decimals(), 18);
        assertEq(token.totalSupply(), 1000000e18);
        assertEq(token.s_supplyCap(), 100000000e18);
        assertEq(token.i_owner(), OWNER);
    }

    function test_Constructor_GivesOwnerBalance() public {
        assertEq(token.balanceOf(OWNER), 990000e18); // 1M - 10K sent to USER
    }

    function test_Transfer_WorksWithKYC() public {
        vm.prank(USER);
        require(token.transfer(USER2, 1000e18), "transfer failed");
        assertEq(token.balanceOf(USER), 9000e18);
        assertEq(token.balanceOf(USER2), 1000e18);
    }

    function test_Transfer_RevertsWithoutKYC() public {
        address noKYC = address(0xDEAD);
        vm.prank(USER);
        vm.expectRevert(abi.encodeWithSignature("PharosRWAToken__KYCMissing()"));
        token.transfer(noKYC, 100e18);
    }

    function test_Transfer_RevertsFrozenAccount() public {
        vm.prank(OWNER);
        token.freeze(USER, true);

        vm.prank(USER);
        vm.expectRevert(abi.encodeWithSignature("PharosRWAToken__FrozenAccount()"));
        token.transfer(USER2, 100e18);
    }

    function test_ApproveAndTransferFrom() public {
        vm.prank(USER);
        token.approve(USER2, 5000e18);

        vm.prank(USER2);
        token.transferFrom(USER, USER2, 3000e18);

        assertEq(token.balanceOf(USER), 7000e18);
        assertEq(token.balanceOf(USER2), 3000e18);
    }

    function test_Mint_OwnerOnly() public {
        vm.prank(OWNER);
        token.mint(USER, 5000e18);
        assertEq(token.balanceOf(USER), 15000e18);
        assertEq(token.totalSupply(), 1005000e18);
    }

    function test_Mint_RevertsNotOwner() public {
        vm.prank(USER);
        vm.expectRevert(abi.encodeWithSignature("PharosRWAToken__Unauthorized()"));
        token.mint(USER, 100e18);
    }

    function test_Mint_RevertsSupplyCap() public {
        vm.prank(OWNER);
        vm.expectRevert(abi.encodeWithSignature("PharosRWAToken__SupplyCapExceeded()"));
        token.mint(USER, 100000000e18); // Would exceed cap
    }

    function test_Burn() public {
        vm.prank(USER);
        token.burn(5000e18);
        assertEq(token.balanceOf(USER), 5000e18);
        assertEq(token.totalSupply(), 995000e18);
    }

    function test_KYC_Expiry() public {
        address user3 = address(0xCAFE);
        vm.prank(OWNER);
        token.setKYC(user3, block.timestamp + 100); // Expires in 100 sec

        vm.prank(OWNER);
        require(token.transfer(user3, 100e18), "transfer failed"); // Works before expiry

        vm.warp(block.timestamp + 200);

        vm.prank(user3);
        vm.expectRevert(abi.encodeWithSignature("PharosRWAToken__KYCExpired()"));
        token.transfer(USER, 50e18);
    }

    function test_SetLegalAdmin() public {
        vm.prank(OWNER);
        token.setLegalAdmin(USER);
        assertEq(token.i_legalAdmin(), USER);

        // USER can now manage KYC
        vm.prank(USER);
        token.setKYC(USER2, block.timestamp + 1000);
    }

    function test_SetSupplyCap() public {
        vm.prank(OWNER);
        token.setSupplyCap(2000000e18);
        assertEq(token.s_supplyCap(), 2000000e18);
    }
}
