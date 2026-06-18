// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import "forge-std/Test.sol";
import {PharosERC20} from "../contracts/PharosERC20.sol";

contract PharosERC20Test is Test {
    PharosERC20 private s_token;
    address private constant OWNER = address(0x1234);
    address private constant USER = address(0x5678);
    address private constant SPENDER = address(0x9ABC);
    uint256 private constant INITIAL_SUPPLY = 1_000_000 ether;

    function setUp() public {
        vm.prank(OWNER);
        s_token = new PharosERC20("PharosToken", "PHT", INITIAL_SUPPLY);
    }

    // --- Constructor ---
    function test_Constructor_SetsName() public view {
        assertEq(s_token.name(), "PharosToken");
    }

    function test_Constructor_SetsSymbol() public view {
        assertEq(s_token.symbol(), "PHT");
    }

    function test_Constructor_SetsTotalSupply() public view {
        assertEq(s_token.totalSupply(), INITIAL_SUPPLY);
    }

    function test_Constructor_SetsOwner() public view {
        assertEq(s_token.owner(), OWNER);
    }

    function test_Constructor_MintsToOwner() public view {
        assertEq(s_token.balanceOf(OWNER), INITIAL_SUPPLY);
    }

    // --- Transfer ---
    function test_Transfer_MovesTokens() public {
        uint256 amount = 100 ether;
        vm.prank(OWNER);
        assertTrue(s_token.transfer(USER, amount));
        assertEq(s_token.balanceOf(OWNER), INITIAL_SUPPLY - amount);
        assertEq(s_token.balanceOf(USER), amount);
    }

    function test_Transfer_EmitsEvent() public {
        uint256 amount = 100 ether;
        vm.prank(OWNER);
        vm.expectEmit(true, true, true, true, address(s_token));
        emit PharosERC20.Transfer(OWNER, USER, amount);
        assertTrue(s_token.transfer(USER, amount));
    }

    function test_Transfer_RevertsWhenInsufficientBalance() public {
        vm.prank(USER);
        vm.expectRevert(PharosERC20.PharosERC20__InsufficientBalance.selector);
        s_token.transfer(OWNER, 1 ether); // intentionally unchecked — reverts under expectRevert
    }

    function test_Transfer_RevertsWhenZeroAddress() public {
        vm.prank(OWNER);
        vm.expectRevert(PharosERC20.PharosERC20__ZeroAddress.selector);
        s_token.transfer(address(0), 100 ether); // intentionally unchecked — reverts under expectRevert
    }

    // --- Mint ---
    function test_Mint_OwnerCanMint() public {
        uint256 amount = 500 ether;
        vm.prank(OWNER);
        s_token.mint(USER, amount);
        assertEq(s_token.balanceOf(USER), amount);
        assertEq(s_token.totalSupply(), INITIAL_SUPPLY + amount);
    }

    function test_Mint_EmitsEvent() public {
        uint256 amount = 500 ether;
        vm.prank(OWNER);
        vm.expectEmit(true, true, true, true, address(s_token));
        emit PharosERC20.Transfer(address(0), USER, amount);
        s_token.mint(USER, amount);
    }

    function test_Mint_NonOwnerReverts() public {
        vm.prank(USER);
        vm.expectRevert(PharosERC20.PharosERC20__NotOwner.selector);
        s_token.mint(OWNER, 100 ether);
    }

    function test_Mint_RevertsWhenZeroAddress() public {
        vm.prank(OWNER);
        vm.expectRevert(PharosERC20.PharosERC20__ZeroAddress.selector);
        s_token.mint(address(0), 100 ether);
    }

    function test_Mint_RevertsWhenExceedsMaxSupply() public {
        uint256 maxSupply = s_token.MAX_SUPPLY();
        uint256 remaining = maxSupply - s_token.totalSupply() + 1;
        vm.prank(OWNER);
        vm.expectRevert(PharosERC20.PharosERC20__InvalidTransfer.selector);
        s_token.mint(USER, remaining);
    }

    // --- Approve + TransferFrom ---
    function test_Approve_SetsAllowance() public {
        uint256 amount = 200 ether;
        vm.prank(OWNER);
        s_token.approve(SPENDER, amount);
        assertEq(s_token.allowance(OWNER, SPENDER), amount);
    }

    function test_Approve_EmitsEvent() public {
        uint256 amount = 200 ether;
        vm.prank(OWNER);
        vm.expectEmit(true, true, true, true, address(s_token));
        emit PharosERC20.Approval(OWNER, SPENDER, amount);
        s_token.approve(SPENDER, amount);
    }

    function test_Approve_RevertsWhenZeroAddress() public {
        vm.prank(OWNER);
        vm.expectRevert(PharosERC20.PharosERC20__ZeroAddress.selector);
        s_token.approve(address(0), 100 ether);
    }

    function test_TransferFrom_UsesAllowance() public {
        uint256 approveAmount = 200 ether;
        uint256 transferAmount = 150 ether;

        vm.prank(OWNER);
        s_token.approve(SPENDER, approveAmount);

        vm.prank(SPENDER);
        assertTrue(s_token.transferFrom(OWNER, USER, transferAmount));

        assertEq(s_token.balanceOf(USER), transferAmount);
        assertEq(s_token.balanceOf(OWNER), INITIAL_SUPPLY - transferAmount);
        assertEq(s_token.allowance(OWNER, SPENDER), approveAmount - transferAmount);
    }

    function test_TransferFrom_EmitsEvent() public {
        uint256 amount = 100 ether;
        vm.prank(OWNER);
        s_token.approve(SPENDER, amount);

        vm.prank(SPENDER);
        vm.expectEmit(true, true, true, true, address(s_token));
        emit PharosERC20.Transfer(OWNER, USER, amount);
        assertTrue(s_token.transferFrom(OWNER, USER, amount));
    }

    function test_TransferFrom_RevertsWhenInsufficientAllowance() public {
        vm.prank(OWNER);
        s_token.approve(SPENDER, 50 ether);

        vm.prank(SPENDER);
        vm.expectRevert(PharosERC20.PharosERC20__InsufficientAllowance.selector);
        s_token.transferFrom(OWNER, USER, 100 ether); // intentionally unchecked — reverts under expectRevert
    }

    function test_TransferFrom_RevertsWhenInsufficientBalance() public {
        vm.prank(OWNER);
        s_token.approve(SPENDER, INITIAL_SUPPLY + 1 ether);

        vm.prank(SPENDER);
        vm.expectRevert(PharosERC20.PharosERC20__InsufficientBalance.selector);
        s_token.transferFrom(OWNER, USER, INITIAL_SUPPLY + 1 ether); // intentionally unchecked — reverts under expectRevert
    }

    // --- Owner view ---
    function test_Owner_ReturnsDeployer() public view {
        assertEq(s_token.owner(), OWNER);
    }
}
