// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {IERC20} from "./interfaces/IERC20.sol";
import {SafeERC20} from "./interfaces/SafeERC20.sol";
import {ReentrancyGuard} from "./interfaces/ReentrancyGuard.sol";

/// @title Pharos SimpleLender
/// @notice Minimal lending/borrowing pool demonstrating DeFi patterns on Pharos
/// @dev Demonstrates: pull-over-push, interest accrual, collateralization, liquidation
contract SimpleLender is ReentrancyGuard {
    using SafeERC20 for IERC20;

    struct Loan {
        uint256 collateralAmount;
        uint256 borrowAmount;
        uint256 lastUpdate;
        bool active;
    }

    error SimpleLender__NotOwner();
    error SimpleLender__ZeroAmount();
    error SimpleLender__InsufficientLiquidity();
    error SimpleLender__InsufficientCollateral();
    error SimpleLender__LoanNotExists();
    error SimpleLender__LoanActive();
    error SimpleLender__PositionHealthy();
    error SimpleLender__InvalidAddress();
    error SimpleLender__RepayExceeds(uint256 owed);

    event Deposited(address indexed user, uint256 amount);
    event Withdrawn(address indexed user, uint256 amount);
    event LoanOpened(address indexed user, uint256 collateral, uint256 borrow);
    event LoanRepaid(address indexed user, uint256 amount);
    event Liquidated(address indexed user, address indexed liquidator, uint256 collateralSeized);

    address public immutable i_owner;
    uint256 public immutable i_chainId;
    IERC20 public immutable i_collateralToken;
    IERC20 public immutable i_borrowToken;

    uint256 public s_totalDeposits;
    uint256 public s_totalBorrows;
    uint256 public s_interestRatePerSecond;
    uint256 public s_liqThreshold = 80;
    uint256 public s_liqPenalty = 10;

    mapping(address => Loan) public s_loans;

    constructor(
        address _collateralToken,
        address _borrowToken,
        uint256 _interestRatePerSecond,
        uint256 _chainId
    ) {
        if (_collateralToken == address(0) || _borrowToken == address(0)) revert SimpleLender__InvalidAddress();
        i_owner = msg.sender;
        i_collateralToken = IERC20(_collateralToken);
        i_borrowToken = IERC20(_borrowToken);
        s_interestRatePerSecond = _interestRatePerSecond;
        i_chainId = _chainId;
    }

    modifier onlyOwner() {
        if (msg.sender != i_owner) revert SimpleLender__NotOwner();
        _;
    }

    function getLoanInfo(address _user) external view returns (Loan memory) {
        return s_loans[_user];
    }

    function getCurrentDebt(address _user) public view returns (uint256) {
        Loan storage loan = s_loans[_user];
        if (!loan.active) return 0;
        uint256 timeElapsed = block.timestamp - loan.lastUpdate;
        uint256 interest = (loan.borrowAmount * s_interestRatePerSecond * timeElapsed) / 1e18;
        return loan.borrowAmount + interest;
    }

    function getCollateralRatio(address _user) public view returns (uint256) {
        Loan storage loan = s_loans[_user];
        if (!loan.active || loan.borrowAmount == 0) return 0;
        uint256 debt = getCurrentDebt(_user);
        if (debt == 0) return type(uint256).max;
        return (loan.collateralAmount * 100) / debt;
    }

    function isLiquidatable(address _user) external view returns (bool) {
        if (!s_loans[_user].active) return false;
        return getCollateralRatio(_user) < s_liqThreshold;
    }

    function depositCollateral(uint256 _amount) external nonReentrant {
        if (_amount == 0) revert SimpleLender__ZeroAmount();
        i_collateralToken.safeTransferFrom(msg.sender, address(this), _amount);

        if (s_loans[msg.sender].active) {
            s_loans[msg.sender].collateralAmount += _amount;
            s_loans[msg.sender].lastUpdate = block.timestamp;
        }

        s_totalDeposits += _amount;
        emit Deposited(msg.sender, _amount);
    }

    function borrow(uint256 _collateralAmount, uint256 _borrowAmount) external nonReentrant {
        if (_collateralAmount == 0 || _borrowAmount == 0) revert SimpleLender__ZeroAmount();
        if (s_loans[msg.sender].active) revert SimpleLender__LoanActive();
        if (i_borrowToken.balanceOf(address(this)) < _borrowAmount) revert SimpleLender__InsufficientLiquidity();

        if ((_collateralAmount * 100) / _borrowAmount < 150) revert SimpleLender__InsufficientCollateral();

        i_collateralToken.safeTransferFrom(msg.sender, address(this), _collateralAmount);

        s_loans[msg.sender] = Loan({
            collateralAmount: _collateralAmount,
            borrowAmount: _borrowAmount,
            lastUpdate: block.timestamp,
            active: true
        });

        s_totalDeposits += _collateralAmount;
        s_totalBorrows += _borrowAmount;

        i_borrowToken.safeTransfer(msg.sender, _borrowAmount);
        emit LoanOpened(msg.sender, _collateralAmount, _borrowAmount);
    }

    /*
     * @dev Repay function with proper principal-vs-interest accounting.
     * s_totalBorrows tracks only principal to avoid underflow when interest
     * exceeds principal (e.g., during stress/high-rate scenarios).
     */
    function repay(uint256 _amount) external nonReentrant {
        if (!s_loans[msg.sender].active) revert SimpleLender__LoanNotExists();
        if (_amount == 0) revert SimpleLender__ZeroAmount();

        uint256 debt = getCurrentDebt(msg.sender);
        if (_amount > debt) revert SimpleLender__RepayExceeds(debt);

        Loan storage loan = s_loans[msg.sender];
        uint256 accruedInterest = debt - loan.borrowAmount;

        i_borrowToken.safeTransferFrom(msg.sender, address(this), _amount);

        // Track principal separately from interest for global accounting
        if (_amount > accruedInterest) {
            uint256 principalPaid = _amount - accruedInterest;
            loan.borrowAmount -= principalPaid;
            s_totalBorrows -= principalPaid;
        }
        // else: _amount <= accruedInterest, all goes to interest
        loan.lastUpdate = block.timestamp;

        emit LoanRepaid(msg.sender, _amount);

        if (loan.borrowAmount == 0) {
            uint256 collateral = loan.collateralAmount;
            loan.active = false;
            loan.collateralAmount = 0;
            s_totalDeposits -= collateral;
            i_collateralToken.safeTransfer(msg.sender, collateral);
            emit Withdrawn(msg.sender, collateral);
        }
    }

    /*
     * @dev Liquidate function. Subtracts only principal from s_totalBorrows
     * since interest accrual was never globally tracked. This prevents
     * arithmetic underflow in high-interest scenarios.
     */
    function liquidate(address _user) external nonReentrant {
        if (!s_loans[_user].active) revert SimpleLender__LoanNotExists();
        if (getCollateralRatio(_user) >= s_liqThreshold) revert SimpleLender__PositionHealthy();

        Loan storage loan = s_loans[_user];
        uint256 debt = getCurrentDebt(_user);
        uint256 collateral = loan.collateralAmount;

        uint256 liquidatorCollateral = collateral;

        i_borrowToken.safeTransferFrom(msg.sender, address(this), debt);

        // Subtract only principal (interest was never added to s_totalBorrows)
        s_totalBorrows -= loan.borrowAmount;
        s_totalDeposits -= collateral;

        loan.active = false;
        loan.collateralAmount = 0;
        loan.borrowAmount = 0;

        i_collateralToken.safeTransfer(msg.sender, liquidatorCollateral);
        emit Liquidated(_user, msg.sender, liquidatorCollateral);
    }

    function setInterestRate(uint256 _rate) external onlyOwner {
        s_interestRatePerSecond = _rate;
    }

    function setLiquidationParams(uint256 _threshold, uint256 _penalty) external onlyOwner {
        if (_threshold > 100 || _penalty > 50) revert SimpleLender__InvalidAddress();
        s_liqThreshold = _threshold;
        s_liqPenalty = _penalty;
    }

    function addLiquidity(uint256 _amount) external onlyOwner {
        if (_amount == 0) revert SimpleLender__ZeroAmount();
        i_borrowToken.safeTransferFrom(msg.sender, address(this), _amount);
    }

    function removeLiquidity(uint256 _amount) external onlyOwner {
        if (_amount == 0) revert SimpleLender__ZeroAmount();
        if (i_borrowToken.balanceOf(address(this)) < _amount + s_totalBorrows) revert SimpleLender__InsufficientLiquidity();
        i_borrowToken.safeTransfer(msg.sender, _amount);
        emit Withdrawn(msg.sender, _amount);
    }
}
