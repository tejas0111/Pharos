// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

/// @title PharosLendingPool
/// @notice A collateralized lending protocol for Pharos (chain ID 688689/1672).
/// @dev Kinked interest rate model, pull-over-push for native transfers.
//      Interest accrual uses block.timestamp — standard DeFi pattern; validators have ~2s influence.
///      Pharos-specific: no 2300 gas stipend, EIP-1559 gas model.
contract PharosLendingPool {
    // ── Inline Reentrancy Guard ──
    uint256 private _status;
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    modifier nonReentrant() {
        if (_status == _ENTERED) revert PharosLendingPool__Reentrancy();
        _status = _ENTERED;
        _;
        _status = _NOT_ENTERED;
    }

    // ── Errors ──
    error PharosLendingPool__CapacityExceeded();
    error PharosLendingPool__InsufficientBalance();
    error PharosLendingPool__InsufficientCollateral();
    error PharosLendingPool__HealthyPosition();
    error PharosLendingPool__InsufficientLiquidity();
    error PharosLendingPool__InvalidAddress();
    error PharosLendingPool__ZeroAmount();
    error PharosLendingPool__Paused();
    error PharosLendingPool__NotOwner();
    error PharosLendingPool__Reentrancy();
    error PharosLendingPool__ExceedsMaxLTV();

    // ── Events ──
    event Supplied(address indexed user, uint256 amount, uint256 totalSupply);
    event Withdrawn(address indexed user, uint256 amount, uint256 totalSupply);
    event Borrowed(address indexed user, uint256 amount, uint256 totalBorrows);
    event Repaid(address indexed user, uint256 amount, uint256 totalBorrows);
    event Liquidated(address indexed user, address indexed liquidator, uint256 debtRepaid, uint256 collateralSeized);
    event InterestRateUpdated(uint256 br, uint256 s1, uint256 s2, uint256 opt);
    event Paused(bool indexed isPaused);
    event ReserveFactorUpdated(uint256 newFactor);

    // ── Types ──
    struct Position { uint256 supplied; uint256 borrowed; uint40 lastUpdated; }

    // ── State ──
    address public immutable i_owner;
    uint256 public s_maxCapacity;
    uint256 public s_reserveFactor;      // Basis points (10000 = 100%)
    uint256 public s_collateralRatio;    // Basis points (15000 = 150%)
    uint256 public s_maxLTV;             // Basis points (7500 = 75%)
    uint256 public s_liquidationBonus;   // Basis points (1000 = 10%)
    bool public s_paused;
    uint256 public s_baseRatePerSec;     // 1e18 = 100% per second
    uint256 public s_slope1PerSec;
    uint256 public s_slope2PerSec;
    uint256 public s_optimalUtilization; // 1e18 = 100%
    uint256 public s_totalSupplied;
    uint256 public s_totalBorrows;
    uint256 public s_reserves;
    uint256 public s_borrowIndex;        // Starts at 1e12
    uint40 public s_lastAccruedTime;
    mapping(address => Position) public s_positions;

    // ── Modifiers ──
    modifier onlyOwner() { if (msg.sender != i_owner) revert PharosLendingPool__NotOwner(); _; }
    modifier whenNotPaused() { if (s_paused) revert PharosLendingPool__Paused(); _; }
    modifier nonZero(uint256 amount) { if (amount == 0) revert PharosLendingPool__ZeroAmount(); _; }

    // ── Constructor ──
    constructor(
        uint256 _maxCapacity, uint256 _reserveFactor, uint256 _collateralRatio,
        uint256 _maxLTV, uint256 _liquidationBonus,
        uint256 _baseRatePerSec, uint256 _slope1PerSec, uint256 _slope2PerSec,
        uint256 _optimalUtilization
    ) {
        i_owner = msg.sender;
        s_maxCapacity = _maxCapacity; s_reserveFactor = _reserveFactor;
        s_collateralRatio = _collateralRatio; s_maxLTV = _maxLTV;
        s_liquidationBonus = _liquidationBonus;
        s_baseRatePerSec = _baseRatePerSec; s_slope1PerSec = _slope1PerSec;
        s_slope2PerSec = _slope2PerSec; s_optimalUtilization = _optimalUtilization;
        s_borrowIndex = 1e12; s_lastAccruedTime = uint40(block.timestamp); _status = _NOT_ENTERED;
    }

    // ── Internal ──
    function _calculateBorrowRate(uint256 utilization) private view returns (uint256) {
        if (utilization <= s_optimalUtilization) {
            return s_baseRatePerSec + (s_slope1PerSec * utilization) / s_optimalUtilization;
        }
        uint256 excess = utilization - s_optimalUtilization;
        uint256 remaining = 1e18 - s_optimalUtilization;
        return s_baseRatePerSec + s_slope1PerSec
            + (s_slope2PerSec * excess) / (remaining > 0 ? remaining : 1);
    }

    function _utilization() private view returns (uint256) {
        if (s_totalSupplied == 0) return 0;
        return (s_totalBorrows * 1e18) / s_totalSupplied;
    }

    // ── Interest Accrual ──
    function accrueInterest() public {
        uint40 now_ = uint40(block.timestamp);
        uint256 elapsed = uint256(now_ - s_lastAccruedTime);
        if (elapsed == 0 || s_totalBorrows == 0) {
            s_lastAccruedTime = now_;
            return;
        }
        uint256 ratePerSec = _calculateBorrowRate(_utilization());
        uint256 borrowIncrease = (s_totalBorrows * ratePerSec * elapsed) / 1e18;
        s_totalBorrows += borrowIncrease;
        s_reserves += (borrowIncrease * s_reserveFactor) / 10000;
        s_borrowIndex = (s_borrowIndex * (1e18 + ratePerSec * elapsed)) / 1e18;
        s_lastAccruedTime = now_;
    }

    // ── Supply ──
    function supply() external payable whenNotPaused nonReentrant {
        uint256 _amount = msg.value;
        if (_amount == 0) revert PharosLendingPool__ZeroAmount();
        accrueInterest();
        if (s_totalSupplied + _amount > s_maxCapacity) revert PharosLendingPool__CapacityExceeded();
        s_positions[msg.sender].supplied += _amount;
        if (s_positions[msg.sender].lastUpdated == 0) {
            s_positions[msg.sender].lastUpdated = uint40(block.timestamp);
        }
        s_totalSupplied += _amount;
        emit Supplied(msg.sender, _amount, s_totalSupplied);
    }

    // ── Withdraw ──
    function withdraw(uint256 _amount) external whenNotPaused nonZero(_amount) nonReentrant {
        accrueInterest();
        Position storage pos = s_positions[msg.sender];
        if (pos.supplied < _amount) revert PharosLendingPool__InsufficientBalance();
        if (pos.borrowed > 0) {
            uint256 remaining = pos.supplied - _amount;
            if (remaining < (pos.borrowed * s_collateralRatio) / 10000) {
                revert PharosLendingPool__InsufficientCollateral();
            }
        }
        pos.supplied -= _amount;
        s_totalSupplied -= _amount;
        (bool sent, ) = msg.sender.call{value: _amount}("");
        if (!sent) revert PharosLendingPool__InsufficientLiquidity();
        emit Withdrawn(msg.sender, _amount, s_totalSupplied);
    }

    // ── Borrow ──
    function borrow(uint256 _amount) external whenNotPaused nonZero(_amount) nonReentrant {
        accrueInterest();
        uint256 available = s_totalSupplied - s_totalBorrows - s_reserves;
        if (_amount > available) revert PharosLendingPool__InsufficientLiquidity();
        Position storage pos = s_positions[msg.sender];
        if (pos.supplied == 0) revert PharosLendingPool__InsufficientCollateral();
        uint256 maxBorrow = (pos.supplied * s_maxLTV) / 10000;
        if (pos.borrowed + _amount > maxBorrow) revert PharosLendingPool__ExceedsMaxLTV();
        pos.borrowed += _amount;
        s_totalBorrows += _amount;
        (bool sent, ) = msg.sender.call{value: _amount}("");
        if (!sent) revert PharosLendingPool__InsufficientLiquidity();
        emit Borrowed(msg.sender, _amount, s_totalBorrows);
    }

    // ── Repay ──
    function repay(uint256 _amount) external payable nonZero(_amount) nonReentrant {
        if (msg.value < _amount) revert PharosLendingPool__InsufficientBalance();
        accrueInterest();
        Position storage pos = s_positions[msg.sender];
        if (pos.borrowed == 0) revert PharosLendingPool__InsufficientBalance();
        uint256 ra = _amount > pos.borrowed ? pos.borrowed : _amount;
        pos.borrowed -= ra;
        s_totalBorrows -= ra;
        emit Repaid(msg.sender, ra, s_totalBorrows);
    }

    // ── Liquidate ──
    function liquidate(address _user, uint256 _debtToCover) external whenNotPaused nonZero(_debtToCover) nonReentrant {
        if (_user == address(0)) revert PharosLendingPool__InvalidAddress();
        Position storage pos = s_positions[_user];
        if (pos.borrowed == 0) revert PharosLendingPool__HealthyPosition();
        accrueInterest();
        if (pos.supplied >= (pos.borrowed * s_collateralRatio) / 10000) {
            revert PharosLendingPool__HealthyPosition();
        }
        uint256 dc = _debtToCover > pos.borrowed ? pos.borrowed : _debtToCover;
        uint256 seize = (dc * (10000 + s_liquidationBonus)) / 10000;
        if (seize > pos.supplied) seize = pos.supplied;
        pos.borrowed -= dc;
        pos.supplied -= seize;
        s_totalBorrows -= dc;
        emit Liquidated(_user, msg.sender, dc, seize);
    }

    // ── Admin ──
    function setPaused(bool _paused) external onlyOwner {
        s_paused = _paused; emit Paused(_paused);
    }

    function updateInterestRate(uint256 _br, uint256 _s1, uint256 _s2, uint256 _opt) external onlyOwner {
        accrueInterest();
        s_baseRatePerSec = _br; s_slope1PerSec = _s1;
        s_slope2PerSec = _s2; s_optimalUtilization = _opt;
        emit InterestRateUpdated(_br, _s1, _s2, _opt);
    }

    function updateReserveFactor(uint256 _nf) external onlyOwner {
        if (_nf > 2500) revert PharosLendingPool__ExceedsMaxLTV();
        s_reserveFactor = _nf; emit ReserveFactorUpdated(_nf);
    }

    // ── View ──
    function getUtilization() external view returns (uint256) { return _utilization(); }

    function getBorrowRatePerSec() external view returns (uint256) {
        return _calculateBorrowRate(_utilization());
    }

    function getSupplyRatePerSec() external view returns (uint256) {
        uint256 br = _calculateBorrowRate(_utilization());
        uint256 u = _utilization();
        return (br * u * (10000 - s_reserveFactor)) / 1e18 / 10000;
    }

    function getHealthFactor(address _user) external view returns (uint256) {
        Position storage pos = s_positions[_user];
        if (pos.borrowed == 0) return type(uint256).max;
        uint256 rc = (pos.borrowed * s_collateralRatio) / 10000;
        if (rc == 0) return type(uint256).max;
        return (pos.supplied * 1e18) / rc;
    }

    function getMaxBorrow(address _user) external view returns (uint256) {
        return (s_positions[_user].supplied * s_maxLTV) / 10000;
    }
}
