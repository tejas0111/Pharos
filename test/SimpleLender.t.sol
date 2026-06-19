// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {Test} from "forge-std/Test.sol";
import {SimpleLender} from "../contracts/SimpleLender.sol";
import {MockERC20} from "./StakingPool.t.sol";

contract SimpleLenderTest is Test {
    SimpleLender public lender;
    MockERC20 public collateralToken;
    MockERC20 public borrowToken;

    address public OWNER = address(0x1234);
    address public BORROWER = address(0x5678);
    address public LIQUIDATOR = address(0x9ABC);

    uint256 public constant INTEREST_RATE = 317_097_920; // ~1% APR (per second)
    uint256 public constant CHAIN_ID = 688689;

    function setUp() public {
        // Deploy mock tokens
        collateralToken = new MockERC20("Collateral", "COL", 18);
        borrowToken = new MockERC20("Borrow", "BRW", 18);

        // Deploy lender
        vm.prank(OWNER);
        lender = new SimpleLender(
            address(collateralToken),
            address(borrowToken),
            INTEREST_RATE,
            CHAIN_ID
        );

        // Fund positions
        collateralToken.mint(OWNER, 1_000_000 ether);
        collateralToken.mint(BORROWER, 1_000_000 ether);
        collateralToken.mint(LIQUIDATOR, 1_000_000 ether);

        borrowToken.mint(OWNER, 1_000_000 ether);
        borrowToken.mint(LIQUIDATOR, 1_000_000 ether);

        // Owner adds borrow liquidity
        vm.prank(OWNER);
        borrowToken.approve(address(lender), type(uint256).max);
        vm.prank(OWNER);
        lender.addLiquidity(500_000 ether);

        // Approvals
        vm.prank(BORROWER);
        collateralToken.approve(address(lender), type(uint256).max);
        vm.prank(LIQUIDATOR);
        collateralToken.approve(address(lender), type(uint256).max);
        vm.prank(LIQUIDATOR);
        borrowToken.approve(address(lender), type(uint256).max);
    }

    // ── Constructor ────────────────────────────────

    function test_Constructor_SetsOwner() public {
        assertEq(lender.i_owner(), OWNER);
    }

    function test_Constructor_SetsChainId() public {
        assertEq(lender.i_chainId(), CHAIN_ID);
    }

    // ── Deposit ────────────────────────────────────

    function test_DepositCollateral() public {
        vm.prank(BORROWER);
        lender.depositCollateral(1000 ether);
        assertEq(collateralToken.balanceOf(address(lender)), 1000 ether);
    }

    // ── Borrow ─────────────────────────────────────

    function test_Borrow_CreatesLoan() public {
        uint256 collateral = 1500 ether;
        uint256 borrowAmt = 1000 ether;

        vm.prank(BORROWER);
        lender.borrow(collateral, borrowAmt);

        SimpleLender.Loan memory loan = lender.getLoanInfo(BORROWER);
        assertEq(loan.collateralAmount, collateral);
        assertEq(loan.borrowAmount, borrowAmt);
        assertTrue(loan.active);
    }

    function test_Borrow_RevertsOnInsufficientLiquidity() public {
        vm.prank(BORROWER);
        vm.expectRevert(SimpleLender.SimpleLender__InsufficientLiquidity.selector);
        lender.borrow(1500 ether, 600_000 ether); // exceeds available liquidity
    }

    function test_Borrow_RevertsOnLowCollateral() public {
        vm.prank(BORROWER);
        vm.expectRevert(SimpleLender.SimpleLender__InsufficientCollateral.selector);
        lender.borrow(100 ether, 100 ether); // 100% ratio, needs 150%+
    }

    // ── Repay ──────────────────────────────────────

    function test_Repay_Partially() public {
        vm.prank(BORROWER);
        lender.borrow(1500 ether, 1000 ether);

        borrowToken.mint(BORROWER, 500 ether);
        vm.prank(BORROWER);
        borrowToken.approve(address(lender), 500 ether);

        vm.prank(BORROWER);
        lender.repay(500 ether);

        SimpleLender.Loan memory loanInfo = lender.getLoanInfo(BORROWER); uint256 remaining = loanInfo.borrowAmount;
        assertTrue(loanInfo.active, "Loan should still be loan.active");
        assertTrue(remaining < 1000 ether, "Remaining should be less");
    }

    function test_Repay_Fully() public {
        vm.prank(BORROWER);
        lender.borrow(1500 ether, 1000 ether);

        borrowToken.mint(BORROWER, 2000 ether);
        vm.prank(BORROWER);
        borrowToken.approve(address(lender), 2000 ether);

        vm.prank(BORROWER);
        lender.repay(1000 ether);

        SimpleLender.Loan memory loanInfo = lender.getLoanInfo(BORROWER); bool active = loanInfo.active;
        assertFalse(active, "Loan should be closed");
    }

    // ── Liquidation ────────────────────────────────

    function test_Liquidation() public {
        // Setup loan
        vm.prank(BORROWER);
        lender.borrow(1500 ether, 1000 ether);
        // Set high interest rate to quickly make position liquidatable
        vm.prank(OWNER);
        lender.setInterestRate(5000000000000000);
        vm.warp(block.timestamp + 1000);

        // verify liquidatable
        assertTrue(lender.isLiquidatable(BORROWER), "Should be liquidatable");

        // Liquidate
        vm.prank(LIQUIDATOR);
        lender.liquidate(BORROWER);

        SimpleLender.Loan memory loanInfo = lender.getLoanInfo(BORROWER); bool active = loanInfo.active;
        assertFalse(active, "Loan should be closed after liquidation");
    }

    // ── Owner ──────────────────────────────────────

    function test_OwnerCanSetInterestRate() public {
        vm.prank(OWNER);
        lender.setInterestRate(1000000000000000);
        assertEq(lender.s_interestRatePerSecond(), 1000000000000000);
    }

    function test_OwnerRevertsOnNonOwner() public {
        vm.prank(BORROWER);
        vm.expectRevert(SimpleLender.SimpleLender__NotOwner.selector);
        lender.setInterestRate(1000000000000000);
    }
}
