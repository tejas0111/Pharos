// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {IERC20} from "./interfaces/IERC20.sol";
import {SafeERC20} from "./interfaces/SafeERC20.sol";
import {ReentrancyGuard} from "./interfaces/ReentrancyGuard.sol";

/// @title Pharos DEXPool
/// @notice Constant Product AMM (Uniswap V2 style) for Pharos
/// @dev Demonstrates: AMM math, LP tokens, swap, add/remove liquidity
contract DEXPool is ReentrancyGuard {
    using SafeERC20 for IERC20;

    // ── Errors ──────────────────────────────────────
    error DEXPool__NotOwner();
    error DEXPool__ZeroAmount();
    error DEXPool__InsufficientOutput();
    error DEXPool__InvalidK();
    error DEXPool__InvalidAddress();
    error DEXPool__InsufficientLiquidity();

    // ── Events ──────────────────────────────────────
    event Swap(address indexed user, address indexed tokenIn, uint256 amountIn, address indexed tokenOut, uint256 amountOut);
    event LiquidityAdded(address indexed user, uint256 amountA, uint256 amountB, uint256 lpTokens);
    event LiquidityRemoved(address indexed user, uint256 amountA, uint256 amountB, uint256 lpTokens);

    // ── Immutable ───────────────────────────────────
    address public immutable i_owner;
    uint256 public immutable i_chainId;
    IERC20 public immutable i_tokenA;
    IERC20 public immutable i_tokenB;

    // ── State ───────────────────────────────────────
    uint256 public s_reserveA;
    uint256 public s_reserveB;
    uint256 public s_totalLpTokens;
    mapping(address => uint256) public s_lpBalances;

    uint256 public s_swapFee = 30; // 0.3% (in basis points)

    // ── Modifiers ───────────────────────────────────
    modifier onlyOwner() {
        if (msg.sender != i_owner) revert DEXPool__NotOwner();
        _;
    }

    constructor(address _tokenA, address _tokenB, uint256 _chainId) {
        if (_tokenA == address(0) || _tokenB == address(0)) revert DEXPool__InvalidAddress();
        if (_tokenA == _tokenB) revert DEXPool__InvalidAddress();
        i_owner = msg.sender;
        i_tokenA = IERC20(_tokenA);
        i_tokenB = IERC20(_tokenB);
        i_chainId = _chainId;
    }

    // ── View ────────────────────────────────────────

    function getReserves() external view returns (uint256, uint256) {
        return (s_reserveA, s_reserveB);
    }

    function getLpBalance(address _user) external view returns (uint256) {
        return s_lpBalances[_user];
    }

    /// @notice Calculate output amount for a given input (constant product)
    function getAmountOut(uint256 _amountIn, uint256 _reserveIn, uint256 _reserveOut) public pure returns (uint256) {
        if (_amountIn == 0) return 0;
        uint256 amountInWithFee = _amountIn * 997;  // 0.3% fee
        uint256 numerator = amountInWithFee * _reserveOut;
        uint256 denominator = (_reserveIn * 1000) + amountInWithFee;
        return numerator / denominator;
    }

    // ── Add Liquidity ───────────────────────────────

    function addLiquidity(uint256 _amountA, uint256 _amountB) external nonReentrant returns (uint256 lpTokens) {
        if (_amountA == 0 || _amountB == 0) revert DEXPool__ZeroAmount();

        i_tokenA.safeTransferFrom(msg.sender, address(this), _amountA);
        i_tokenB.safeTransferFrom(msg.sender, address(this), _amountB);

        if (s_totalLpTokens == 0) {
            // First deposit: LP = geometric mean
            lpTokens = _sqrt(_amountA * _amountB);
        } else {
            // Subsequent deposits: LP proportional to share
            uint256 shareA = (_amountA * s_totalLpTokens) / s_reserveA;
            uint256 shareB = (_amountB * s_totalLpTokens) / s_reserveB;
            lpTokens = shareA < shareB ? shareA : shareB;
            if (lpTokens == 0) revert DEXPool__InsufficientLiquidity();
        }

        s_reserveA += _amountA;
        s_reserveB += _amountB;
        s_lpBalances[msg.sender] += lpTokens;
        s_totalLpTokens += lpTokens;

        emit LiquidityAdded(msg.sender, _amountA, _amountB, lpTokens);
        return lpTokens;
    }

    // ── Remove Liquidity ────────────────────────────

    function removeLiquidity(uint256 _lpTokens) external nonReentrant returns (uint256 amountA, uint256 amountB) {
        if (_lpTokens == 0) revert DEXPool__ZeroAmount();
        if (s_lpBalances[msg.sender] < _lpTokens) revert DEXPool__InsufficientLiquidity();

        amountA = (_lpTokens * s_reserveA) / s_totalLpTokens;
        amountB = (_lpTokens * s_reserveB) / s_totalLpTokens;

        s_lpBalances[msg.sender] -= _lpTokens;
        s_totalLpTokens -= _lpTokens;
        s_reserveA -= amountA;
        s_reserveB -= amountB;

        i_tokenA.safeTransfer(msg.sender, amountA);
        i_tokenB.safeTransfer(msg.sender, amountB);

        emit LiquidityRemoved(msg.sender, amountA, amountB, _lpTokens);
        return (amountA, amountB);
    }

    // ── Swap ────────────────────────────────────────

    function swap(address _tokenIn, uint256 _amountIn, address _tokenOut, uint256 _minAmountOut) external nonReentrant returns (uint256) {
        if (_amountIn == 0) revert DEXPool__ZeroAmount();

        bool isAtoB = _tokenIn == address(i_tokenA) && _tokenOut == address(i_tokenB);
        bool isBtoA = _tokenIn == address(i_tokenB) && _tokenOut == address(i_tokenA);
        if (!isAtoB && !isBtoA) revert DEXPool__InvalidAddress();

        uint256 reserveIn;
        uint256 reserveOut;
        IERC20 tokenOut;

        if (isAtoB) {
            reserveIn = s_reserveA;
            reserveOut = s_reserveB;
            tokenOut = i_tokenB;
        } else {
            reserveIn = s_reserveB;
            reserveOut = s_reserveA;
            tokenOut = i_tokenA;
        }

        uint256 amountOut = getAmountOut(_amountIn, reserveIn, reserveOut);
        if (amountOut < _minAmountOut) revert DEXPool__InsufficientOutput();
        if (amountOut >= reserveOut) revert DEXPool__InsufficientLiquidity();

        IERC20(_tokenIn).safeTransferFrom(msg.sender, address(this), _amountIn);
        tokenOut.safeTransfer(msg.sender, amountOut);

        // Update reserves (after transfer, reflect actual balances)
        s_reserveA = i_tokenA.balanceOf(address(this));
        s_reserveB = i_tokenB.balanceOf(address(this));

        emit Swap(msg.sender, _tokenIn, _amountIn, _tokenOut, amountOut);
        return amountOut;
    }

    // ── Owner ───────────────────────────────────────

    function setSwapFee(uint256 _feeBps) external onlyOwner {
        if (_feeBps > 100) revert DEXPool__InvalidK(); // max 1%
        s_swapFee = _feeBps;
    }

    // ── Utility ─────────────────────────────────────

    function _sqrt(uint256 y) private pure returns (uint256 z) {
        if (y > 3) {
            z = y;
            uint256 x = y / 2 + 1;
            while (x < z) {
                z = x;
                x = (y / x + x) / 2;
            }
        } else if (y != 0) {
            z = 1;
        }
    }
}
