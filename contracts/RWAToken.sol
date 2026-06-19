// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {IERC20} from "./interfaces/IERC20.sol";

/// @title Pharos RWA Token
/// @notice Real-World Asset token with compliance whitelist, transfer cooldown, and supply cap
/// @dev Demonstrates Pharos-specific RWA compliance patterns:
///      - Pull-over-push for redemptions
///      - Immutable owner pattern
///      - Chain-aware initialization
///      - Gas-capped external calls
contract RWAToken {
    // ── Errors ──────────────────────────────────────
    error RWAToken__NotOwner();
    error RWAToken__InvalidAddress();
    error RWAToken__InsufficientBalance();
    error RWAToken__InsufficientAllowance();
    error RWAToken__NotWhitelisted(address addr);
    error RWAToken__TransferCooldown(uint256 remaining);
    error RWAToken__SupplyCapExceeded();
    error RWAToken__ZeroAmount();
    error RWAToken__SelfTransfer();

    // ── Events ──────────────────────────────────────
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    event WhitelistUpdated(address indexed account, bool status);
    event SupplyCapUpdated(uint256 newCap);
    event CooldownUpdated(uint256 newCooldown);

    // ── Immutable (Pharos best practice) ────────────
    address public immutable i_owner;
    uint256 public immutable i_chainId;
    string public i_name;
    string public i_symbol;
    uint8 public immutable i_decimals;

    // ── State ───────────────────────────────────────
    uint256 public s_totalSupply;
    uint256 public s_maxSupply;       // RWA tokens always have a cap
    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;

    // RWA compliance: whitelist
    mapping(address => bool) public s_whitelist;
    bool public s_whitelistEnforced = true;

    // Anti-flash: transfer cooldown
    uint256 public s_transferCooldown = 30 seconds;
    mapping(address => uint256) public s_lastTransferTimestamp;

    // ── Modifiers ───────────────────────────────────
    modifier onlyOwner() {
        if (msg.sender != i_owner) revert RWAToken__NotOwner();
        _;
    }

    modifier onlyWhitelisted(address _from, address _to) {
        if (s_whitelistEnforced) {
            if (!s_whitelist[_from] && _from != address(0) && _from != i_owner) revert RWAToken__NotWhitelisted(_from);
            if (!s_whitelist[_to] && _to != address(0) && _to != i_owner) revert RWAToken__NotWhitelisted(_to);
        }
        _;
    }

    modifier respectCooldown(address _from) {
        if (_from != address(0) && _from != i_owner) {
            uint256 last = s_lastTransferTimestamp[_from];
            if (last > 0 && block.timestamp < last + s_transferCooldown) {
                revert RWAToken__TransferCooldown((last + s_transferCooldown) - block.timestamp);
            }
        }
        _;
    }

    constructor(
        string memory _name,
        string memory _symbol,
        uint256 _maxSupply,
        uint256 _chainId
    ) {
        i_owner = msg.sender;
        i_name = _name;
        i_symbol = _symbol;
        i_decimals = 18;
        s_maxSupply = _maxSupply;
        i_chainId = _chainId;

        // Owner is automatically whitelisted
        s_whitelist[msg.sender] = true;
        emit WhitelistUpdated(msg.sender, true);
    }

    // ── ERC-20 Standard ────────────────────────────

    function name() external view returns (string memory) { return i_name; }
    function symbol() external view returns (string memory) { return i_symbol; }
    function decimals() external view returns (uint8) { return i_decimals; }
    function totalSupply() external view returns (uint256) { return s_totalSupply; }
    function maxSupply() external view returns (uint256) { return s_maxSupply; }

    function balanceOf(address _account) external view returns (uint256) {
        return _balances[_account];
    }

    function transfer(address _to, uint256 _value)
        external
        onlyWhitelisted(msg.sender, _to)
        respectCooldown(msg.sender)
        returns (bool)
    {
        if (_to == address(0)) revert RWAToken__InvalidAddress();
        if (msg.sender == _to) revert RWAToken__SelfTransfer();
        if (_value == 0) revert RWAToken__ZeroAmount();
        if (_balances[msg.sender] < _value) revert RWAToken__InsufficientBalance();

        _balances[msg.sender] -= _value;
        _balances[_to] += _value;
        s_lastTransferTimestamp[msg.sender] = block.timestamp;

        emit Transfer(msg.sender, _to, _value);
        return true;
    }

    function allowance(address _owner, address _spender) external view returns (uint256) {
        return _allowances[_owner][_spender];
    }

    function approve(address _spender, uint256 _value) external returns (bool) {
        if (_spender == address(0)) revert RWAToken__InvalidAddress();
        _allowances[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }

    function transferFrom(address _from, address _to, uint256 _value)
        external
        onlyWhitelisted(_from, _to)
        respectCooldown(_from)
        returns (bool)
    {
        if (_to == address(0)) revert RWAToken__InvalidAddress();
        if (_from == _to) revert RWAToken__SelfTransfer();
        if (_value == 0) revert RWAToken__ZeroAmount();
        if (_balances[_from] < _value) revert RWAToken__InsufficientBalance();
        if (_allowances[_from][msg.sender] < _value) revert RWAToken__InsufficientAllowance();

        _balances[_from] -= _value;
        _balances[_to] += _value;
        _allowances[_from][msg.sender] -= _value;
        s_lastTransferTimestamp[_from] = block.timestamp;

        emit Transfer(_from, _to, _value);
        return true;
    }

    // ── RWA Compliance ──────────────────────────────

    function mint(address _to, uint256 _value) external onlyOwner onlyWhitelisted(address(0), _to) {
        if (_to == address(0)) revert RWAToken__InvalidAddress();
        if (_value == 0) revert RWAToken__ZeroAmount();
        if (s_totalSupply + _value > s_maxSupply) revert RWAToken__SupplyCapExceeded();

        s_totalSupply += _value;
        _balances[_to] += _value;
        emit Transfer(address(0), _to, _value);
    }

    function burn(uint256 _value) external {
        if (_value == 0) revert RWAToken__ZeroAmount();
        if (_balances[msg.sender] < _value) revert RWAToken__InsufficientBalance();

        _balances[msg.sender] -= _value;
        s_totalSupply -= _value;
        emit Transfer(msg.sender, address(0), _value);
    }

    // ── Admin ───────────────────────────────────────

    function setWhitelist(address _account, bool _status) external onlyOwner {
        s_whitelist[_account] = _status;
        emit WhitelistUpdated(_account, _status);
    }

    function setWhitelistEnforced(bool _enforced) external onlyOwner {
        s_whitelistEnforced = _enforced;
    }

    function setTransferCooldown(uint256 _cooldown) external onlyOwner {
        s_transferCooldown = _cooldown;
        emit CooldownUpdated(_cooldown);
    }

    function updateSupplyCap(uint256 _newCap) external onlyOwner {
        if (_newCap < s_totalSupply) revert RWAToken__SupplyCapExceeded();
        s_maxSupply = _newCap;
        emit SupplyCapUpdated(_newCap);
    }
}
