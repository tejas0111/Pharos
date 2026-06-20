// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

/// @title PharosRWAToken
/// @notice ERC-20 compliant Real-World Asset token with KYC, freeze, pause, and transfer cooldown
/// @dev Combines KYC compliance (from original PharosRWAToken) + transfer cooldown (from RWAToken)
contract PharosRWAToken {
    // ──────────────────────────────────────────────
    // Custom Errors
    // ──────────────────────────────────────────────
    error PharosRWAToken__KYCExpired(address account);
    error PharosRWAToken__FrozenAccount(address account);
    error PharosRWAToken__SupplyCapExceeded();
    error PharosRWAToken__NotOwner();
    error PharosRWAToken__NotLegalAdmin();
    error PharosRWAToken__ContractPaused();
    error PharosRWAToken__TransferCooldown(address account, uint256 remaining);
    error PharosRWAToken__ZeroAddress();

    // ──────────────────────────────────────────────
    // Events
    // ──────────────────────────────────────────────
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    event KYCSet(address indexed account, uint256 expiry);
    event KYCRevoked(address indexed account);
    event AccountFrozen(address indexed account);
    event AccountUnfrozen(address indexed account);
    event Paused();
    event Unpaused();
    event LegalAdminSet(address indexed previousAdmin, address indexed newAdmin);
    event SupplyCapUpdated(uint256 oldCap, uint256 newCap);
    event TransferCooldownSet(uint256 cooldown);

    // ──────────────────────────────────────────────
    // Immutable State
    // ──────────────────────────────────────────────
    address public immutable i_owner;
    address public immutable i_legalAdmin;
    string public i_name;
    string public i_symbol;
    uint8 public immutable i_decimals;

    // ──────────────────────────────────────────────
    // Mutable State
    // ──────────────────────────────────────────────
    uint256 public s_totalSupply;
    uint256 public s_supplyCap;

    mapping(address => uint256) public s_balances;
    mapping(address => mapping(address => uint256)) public s_allowances;
    mapping(address => uint256) public s_kycExpiry;
    mapping(address => bool) public s_frozen;
    bool public s_paused;

    // Transfer cooldown (anti-flash-loan)
    uint256 public s_transferCooldown;
    mapping(address => uint256) public s_lastTransferTimestamp;

    // ──────────────────────────────────────────────
    // Modifiers
    // ──────────────────────────────────────────────
    modifier onlyOwner() {
        if (msg.sender != i_owner) revert PharosRWAToken__NotOwner();
        _;
    }

    modifier onlyLegal() {
        if (msg.sender != i_legalAdmin && msg.sender != i_owner) revert PharosRWAToken__NotLegalAdmin();
        _;
    }

    modifier whenNotPaused() {
        if (s_paused) revert PharosRWAToken__ContractPaused();
        _;
    }

    modifier respectCooldown(address from, address to) {
        if (from != i_owner && to != i_owner && s_transferCooldown > 0) {
            uint256 lastTx = s_lastTransferTimestamp[from];
            if (lastTx > 0 && block.timestamp < lastTx + s_transferCooldown) {
                revert PharosRWAToken__TransferCooldown(from, (lastTx + s_transferCooldown) - block.timestamp);
            }
        }
        _;
    }

    // ──────────────────────────────────────────────
    // Constructor
    // ──────────────────────────────────────────────
    constructor(
        string memory _name,
        string memory _symbol,
        uint8 _decimals,
        uint256 _initialSupply,
        uint256 _supplyCap,
        address _legalAdmin
    ) {
        if (_legalAdmin == address(0)) revert PharosRWAToken__ZeroAddress();
        i_owner = msg.sender;
        i_name = _name;
        i_symbol = _symbol;
        i_decimals = _decimals;
        i_legalAdmin = _legalAdmin;
        s_supplyCap = _supplyCap;

        // Owner gets perpetual KYC
        s_kycExpiry[msg.sender] = type(uint256).max;
        s_kycExpiry[_legalAdmin] = type(uint256).max;

        if (_initialSupply > 0) {
            if (_initialSupply > _supplyCap) revert PharosRWAToken__SupplyCapExceeded();
            s_balances[msg.sender] = _initialSupply;
            s_totalSupply = _initialSupply;
            emit Transfer(address(0), msg.sender, _initialSupply);
        }

        // Default 30-second transfer cooldown
        s_transferCooldown = 30;
    }

    // ──────────────────────────────────────────────
    // KYC & Compliance Checks
    // ──────────────────────────────────────────────
    function _checkKYC(address _account) internal view {
        if (s_kycExpiry[_account] == 0 || s_kycExpiry[_account] < block.timestamp) {
            revert PharosRWAToken__KYCExpired(_account);
        }
        if (s_frozen[_account]) revert PharosRWAToken__FrozenAccount(_account);
    }

    // ──────────────────────────────────────────────
    // ERC-20 Core
    // ──────────────────────────────────────────────
    function name() external view returns (string memory) { return i_name; }
    function symbol() external view returns (string memory) { return i_symbol; }
    function decimals() external view returns (uint8) { return i_decimals; }
    function totalSupply() external view returns (uint256) { return s_totalSupply; }
    function balanceOf(address _account) external view returns (uint256) { return s_balances[_account]; }
    function allowance(address _owner, address _spender) external view returns (uint256) { return s_allowances[_owner][_spender]; }

    function transfer(address _to, uint256 _value) external whenNotPaused respectCooldown(msg.sender, _to) returns (bool) {
        _checkKYC(msg.sender);
        _checkKYC(_to);
        s_balances[msg.sender] -= _value;
        s_balances[_to] += _value;
        s_lastTransferTimestamp[msg.sender] = block.timestamp;
        emit Transfer(msg.sender, _to, _value);
        return true;
    }

    function approve(address _spender, uint256 _value) external whenNotPaused returns (bool) {
        s_allowances[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }

    function transferFrom(address _from, address _to, uint256 _value) external whenNotPaused respectCooldown(_from, _to) returns (bool) {
        _checkKYC(_from);
        _checkKYC(_to);
        s_allowances[_from][msg.sender] -= _value;
        s_balances[_from] -= _value;
        s_balances[_to] += _value;
        s_lastTransferTimestamp[_from] = block.timestamp;
        emit Transfer(_from, _to, _value);
        return true;
    }

    // ──────────────────────────────────────────────
    // Mint & Burn
    // ──────────────────────────────────────────────
    function mint(address _to, uint256 _amount) external onlyOwner {
        if (_to == address(0)) revert PharosRWAToken__ZeroAddress();
        uint256 newSupply = s_totalSupply + _amount;
        if (newSupply > s_supplyCap) revert PharosRWAToken__SupplyCapExceeded();
        s_totalSupply = newSupply;
        s_balances[_to] += _amount;
        emit Transfer(address(0), _to, _amount);
    }

    function burn(uint256 _amount) external {
        if (_amount > s_balances[msg.sender]) revert PharosRWAToken__SupplyCapExceeded();
        s_balances[msg.sender] -= _amount;
        s_totalSupply -= _amount;
        emit Transfer(msg.sender, address(0), _amount);
    }

    // ──────────────────────────────────────────────
    // Admin: KYC
    // ──────────────────────────────────────────────
    function setKYC(address _account, uint256 _expiry) external onlyLegal {
        s_kycExpiry[_account] = _expiry;
        emit KYCSet(_account, _expiry);
    }

    function revokeKYC(address _account) external onlyLegal {
        delete s_kycExpiry[_account];
        emit KYCRevoked(_account);
    }

    // ──────────────────────────────────────────────
    // Admin: Freeze
    // ──────────────────────────────────────────────
    function freeze(address _account) external onlyLegal {
        s_frozen[_account] = true;
        emit AccountFrozen(_account);
    }

    function unfreeze(address _account) external onlyLegal {
        s_frozen[_account] = false;
        emit AccountUnfrozen(_account);
    }

    // ──────────────────────────────────────────────
    // Admin: Pause
    // ──────────────────────────────────────────────
    function pause() external onlyLegal {
        s_paused = true;
        emit Paused();
    }

    function unpause() external onlyLegal {
        s_paused = false;
        emit Unpaused();
    }

    // ──────────────────────────────────────────────
    // Admin: Supply Cap
    // ──────────────────────────────────────────────
    function setSupplyCap(uint256 _newCap) external onlyOwner {
        if (_newCap < s_totalSupply) revert PharosRWAToken__SupplyCapExceeded();
        emit SupplyCapUpdated(s_supplyCap, _newCap);
        s_supplyCap = _newCap;
    }

    // ──────────────────────────────────────────────
    // Admin: Transfer Cooldown
    // ──────────────────────────────────────────────
    function setTransferCooldown(uint256 _cooldown) external onlyOwner {
        s_transferCooldown = _cooldown;
        emit TransferCooldownSet(_cooldown);
    }
}
