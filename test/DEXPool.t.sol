// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {Test} from "forge-std/Test.sol";
import {DEXPool} from "../contracts/DEXPool.sol";
import {MockERC20} from "./StakingPool.t.sol";

contract DEXPoolTest is Test {
    DEXPool public pool;
    MockERC20 public tokenA;
    MockERC20 public tokenB;

    address public OWNER = address(0x1234);
    address public LP = address(0x5678);
    address public SWAPPER = address(0x9ABC);

    uint256 public constant PHAROS_CHAIN_ID = 688689;

    function setUp() public {
        tokenA = new MockERC20("Token A", "TOKA", 18);
        tokenB = new MockERC20("Token B", "TOKB", 18);

        tokenA.mint(OWNER, 1_000_000 ether);
        tokenA.mint(LP, 1_000_000 ether);
        tokenA.mint(SWAPPER, 1_000_000 ether);
        tokenB.mint(OWNER, 1_000_000 ether);
        tokenB.mint(LP, 1_000_000 ether);
        tokenB.mint(SWAPPER, 1_000_000 ether);

        vm.prank(OWNER);
        pool = new DEXPool(address(tokenA), address(tokenB), PHAROS_CHAIN_ID);

        // Approvals
        vm.prank(LP);
        tokenA.approve(address(pool), type(uint256).max);
        vm.prank(LP);
        tokenB.approve(address(pool), type(uint256).max);
        vm.prank(SWAPPER);
        tokenA.approve(address(pool), type(uint256).max);
        vm.prank(SWAPPER);
        tokenB.approve(address(pool), type(uint256).max);
    }

    // ── Constructor ────────────────────────────────

    function test_Constructor_SetsTokens() public {
        assertEq(address(pool.i_tokenA()), address(tokenA));
        assertEq(address(pool.i_tokenB()), address(tokenB));
    }

    function test_Constructor_SetsChainId() public {
        assertEq(pool.i_chainId(), PHAROS_CHAIN_ID);
    }

    function test_Constructor_RevertsOnSameToken() public {
        vm.prank(OWNER);
        vm.expectRevert(DEXPool.DEXPool__InvalidAddress.selector);
        new DEXPool(address(tokenA), address(tokenA), PHAROS_CHAIN_ID);
    }

    // ── Add Liquidity ──────────────────────────────

    function test_AddLiquidity_Initial() public {
        vm.prank(LP);
        uint256 lpTokens = pool.addLiquidity(1000 ether, 2000 ether);

        assertTrue(lpTokens > 0, "Should mint LP tokens");
        assertEq(pool.getLpBalance(LP), lpTokens);

        (uint256 rA, uint256 rB) = pool.getReserves();
        assertEq(rA, 1000 ether);
        assertEq(rB, 2000 ether);
    }

    function test_AddLiquidity_Subsequent() public {
        vm.prank(LP);
        pool.addLiquidity(1000 ether, 2000 ether);

        uint256 lpBefore = pool.getLpBalance(LP);
        vm.prank(LP);
        uint256 lpTokens = pool.addLiquidity(500 ether, 1000 ether);
        uint256 lpAfter = pool.getLpBalance(LP);

        assertEq(lpAfter, lpBefore + lpTokens, "LP tokens should accumulate");
    }

    // ── Remove Liquidity ───────────────────────────

    function test_RemoveLiquidity() public {
        vm.prank(LP);
        uint256 lpTokens = pool.addLiquidity(1000 ether, 2000 ether);

        uint256 balA_before = tokenA.balanceOf(LP);
        uint256 balB_before = tokenB.balanceOf(LP);

        vm.prank(LP);
        (uint256 amountA, uint256 amountB) = pool.removeLiquidity(lpTokens);

        assertTrue(amountA > 0, "Should receive token A");
        assertTrue(amountB > 0, "Should receive token B");
        assertEq(tokenA.balanceOf(LP), balA_before + amountA);
        assertEq(tokenB.balanceOf(LP), balB_before + amountB);
        assertEq(pool.getLpBalance(LP), 0);
    }

    // ── Swap ───────────────────────────────────────

    function test_Swap_AtoB() public {
        // Add initial liquidity
        vm.prank(LP);
        pool.addLiquidity(1000 ether, 2000 ether);

        uint256 balB_before = tokenB.balanceOf(SWAPPER);

        vm.prank(SWAPPER);
        uint256 amountOut = pool.swap(address(tokenA), 100 ether, address(tokenB), 0);

        assertTrue(amountOut > 0, "Should receive token B");
        assertEq(tokenB.balanceOf(SWAPPER), balB_before + amountOut);
    }

    function test_Swap_BtoA() public {
        vm.prank(LP);
        pool.addLiquidity(1000 ether, 2000 ether);

        uint256 balA_before = tokenA.balanceOf(SWAPPER);

        vm.prank(SWAPPER);
        uint256 amountOut = pool.swap(address(tokenB), 100 ether, address(tokenA), 0);

        assertTrue(amountOut > 0, "Should receive token A");
        assertEq(tokenA.balanceOf(SWAPPER), balA_before + amountOut);
    }

    function test_Swap_RevertsOnInsufficientOutput() public {
        vm.prank(LP);
        pool.addLiquidity(1000 ether, 2000 ether);

        vm.prank(SWAPPER);
        vm.expectRevert(DEXPool.DEXPool__InsufficientOutput.selector);
        pool.swap(address(tokenA), 100 ether, address(tokenB), 1000 ether);
    }

    function test_Swap_RespectsFee() public {
        vm.prank(LP);
        pool.addLiquidity(1000 ether, 2000 ether);

        // Without fee: out = (in * outReserve) / (inReserve + in) = (100 * 2000) / (1000 + 100) = 181.8
        // With 0.3% fee: out = (in * 997 * outReserve) / (inReserve * 1000 + in * 997)
        vm.prank(SWAPPER);
        uint256 amountOut = pool.swap(address(tokenA), 100 ether, address(tokenB), 0);

        // Expected: (100 * 997 * 2000) / (1000 * 1000 + 100 * 997) = 199400000 / 1099700 = ~181.31
        // Without fee would be ~181.82
        assertApproxEqRel(amountOut, 181 ether, 0.01e18); // within 1%
    }

    // ── GetAmountOut ───────────────────────────────

    function test_GetAmountOut_ReturnsZeroForZeroInput() public {
        assertEq(pool.getAmountOut(0, 1000 ether, 2000 ether), 0);
    }

    // ── Owner ───────────────────────────────────────

    function test_OwnerCanSetFee() public {
        vm.prank(OWNER);
        pool.setSwapFee(50); // 0.5%
        assertEq(pool.s_swapFee(), 50);
    }

    function test_OwnerRevertsOnNonOwner() public {
        vm.prank(LP);
        vm.expectRevert(DEXPool.DEXPool__NotOwner.selector);
        pool.setSwapFee(50);
    }
}
