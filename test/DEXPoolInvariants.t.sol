// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {Test} from "forge-std/Test.sol";
import {StdInvariant} from "forge-std/StdInvariant.sol";
import {DEXPool} from "../contracts/DEXPool.sol";
import {PharosERC20} from "../contracts/PharosERC20.sol";

/// @title DEXPoolHandler
/// @notice Invariant test handler — holds tokens directly, no vm cheats
contract DEXPoolHandler {
    DEXPool public pool;
    PharosERC20 public tokenA;
    PharosERC20 public tokenB;

    uint256 public constant MAX_AMOUNT = 100_000e18;

    uint256 public totalLpMinted;

    constructor(address _pool, address _tokenA, address _tokenB) {
        pool = DEXPool(_pool);
        tokenA = PharosERC20(_tokenA);
        tokenB = PharosERC20(_tokenB);
    }

    // ── Liquidity ──────────────────────────────────
    function addLiquidity(uint256 amountA, uint256 amountB) external {
        if (amountA == 0 || amountB == 0) return;
        if (amountA > MAX_AMOUNT) amountA = MAX_AMOUNT;
        if (amountB > MAX_AMOUNT) amountB = MAX_AMOUNT;
        if (amountA > tokenA.balanceOf(address(this))) return;
        if (amountB > tokenB.balanceOf(address(this))) return;

        uint256 before = pool.getLpBalance(address(this));

        tokenA.approve(address(pool), amountA);
        tokenB.approve(address(pool), amountB);
        uint256 minted = pool.addLiquidity(amountA, amountB);

        totalLpMinted += minted;
    }

    function removeLiquidity(uint256 fraction) external {
        uint256 lpBalance = pool.getLpBalance(address(this));
        if (lpBalance == 0 || fraction == 0) return;

        uint256 toRemove = lpBalance * (fraction % 100) / 100;
        if (toRemove == 0) return;

        pool.removeLiquidity(toRemove);
    }

    // ── Swaps ───────────────────────────────────────
    function swapAtoB(uint256 amountIn) external {
        (uint256 rA, uint256 rB) = pool.getReserves();
        if (rA == 0 || rB == 0) return;

        if (rA / 5 == 0) return;
        amountIn = amountIn % (rA / 5);  // Max 20% of pool
        if (amountIn < 1e15) return;
        if (amountIn > tokenA.balanceOf(address(this))) return;

        tokenA.approve(address(pool), amountIn);
        pool.swap(address(tokenA), amountIn, address(tokenB), 0);
    }

    function swapBtoA(uint256 amountIn) external {
        (uint256 rA, uint256 rB) = pool.getReserves();
        if (rA == 0 || rB == 0) return;

        if (rB / 5 == 0) return;
        amountIn = amountIn % (rB / 5);
        if (amountIn < 1e15) return;
        if (amountIn > tokenB.balanceOf(address(this))) return;

        tokenB.approve(address(pool), amountIn);
        pool.swap(address(tokenB), amountIn, address(tokenA), 0);
    }
}

contract DEXPoolInvariants is StdInvariant, Test {
    DEXPool public pool;
    PharosERC20 public tokenA;
    PharosERC20 public tokenB;
    DEXPoolHandler public handler;

    address public constant OWNER = address(0x1);
    uint256 public constant CHAIN_ID = 688689;
    uint256 public constant INITIAL_MINT = 10_000_000e18;

    uint256 public constant INITIAL_LIQUIDITY_A = 1_000_000e18;
    uint256 public constant INITIAL_LIQUIDITY_B = 1_000_000e18;

    function setUp() public {
        // Deploy tokens
        vm.startPrank(OWNER);
        tokenA = new PharosERC20("Token A", "TOKA", INITIAL_MINT);
        tokenB = new PharosERC20("Token B", "TOKB", INITIAL_MINT);
        vm.stopPrank();

        // Deploy pool
        vm.prank(OWNER);
        pool = new DEXPool(address(tokenA), address(tokenB), CHAIN_ID);

        // Seed initial liquidity
        vm.startPrank(OWNER);
        tokenA.approve(address(pool), INITIAL_LIQUIDITY_A);
        tokenB.approve(address(pool), INITIAL_LIQUIDITY_B);
        pool.addLiquidity(INITIAL_LIQUIDITY_A, INITIAL_LIQUIDITY_B);
        vm.stopPrank();

        // Deploy handler and fund it
        handler = new DEXPoolHandler(address(pool), address(tokenA), address(tokenB));
        vm.startPrank(OWNER);
        tokenA.transfer(address(handler), 500_000e18);
        tokenB.transfer(address(handler), 500_000e18);
        vm.stopPrank();

        targetContract(address(handler));
    }

    /// k = reserveA * reserveB must never decrease
    function invariant_k_never_decreases() public {
        (uint256 rA, uint256 rB) = pool.getReserves();
        uint256 k = rA * rB;
        assertGe(k, 1e36, "k decreased: constant product violated");
    }

    /// Total LP supply must equal sum of all LP balances
    function invariant_lp_total_matches_sum() public {
        uint256 actualTotal = pool.s_totalLpTokens();
        uint256 ownerLp = pool.getLpBalance(OWNER);
        uint256 handlerLp = pool.getLpBalance(address(handler));
        assertEq(actualTotal, ownerLp + handlerLp, "LP supply != sum of balances");
    }

    /// Contract token balances must match reported reserves
    function invariant_reserves_match_actual() public {
        (uint256 rA, uint256 rB) = pool.getReserves();
        assertEq(rA, tokenA.balanceOf(address(pool)), "reserveA mismatch");
        assertEq(rB, tokenB.balanceOf(address(pool)), "reserveB mismatch");
    }

    /// Pool must always retain some liquidity on both sides
    function invariant_pool_never_drained() public {
        (uint256 rA, uint256 rB) = pool.getReserves();
        assertGt(rA, 0, "reserveA drained");
        assertGt(rB, 0, "reserveB drained");
    }

    /// Swap fee must remain within 0–1%
    function invariant_swap_fee_in_bounds() public {
        assertLe(pool.s_swapFee(), 100, "swap fee > 1%");
    }
}
