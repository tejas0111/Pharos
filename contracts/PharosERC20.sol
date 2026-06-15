// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

/// @title PharosERC20
/// @notice Standard ERC-20 token for Pharos testnet deployment example
/// @dev Inline implementation — no external dependency required
contract PharosERC20 {
    // --- Errors ---
    error PharosERC20__InvalidTransfer();
    error PharosERC20__InvalidApproval();
    error PharosERC20__InsufficientBalance();
    error PharosERC20__InsufficientAllowance();
    error PharosERC20__ZeroAddress();

    // --- Events ---
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

    // --- State ---
    string private s_name;
    string private s_symbol;
    uint8 private s_decimals;
    uint256 private s_totalSupply;
    mapping(address => uint256) private s_balances;
    mapping(address => mapping(address => uint256)) private s_allowances;

    // --- Constructor ---
    constructor(string memory _name, string memory _symbol, uint256 _initialSupply) {
        if (bytes(_name).length == 0) revert PharosERC20__InvalidTransfer();
        if (bytes(_symbol).length == 0) revert PharosERC20__InvalidTransfer();
        s_name = _name;
        s_symbol = _symbol;
        s_decimals = 18;
        s_totalSupply = _initialSupply;
        s_balances[msg.sender] = _initialSupply;
        emit Transfer(address(0), msg.sender, _initialSupply);
    }

    // --- ERC-20 Standard ---
    function name() external view returns (string memory) { return s_name; }
    function symbol() external view returns (string memory) { return s_symbol; }
    function decimals() external view returns (uint8) { return s_decimals; }
    function totalSupply() external view returns (uint256) { return s_totalSupply; }
    function balanceOf(address account) external view returns (uint256) { return s_balances[account]; }

    function transfer(address to, uint256 value) external returns (bool) {
        if (to == address(0)) revert PharosERC20__ZeroAddress();
        if (s_balances[msg.sender] < value) revert PharosERC20__InsufficientBalance();
        s_balances[msg.sender] -= value;
        s_balances[to] += value;
        emit Transfer(msg.sender, to, value);
        return true;
    }

    function allowance(address owner, address spender) external view returns (uint256) {
        return s_allowances[owner][spender];
    }

    function approve(address spender, uint256 value) external returns (bool) {
        if (spender == address(0)) revert PharosERC20__ZeroAddress();
        s_allowances[msg.sender][spender] = value;
        emit Approval(msg.sender, spender, value);
        return true;
    }

    function transferFrom(address from, address to, uint256 value) external returns (bool) {
        if (to == address(0)) revert PharosERC20__ZeroAddress();
        if (s_balances[from] < value) revert PharosERC20__InsufficientBalance();
        if (s_allowances[from][msg.sender] < value) revert PharosERC20__InsufficientAllowance();
        s_balances[from] -= value;
        s_balances[to] += value;
        s_allowances[from][msg.sender] -= value;
        emit Transfer(from, to, value);
        return true;
    }

    // --- Mint (only for testnet convenience) ---
    function mint(address to, uint256 value) external {
        if (to == address(0)) revert PharosERC20__ZeroAddress();
        s_totalSupply += value;
        s_balances[to] += value;
        emit Transfer(address(0), to, value);
    }
}
